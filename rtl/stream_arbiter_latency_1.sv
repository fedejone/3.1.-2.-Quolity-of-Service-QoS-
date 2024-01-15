/*------------------------------------------------------------------------------
-- 
------------------------------------------------------------------------------*/
module stream_arbiter_latency_1 #(
  parameter T_DATA_WIDTH = 8                   ,
  parameter T_QOS__WIDTH = 4                   ,
  parameter STREAM_COUNT = 2                   ,
  parameter T_ID___WIDTH = $clog2(STREAM_COUNT)
) (
  input  logic                    clk_i                      ,
  input  logic                    rst_n                      ,
  // input streams
  input  logic [T_DATA_WIDTH-1:0] s_data_i [STREAM_COUNT-1:0],
  input  logic [T_QOS__WIDTH-1:0] s_qos_i  [STREAM_COUNT-1:0],
  input  logic [STREAM_COUNT-1:0] s_last_i                   ,
  input  logic [STREAM_COUNT-1:0] s_valid_i                  ,
  output logic [STREAM_COUNT-1:0] s_ready_o                  ,
  // output stream
  output logic [T_DATA_WIDTH-1:0] m_data_o                   ,
  output logic [T_QOS__WIDTH-1:0] m_qos_o                    ,
  output logic [T_ID___WIDTH-1:0] m_id_o                     ,
  output logic                    m_last_o                   ,
  output logic                    m_valid_o                  ,
  input  logic                    m_ready_i
);


/*------------------------------------------------------------------------------
-- internal signals
------------------------------------------------------------------------------*/
  logic [T_ID___WIDTH-1:0] select_stream_reg  ; // регистр выбраного потока
  logic [             1:0] cnt_rr             ; // счетчик для Round-Robin очереди
  logic [T_ID___WIDTH-1:0] rr_reg             ; // регистр для Round-Robin очереди
  logic [T_QOS__WIDTH-1:0] select_qos_reg     ; // регистр выбранной приоритетности
  logic [STREAM_COUNT-1:0] same_priorities_reg; // сигналы с одинаковой приоритетностью
  logic [  T_ID___WIDTH:0] quantity_one_prior ; // количесвто одинаковых сигнлаов
  enum logic [1:0] {IDLE, QUEUE, DATA} state;   // состояния автомата
/*------------------------------------------------------------------------------
-- выбор наибольшей приоритетноти и счет кол-ва одинаковых приоритетностей 
------------------------------------------------------------------------------*/
  always_comb begin : proc_select_qos_reg
    select_qos_reg     = '0;
    quantity_one_prior = '0;
    for ( int i = 0; i < STREAM_COUNT ; i++ ) begin // цикл  перебора потоков
      begin
        if ((s_qos_i[i] > select_qos_reg) && s_valid_i[i])
          select_qos_reg = s_qos_i[i]; // присвоение максимальной приоритетности
      end
      if (same_priorities_reg[i])
        quantity_one_prior = quantity_one_prior + 1'b1; // счет кол-ва одинаковых потоков в очереди
    end
  end
/*------------------------------------------------------------------------------
--  автомат трех состояний 
IDLE - выбор приориеттного потока и фиксация этого потока в регистр same_priorities_reg
QUEUE - при одинкаовых или 0 приоритетности циклическая смена потоков каждые два пакета
DATA - выдача данных выбранного потока и выставление ready_o
------------------------------------------------------------------------------*/
  always_ff @( posedge clk_i or negedge rst_n ) begin
    if( ~rst_n ) begin
      select_stream_reg   <= '0;
      same_priorities_reg <= '0;
      m_data_o            <= '0;
      m_qos_o             <= '0;
      m_id_o              <= '0;
      m_last_o            <= '0;
      m_valid_o           <= '0;
      s_ready_o           <= '0;
      cnt_rr              <= '0;
      rr_reg              <= '0;
      state               <= IDLE;
    end else if ( m_ready_i ) begin // конечный автомат с двумя состояниями определия приоритетного потока и выдачи данных
      case ( state )
        IDLE :
          begin                        // при выборе приоритетного сигнала модуль не готов к принятию данных
            s_ready_o           <= '0;
            m_last_o            <= '0;
            m_valid_o           <= '0;
            same_priorities_reg <= '0; // сбросить маску на одинаковые потоки для выставления новой
            if (s_valid_i) begin       // если вадида нет, то данные на выход не идут
              for ( int i = 0; i < STREAM_COUNT; i++ ) begin // цикл  перебора потоков для выделения максимального
                if ( (s_qos_i[i] == select_qos_reg) && s_valid_i[i] || (s_qos_i[i] == 0) && s_valid_i[i])
                  begin
                    select_stream_reg      <= i;
                    same_priorities_reg[i] <= 1'b1; // маска сигналов максимального приоритета
                  end
              end  // конец цикла
              state <= QUEUE;
            end
          end
        QUEUE :
          begin
            s_ready_o <= '0;
            m_last_o  <= '0;
            if ( quantity_one_prior > 1 ) begin // очередь Round-Robin если одинаковые приоритетности
              cnt_rr <= cnt_rr + 1'b1;   //  счет кол-ва повторений прихода одной проиритетности
              for ( int i = 0; i < STREAM_COUNT; i++ ) begin // цикл колцевой смены потоков
                if ( same_priorities_reg[i] && rr_reg == i ) // по маске same_priorities_reg и регистру rr_reg выбор следующего потока с одним приоритетом
                  select_stream_reg <= i;
              end // конец цикла
              if ( cnt_rr == 2 ) begin // смена потока одинаковых приоритетностей каждые два такта
                cnt_rr <= '0;
                if ( rr_reg == quantity_one_prior-1 )  // сброс, при достижении кол-ва одинаковых потоков
                  rr_reg <= '0;
                else
                  rr_reg <= rr_reg + 1'b1; // кольцевая смена потоков, начиная с первого
              end
            end
            else begin
              cnt_rr <= '0; // сброс регистров round-robin при отсутсвии одинаковых приоритетов
              rr_reg <= '0;
            end
            state     <= DATA;
            m_valid_o <= '0;
          end
        DATA :
          begin
            if (s_valid_i[select_stream_reg]) begin // на выход идут только валидные данные
              m_data_o                     <= s_data_i[select_stream_reg]; // данные выбраного потока
              m_id_o                       <= select_stream_reg;           // номер выбранного потока
              m_last_o                     <= s_last_i[select_stream_reg]; // данные корректны
              m_valid_o                    <= '1;
              m_qos_o                      <= s_qos_i[select_stream_reg];
              s_ready_o[select_stream_reg] <= 1'b1;                        // сигнла ready отправляется только выбранному потоку
              if (s_last_i[select_stream_reg]) begin
                state <= IDLE;  // при достижении конца пакета переход на выбор потока
              end
            end
            else begin // при отсутсвии валида на выбранном потоке - ожидание
              m_data_o  <= m_data_o;
              m_id_o    <= m_id_o;
              m_last_o  <= m_last_o;
              m_valid_o <= '0;
              m_qos_o   <= m_qos_o;
              s_ready_o <= s_ready_o;
            end
          end
      endcase
    end else begin // ожиданеие при отсутсвии ready_i
      m_valid_o <= '0;
      s_ready_o <= '0;
      m_data_o  <= m_data_o;
      m_id_o    <= m_id_o;
      m_last_o  <= m_last_o;
      m_qos_o   <= m_qos_o;
    end
  end

  


endmodule 
