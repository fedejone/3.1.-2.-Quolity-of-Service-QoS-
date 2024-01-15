

# Описание модуля

  

**За основу проектирования был взят конечный автомат с тремя состояниями**

**Модуль параметризирован и может использоваться для большего кол-ва потоков** 
  
![](/doc/1.jpg)
- IDLE - выбор приоритетного потока и фиксация этого потока в регистр same_priorities_reg

- QUEUE - при одинаковых или 0 приоритетности циклическая смена потоков каждые два пакета

- DATA - выдача данных выбранного потока и выставление ready_o

--------------------------------------------------------------------------------------------------------------------

**Выбор приоритета** реализован перебором валидных сигналов
приоритета и выбор наибольшего из них, при равнозначных приоритетностях преимущество отдается первому потоку и сменяется по принципу Round-Robin каждые две транзакции одного потока (две транзакции один - две транзакции другой). Приоритетность равная 0 не сравнивается, а считается за равнозначный сигнал по приоритетности и так же выбирается по принципу карусели.

Цикл счета транзакций Round-Robin сбрасывается если на вход приходит одна более приоритетная транзакция.

При состоянии *IDLE и QUEUE*  выходной валид равен 0

**Выдача данных** происходит по выбранному приоритетному потоку. При пришествии на модуль сигнала *s_last_i*, модуль дублирует его на выход и переходит в состояние IDLE для выбора следующего приоритета.

Если при выдачи данных сигнал если  *валид* пропал, то автомат ожидает пришествия *валида* и убирает сигнал *валид* на выход

  

---

  

  

**Сигнал *s_ready_o*** :
Готовность отправляется только выбранному потоку, после каждой транзакции сигнал готовности обновляется по выбранному сигналу. Т.е сигнал готовности (активный 1) отправляется только на тот поток который выбран в данный момент. Сигнал обнуляется для всех потоков на момент выбора приоритетного сигнала ( состояние автомата IDLE и QUEUE). 

*При падении сигнала m_ready_i s_ready_o также падает с задержкой в такт*

  

---

**Сигнал** ***m_valid_o***:

Выходной сигнал корректности данных не активен при выборе приоритетного потока (состояние автомата *IDLE и QUEUE*). При выдаче данных активен, если активен входной сигнал *валид*.

Выходной *валид* так же задерживается на один такт по сравнению с входным.

  

---

***В коде проекта закомментированы основные процессы выполнения алгоритма описанного выше***

  

Проект состоит из 2-х файлов

- *stream_arbiter_latency_1*

- *stream_arbiter_top* - топовый файл

---

Отчет о синтезе :

![  ](/doc/3.png)

  

Предельная частота на данном кристалле для двух потоков 408 Мгц

  

![  ](/doc/4.png)

- критический путь ![  ](/doc/7.png)

- ![ RTL модель критического пути ](/doc/8.png)

Критический путь состоит в основном из логики двух входовых мультиплексоров. Если убавить количество элементов if в коде логики выбора приоритетного потока, можно сократить критический путь и увеличить максимальную частоту.

---

- Код проекта находится в папке *RTL*

- Тестбенч модуля находится в папке *tb*

- Скрипт для запуска симуляции проекта находится в папке sim\modelsim\make_file.bat

- Скрипт для запуска синтеза проекта находится в папке syn\Quartus\make_analyz.bat

- Для открытия проекта запустить Quartus, запустить скрипт в папке syn\Quartus\make_analyz.bat. Открыть проект в папке syn\Quartus\stream_arbiter_top.qpf

  
**Не уверен что правильного реализовал алгоритм Round-Robin**

  

