`timescale 1 ps/1 ps

parameter T_DATA_WIDTH  = 8                   ;
parameter T_QOS__WIDTH  = 4                   ;
parameter STREAM_COUNT  = 2                   ;
parameter T_ID___WIDTH  = $clog2(STREAM_COUNT);
parameter LATENCY_SLAVE = 1                   ;

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

generate
  if (LATENCY_SLAVE == 1) begin

    stream_arbiter_latency_0 #(
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

  end else begin
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
  end
  endgenerate

  integer       count         = 0;
  logic         ready_delay_0    ;
  logic         ready_delay_1    ;
  logic   [7:0] data_1           ;
  logic   [7:0] data_2           ;



  task wait_clk(int i);
    repeat (i) @(posedge clk_i);
  endtask : wait_clk

task test_arbiter_1(int i);
  while (count >= 0) begin
    if (count <= 2) begin
      m_ready_i <= 1;
      s_valid_i <= '0;
      s_qos_i[0] <= 1;
      s_qos_i[1] <= 5;
      count++;
      wait_clk(1);
    end else if (count >= 2 && count <= 4 ) begin
      count++;
      s_valid_i[1] <= 0;
      wait_clk(1);
    end else if (count >= 2 && count <= 4 && count <= 10) begin
      count++;
      s_valid_i[1] <= 0;
      wait_clk(1);
    end else if ( count >=4 && count <= 10) begin
      if (count == 5 || count == 10) begin
        s_last_i[0] <= 1;
        s_last_i[1] <= 1;
        s_qos_i[0] <= $urandom_range(0,15);
        s_qos_i[1] <= $urandom_range(0,15);
        wait_clk(1);
        s_last_i[0] <= 0;
        s_last_i[1] <= 0;
      end
      count++;
      s_valid_i[0] <= 0;
      s_valid_i[1] <= 1;
      wait_clk(1);
    end else if ( count >= 4 && count <= 10) begin
      if (count == 10 || count == 5) begin
        s_last_i[1] <= 1;
        s_qos_i[0] <= 2;
        s_qos_i[1] <= 1;
        count++;
        wait_clk(1);
        s_last_i[1] <= 0;
      end
      count++;
      s_valid_i[0] <= 1;
      s_valid_i[1] <= 1;
      wait_clk(1);
    end else if ( count >= 10 && count <= 15  ) begin
      if (count == 15 ) begin
        s_last_i[0] <= 1;
        s_last_i[1] <= 1;
        s_qos_i[0] <= 0;
        s_qos_i[1] <= 0;
        wait_clk(1);
        s_last_i[0] <= 0;
        s_last_i[1] <= 0;
      end
      count++;
      s_valid_i[0] <= 1;
      s_valid_i[1] <= 1;
      wait_clk(1);
    end else if ( count >= 15 && count <= 20 ) begin
      if (count == 20 ) begin
        s_last_i[0] <= 1;
        s_qos_i[0] <= 0;
        s_qos_i[1] <= 0;
        wait_clk(1);
        s_last_i[0] <= 0;
      end
      count++;
      s_valid_i[0] <= 1;
      s_valid_i[1] <= 1;
      wait_clk(1);
    end else if ( count >= 20 && count <= 25 ) begin
      if (count == 25 ) begin
        s_last_i[0] <= 1;
        s_qos_i[0] <= 0;
        s_qos_i[1] <= 4;
        wait_clk(1);
        s_last_i[0] <= 0;
      end
      count++;
      s_valid_i[0] <= 1;
      s_valid_i[1] <= 1;
      wait_clk(1);
    
  end else if ( count >= 25 ) begin
      if (count == 30 ) begin
        s_last_i[0] <= 1;
        s_qos_i[0] <= 0;
        s_qos_i[1] <= 0;
        wait_clk(1);
        s_last_i[0] <= 0;
      end
      count++;
      s_valid_i[0] <= 1;
      s_valid_i[1] <= 1;
      wait_clk(1);
    end
    if (count == 40)
      break;
  end
endtask : test_arbiter_1


    initial begin
      forever begin
        ready_delay_0 <= s_ready_o[0];
        ready_delay_1 <= s_ready_o[1];
        wait_clk(1);
      end
    end 

  initial begin
    clk_i = 0;
    rst_n = 1;
    s_last_i = '0;
    forever #2 clk_i = ~clk_i ; 
  end

  always_ff @(posedge clk_i or negedge rst_n) begin : proc_s_data_i
     begin 
      s_data_i[0] <= $urandom_range(0,10);
      s_data_i[1] <= $urandom_range(0,10);
      data_1        <= s_data_i[1];
      data_2        <= s_data_i[0];
    end
  end


  initial begin
    wait_clk(1);
    rst_n = 0;
    wait_clk(1);
    m_ready_i <= '1;
    rst_n = 1;
    wait_clk(1);
    test_arbiter_1(1);
    wait_clk(4);
     forever #4 s_valid_i <= $urandom_range(0,3);
  end

  initial begin 
    wait_clk(100);
    forever #4 m_ready_i <= $urandom_range(0,1);

  end 

endmodule
