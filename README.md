
# Описание модуля 

![ ](/doc/1.png)
 **За основу проектирования был взят конечный автомат с двумя состояниями** 

 -  Выбор приоритетного потока 
 - Выдача данных с выбранного потока 
 --------------------------------------------------------------------------------------------------------------------
 **Выбор приоритета** реализован перебором валидных сигналов

    for ( int i = 1; i < STREAM_COUNT; i++ )

 приоритета и выбор наибольшего из них, при равнозначных приоритетностях преимущество отдается первому потоку и сменяется по принципу Round-Robin каждые три транзакции одного потока (три транзакции один - три транзакции другой). Приоритетность равная 0 не сравнивается, а считается за равнозначный сигнал по приоритетности и так же выбирается по принципу карусели.
 Цикл счета транзакций Round-Robin сбрасывается если на вход приходит одна более приоритетная транзакция.
 При состоянии *IDLE* выходной валид равен 0
**Выдача данных** происходит по выбранному приоритетному потоку. При пришествии на модуль сигнала *s_last_i*, модуль дублирует его на выход и переходит в состояние IDLE для выбора следующего приоритета. 
Если при выдачи данных сигнал *валид* пропал, то автомат ожидает пришествия *валида* и убирает сигнал *валид* на выход

    

![блок схема алгоритма ](/doc/2.png)

---

## Подмодули
Модуль делится на два подмодуля с разными входными латентностями.

**stream_arbiter_latency_0**: 
модуль, посылает сигнал *s_ready_o* без задержки в такт для того чтобы slave модуль на следующий такт не отправлял данные т.к произойдет потеря этих данных. Следует использовать если  выходная латентность модуля slave равна 1.

**stream_arbiter_latency_1**: 
модуль посылает сигнал *s_ready_o*  с задержкой в такт. Следует применять если выходная латентность slave модуля равна 0.

**Выбор подмодулей** реализован изменением параметра *LATENCY_SLAVE* при LATENCY_SLAVE = 1, выбирается модуль stream_arbiter_latency_0, при LATENCY_SLAVE = 0, stream_arbiter_latency_1

---
**Сигнал *s_ready_o*** :
Сигнал готовности для slave модуля посылается в нулевой момент времени для всех потоков, после выбора приоритетного, готовность отправляется только выбранному потоку, после каждой транзакции сигнал готовности обновляется по выбранному сигналу. Т.е сигнал готовности (активный 1) отправляется только на тот поток который выбран в данный момент. Сигнал обнуляется для всех потоков на момент выбора приоритетного сигнала ( состояние автомата IDLE). Также сигнал активен для всех потоков если валид не приходит ни с одного потока.
 *При падении сигнала m_ready_i s_ready_o также падает с задержкой в такт*

---
**Сигнал**  ***m_valid_o***:
Выходной сигнал корректности данных не активен при выборе приоритетного потока (состояние автомата *IDLE*). При выдаче данных активен, если активен входной сигнал *валид*.
Выходной *валид* так же задерживается на один такт по сравнению с входным.

---
***В коде проекта закомментированы основные процессы выполнения алгоритма описанного выше*** 
Проект состоит из 3-х файлов:

 - *stream_arbiter_latency_0*
 - *stream_arbiter_latency_1*
 - *stream_arbiter_top* - топовый файл
---
Отчет о синтезе :
![ ](/doc/3.png)

Предельная частота на данном кристалле  383,73 Мгц
![ ](/doc/4.png)

 - критическое время удержания не вышло за пределы *слэка* ![ ](/doc/5.png)
 - критическое время установки вышло ![ ](/doc/6.png)
 - критический путь ![ ](/doc/7.png)
 -  ![ RTL модель критического пути ](/doc/8.png)
Критический путь состоит в основном из логики двух входовых мультиплексоров, если убавить количество элементов if в коде логики выбора приоритетного потока.
---
 - Код проекта находится в папке *RTL*
 - Тестбенч модуля находится в папке *tb* 
 - Скрипт для запуска симуляции проекта находится в папке sim\modelsim\make_file.bat
 - Скрипт для запуска синтеза проекта находится в папке syn\Quartus\make_analyz.bat
 - Для открытия проекта запустить Quartus, запустить скрипт в папке syn\Quartus\make_analyz.bat. Открыть проект в папке syn\Quartus\stream_arbiter_top.qpf

P.S. Можно реализовать выбор приоритетного потока комбинационной логикой, без задержки потока на один такт после каждой транзакции.
**Не уверен что правильного реализовал алгоритм Round-Robin** 
