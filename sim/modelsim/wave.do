onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_stream_arbiter/clk_i
add wave -noupdate /tb_stream_arbiter/rst_n
add wave -noupdate /tb_stream_arbiter/s_last_i
add wave -noupdate /tb_stream_arbiter/s_valid_i
add wave -noupdate /tb_stream_arbiter/s_ready_o
add wave -noupdate /tb_stream_arbiter/m_data_o
add wave -noupdate -radix unsigned /tb_stream_arbiter/m_qos_o
add wave -noupdate /tb_stream_arbiter/m_id_o
add wave -noupdate /tb_stream_arbiter/m_last_o
add wave -noupdate /tb_stream_arbiter/m_valid_o
add wave -noupdate /tb_stream_arbiter/m_ready_i
add wave -noupdate -radix unsigned /tb_stream_arbiter/data_1
add wave -noupdate -radix unsigned /tb_stream_arbiter/data_2
add wave -noupdate -radix unsigned /tb_stream_arbiter/qos_1
add wave -noupdate -radix unsigned /tb_stream_arbiter/qos_2
add wave -noupdate /tb_stream_arbiter/wait_clk/i
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/clk_i
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/rst_n
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/s_last_i
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/s_valid_i
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/s_ready_o
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/m_data_o
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/m_qos_o
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/m_id_o
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/m_last_o
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/m_valid_o
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/m_ready_i
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/select_stream_reg
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/cnt_rr
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/rr_reg
add wave -noupdate /tb_stream_arbiter/genblk1/uut_stream_arbiter/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {328 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 370
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {262 ps} {414 ps}
