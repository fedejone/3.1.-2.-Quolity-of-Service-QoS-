module stream_arbiter_top #(
  parameter T_DATA_WIDTH  = 8                   ,
  parameter T_QOS__WIDTH  = 4                   ,
  parameter STREAM_COUNT  = 2                   ,
  parameter T_ID___WIDTH  = $clog2(STREAM_COUNT),
  parameter LATENCY_SLAVE = 0
) (
  input                     clk_i                      , // Clock
  input                     rst_n                      ,
  // input streams
  input  [T_DATA_WIDTH-1:0] s_data_i [STREAM_COUNT-1:0],
  input  [T_QOS__WIDTH-1:0] s_qos_i  [STREAM_COUNT-1:0],
  input  [STREAM_COUNT-1:0] s_last_i                   ,
  input  [STREAM_COUNT-1:0] s_valid_i                  ,
  output [STREAM_COUNT-1:0] s_ready_o                  ,
   // output stream
  output [T_DATA_WIDTH-1:0] m_data_o                   ,
  output [T_QOS__WIDTH-1:0] m_qos_o                    ,
  output [T_ID___WIDTH-1:0] m_id_o                     ,
  output                    m_last_o                   ,
  output                    m_valid_o                  ,
  input                     m_ready_i
);

generate
  if (LATENCY_SLAVE == 1) begin

    stream_arbiter_latency_0 #(
      .T_DATA_WIDTH(T_DATA_WIDTH),
      .T_QOS__WIDTH(T_QOS__WIDTH),
      .STREAM_COUNT(STREAM_COUNT)
    ) uut_stream_arbiter_0 (
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
    ) uut_stream_arbiter_1 (
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

  

endmodule
