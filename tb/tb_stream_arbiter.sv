`timescale 1 ps/1 ps

parameter T_DATA_WIDTH  = 8                   ;
parameter T_QOS__WIDTH  = 4                   ;
parameter STREAM_COUNT  = 2                   ;
parameter T_ID___WIDTH  = $clog2(STREAM_COUNT);
parameter LATENCY_SLAVE = 0                   ;

module tb_stream_arbiter ();
  logic                    clk_i                      ; // Clock
  logic                    rst_n                      ; // Asynchronous reset active low
  logic [T_DATA_WIDTH-1:0] s_data_i [STREAM_COUNT-1:0];
  logic [T_QOS__WIDTH-1:0] s_qos_i  [STREAM_COUNT-1:0];
  logic [STREAM_COUNT-1:0] s_last_i                   ;
  logic [STREAM_COUNT-1:0] s_valid_i                  ;
  logic [STREAM_COUNT-1:0] s_ready_o                  ;

  logic [T_DATA_WIDTH-1:0] m_data_o ;
  logic [T_QOS__WIDTH-1:0] m_qos_o  ;
  logic [T_ID___WIDTH-1:0] m_id_o   ;
  logic                    m_last_o ;
  logic                    m_valid_o;
  logic                    m_ready_i;

  
      stream_arbiter_latency_1 #(
        .T_DATA_WIDTH(T_DATA_WIDTH),
        .T_QOS__WIDTH(T_QOS__WIDTH),
        .STREAM_COUNT(STREAM_COUNT)
      ) uut_stream_arbiter (
        .clk_i    (clk_i    ),
        .rst_n    (rst_n    ),
        .s_data_i (s_data_i ),
        .s_qos_i  (s_qos_i  ),
        .s_last_i (s_last_i ),
        .s_valid_i(s_valid_i),
        .s_ready_o(s_ready_o),
        .m_data_o (m_data_o ),
        .m_qos_o  (m_qos_o  ),
        .m_id_o   (m_id_o   ),
        .m_last_o (m_last_o ),
        .m_valid_o(m_valid_o),
        .m_ready_i(m_ready_i)
      );

  logic                    ready_delay_0;
  logic                    ready_delay_1;
  logic [             7:0] data_1       ;
  logic [             7:0] data_2       ;
  logic [             7:0] data_3       ;
  logic [             7:0] data_4       ;
  logic [T_QOS__WIDTH-1:0] qos_1        ;
  logic [T_QOS__WIDTH-1:0] qos_2        ;
  logic [T_QOS__WIDTH-1:0] qos_3        ;
  logic [T_QOS__WIDTH-1:0] qos_4        ;

  typedef struct {
    logic [T_DATA_WIDTH-1:0] sdata;
    logic [T_QOS__WIDTH-1:0] id  ;
    logic [T_QOS__WIDTH-1:0] qos;
  } packet;

  mailbox#(packet) in = new();
  mailbox#(packet) out = new();

  task wait_clk(int i);
    repeat (i) @(posedge clk_i);
  endtask : wait_clk
 /*------------------------------------------------------------------------------
 --  начальные значения
 ------------------------------------------------------------------------------*/
  initial begin
    clk_i = 0;
    rst_n = 1;
    s_last_i = '0;
    forever #2 clk_i = ~clk_i ;
  end

  initial begin
    wait_clk(1);
    rst_n = 0;
    wait_clk(1);
    m_ready_i <= '1;
    rst_n = 1;
    wait_clk(1);
  end
/*------------------------------------------------------------------------------
--  значения сигналов значения
------------------------------------------------------------------------------*/
  initial begin
    wait(~rst_n);
    s_data_i[0] <= '0;
    s_data_i[1] <= '0;
    s_qos_i[0] <= 1;
    s_qos_i[1] <= 2;
    s_qos_i[2] <= 3;
    s_qos_i[3] <= 4;
    s_last_i <= '0;
    s_valid_i <= '0;
    wait_clk(4);
    s_valid_i = '1;
    s_qos_i[0] <= 1;
    s_qos_i[1] <= 0;
    s_qos_i[2] <= 1;
    s_qos_i[3] <= 1;
    wait(rst_n);
    repeat(200) begin
      @(posedge clk_i);
      s_valid_i = '1;
      if (s_ready_o !== 0) begin
        s_data_i[0] <= $urandom();
        s_data_i[1] <= $urandom();
        s_data_i[2] <= $urandom();
        s_data_i[3] <= $urandom();
        s_last_i[m_id_o] <= $urandom();
      end
      if (m_last_o) begin
        // @(negedge clk_i)
        s_qos_i[0] <=$urandom_range(0,15);
        s_qos_i[1] <=$urandom_range(0,15);
        s_qos_i[2] <=$urandom_range(0,15);
        s_qos_i[3] <=$urandom_range(0,15);
        wait_clk(2);
        s_valid_i = '0;
      end
    end
    $stop();
    m_ready_i = '0;
  end

  initial begin
    packet p;
    wait(rst_n);
    forever begin
      @(posedge clk_i);
      if ((s_valid_i[0] && s_ready_o[0]) || (s_valid_i[1] && s_ready_o[1])) begin
        if ((s_qos_i[0] > s_qos_i[1])  && s_qos_i[0] !== 0 && s_qos_i[1] !== 0 ) begin
          p.sdata = s_data_i[0];
          p.qos = s_qos_i[0];
          in.put(p);
        end else if (s_qos_i[0] < s_qos_i[1] && s_qos_i[1] !== 0 && s_qos_i[0] !== 0) begin
          p.sdata = s_data_i[1];
          p.qos = s_qos_i[1];
          in.put(p);
        end
      end
    end
  end

initial begin
  packet p;
  wait(rst_n);
  forever begin
    @(posedge clk_i);
    if (m_valid_o && m_ready_i) begin
      wait_clk(1);
      p.sdata = m_data_o;
      p.id = m_id_o;
      p.qos = m_qos_o;
      out.put(p);
    end
  end
end

initial begin   // проверка пакетов (работает не корректно)
  packet in_p, out_p;
  forever begin 
    in.get(in_p);
    out.get(out_p);
      if (in_p.qos !== out_p.qos && m_valid_o  ) begin 
        $warning("%0t Invalid priority REAL:%d EXPECTED:%d",
        $time(), out_p.qos, in_p.qos);
    end   
      if (in_p.sdata !== out_p.sdata && m_valid_o) begin  
       $warning("Invalid DATA");
      end 
    end 
  end 

  assign data_1 = s_data_i[0];
  assign data_2 = s_data_i[1];
  assign qos_1  = s_qos_i[0];
  assign qos_2  = s_qos_i[1];
  assign qos_3  = s_qos_i[2];
  assign qos_4  = s_qos_i[3];
  assign data_3 = s_data_i[2];
  assign data_4 = s_data_i[3];

  endmodule
