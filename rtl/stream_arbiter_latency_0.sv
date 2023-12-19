/*------------------------------------------------------------------------------
-- арбитр реализован на основе конечного автомата с двумя состояниями :
1. выбор приоритетного потока
2. выдача данных с выбранного потока

Принцип Round-Robin реализован счетсчиком до 3 пакетов с одного потока при одной
и той же приоритетности на потоках или при при приоритетности равной 0 на одном из потоков.
При одной и той же приоритетности потоков, первым на выход выбирается 1 поток.

Модуль буфферизирует данные на один такт, для реализации последовательстной логики и
синхронизации схемы. (выходное Latency = 1)

При изменении количества потоков, необходимо будет изменить логику выходного сигнала s_ready_o
(изменить значения 113 и 115 строка), а так же добавить кол-во переборов в 72, 75, 79 строке


------------------------------------------------------------------------------*/
module stream_arbiter_latency_0 #(
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
  logic [T_ID___WIDTH-1:0] select_stream_reg; // регистр выбраного потока
  logic [             1:0] cnt_rr           ; // счетчик для Round-Robin очереди
  logic                    rr_reg           ; // регистр для Round-Robin очереди

  enum logic [2:0] {IDLE, DATA} state; // состояния автомата
/*------------------------------------------------------------------------------
--
------------------------------------------------------------------------------*/
  always_ff @( posedge clk_i or negedge rst_n ) begin
    if( ~rst_n ) begin
      select_stream_reg <= '0;
      m_data_o          <= '0;
      m_qos_o           <= '0;
      m_id_o            <= '0;
      m_last_o          <= '0;
      m_valid_o         <= '0;
      cnt_rr            <= '0;
      rr_reg            <= '0;
      state             <= IDLE;
    end else if ( m_ready_i ) begin // конечный автомат с двумя состояниями определия приоритетного потока и выдачи данных
      case ( state )
        IDLE :
          begin        // при выборе приоритетного сигнала модуль не готов к принятию данных
            m_last_o <= '0;
            for ( int i = 1; i < STREAM_COUNT; i++ ) begin              // цикл  перебора двух потоков
              // сравнение двух потоков на более приотритеный без учета 0 приоритетности b одинаковых приоритетов
              if ( (s_qos_i[i] !== s_qos_i[i-1]) && (s_qos_i[i] !== 0 && s_qos_i[i-1] !== 0))
                begin
                  cnt_rr <= '0;                                         // сброс очереди Round-Robin
                  if ( (s_qos_i[i] > s_qos_i[i-1]) && s_valid_i[i]  )   // приоритет у второго потока
                    begin
                      select_stream_reg <= i;
                    end
                  else if (s_qos_i[i] < s_qos_i[i-1] && s_valid_i[i-1]) // приоритет у первого потока
                    begin
                      select_stream_reg <= i-1;
                    end
                  else if (s_valid_i[i])   // приоритет уходит единственному валидному потоку
                    begin
                      select_stream_reg <= i;
                    end
                end
              else if ( &s_valid_i ) begin // очередь Round-Robin если одинаковые приоритетности и они валидны
                cnt_rr <= cnt_rr + 1'b1;   // Round-Robin до трех итераций одного потока
                if ( cnt_rr == STREAM_COUNT )
                  begin
                    cnt_rr <= '0;
                  end
                if (cnt_rr == STREAM_COUNT)
                  begin
                    rr_reg <= ~rr_reg;
                  end
                select_stream_reg <= rr_reg; //{select_stream_reg[T_ID___WIDTH-1:1], rr_reg}; // при одной приоритетности первым пойдет первый поток
              end
            end
            if ( s_valid_i )  begin          // если вадида нет, то данные на выход не идут
              state     <= DATA;
              m_valid_o <= '0;
            end else
            begin
              m_valid_o <= '0;
            end
          end
        DATA :
          begin
            if (s_valid_i[select_stream_reg]) begin // на выход идут только валидные данные
              m_data_o  <= s_data_i[select_stream_reg]; // данные выбраного потока
              m_id_o    <= select_stream_reg;           // номер выбранного потока
              m_last_o  <= s_last_i[select_stream_reg]; // данные корректны
              m_valid_o <= '1;
              m_qos_o   <= s_qos_i[select_stream_reg];
              if (s_last_i[select_stream_reg]) begin
                state <= IDLE;                           // при достижении конца пакета переход на выбор потока
              end
            end
            else begin // при отсутсвии валида на выбранном потоке ожидание
              m_data_o  <= m_data_o;
              m_id_o    <= m_id_o;
              m_last_o  <= m_last_o;
              m_valid_o <= '0;
              m_qos_o   <= m_qos_o;
            end
          end
        default :
          begin
            m_data_o  <= m_data_o;
            m_id_o    <= m_id_o;
            m_last_o  <= '0;
            m_valid_o <= '0;
            m_qos_o   <= m_qos_o;
            state     <= IDLE;
          end
      endcase
    end else if (~m_ready_i) begin
      m_valid_o <= '0;
    end
  end

  always_comb begin
    if ( state == IDLE && s_valid_i ) begin
      s_ready_o = '0;
    end else if ( m_ready_i ) begin
      if ( select_stream_reg && state == DATA )
        s_ready_o = {select_stream_reg , 1'b0}; // выходная готовность используемого потока для slave модуля
      else if ( ~select_stream_reg && state == DATA )
        s_ready_o = {1'b0 , ~select_stream_reg};
    end else if ( ~m_ready_i ) begin
      s_ready_o = '0;
    end else begin
      s_ready_o = '1;
    end
  end


endmodule 
