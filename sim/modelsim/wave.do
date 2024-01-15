onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_stream_arbiter/clk_i
add wave -noupdate /tb_stream_arbiter/rst_n
add wave -noupdate /tb_stream_arbiter/s_last_i
add wave -noupdate /tb_stream_arbiter/s_valid_i
add wave -noupdate /tb_stream_arbiter/s_ready_o
add wave -noupdate -radix unsigned /tb_stream_arbiter/m_data_o
add wave -noupdate -radix unsigned /tb_stream_arbiter/m_qos_o
add wave -noupdate -radix unsigned /tb_stream_arbiter/m_id_o
add wave -noupdate /tb_stream_arbiter/m_last_o
add wave -noupdate /tb_stream_arbiter/m_valid_o
add wave -noupdate /tb_stream_arbiter/m_ready_i
add wave -noupdate -radix unsigned /tb_stream_arbiter/data_1
add wave -noupdate -radix unsigned /tb_stream_arbiter/data_2
add wave -noupdate -radix unsigned /tb_stream_arbiter/data_3
add wave -noupdate -radix unsigned /tb_stream_arbiter/data_4
add wave -noupdate -radix unsigned /tb_stream_arbiter/qos_1
add wave -noupdate -radix unsigned /tb_stream_arbiter/qos_2
add wave -noupdate -radix unsigned /tb_stream_arbiter/qos_3
add wave -noupdate -radix unsigned /tb_stream_arbiter/qos_4
add wave -noupdate /tb_stream_arbiter/wait_clk/i
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/clk_i
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/rst_n
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/s_last_i
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/s_valid_i
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/s_ready_o
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/m_data_o
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/m_qos_o
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/m_id_o
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/m_last_o
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/m_valid_o
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/m_ready_i
add wave -noupdate -radix unsigned /tb_stream_arbiter/uut_stream_arbiter/select_stream_reg
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/cnt_rr
add wave -noupdate -radix unsigned -childformat {{{/tb_stream_arbiter/uut_stream_arbiter/rr_reg[1]} -radix unsigned} {{/tb_stream_arbiter/uut_stream_arbiter/rr_reg[0]} -radix unsigned}} -expand -subitemconfig {{/tb_stream_arbiter/uut_stream_arbiter/rr_reg[1]} {-height 15 -radix unsigned} {/tb_stream_arbiter/uut_stream_arbiter/rr_reg[0]} {-height 15 -radix unsigned}} /tb_stream_arbiter/uut_stream_arbiter/rr_reg
add wave -noupdate -radix unsigned /tb_stream_arbiter/uut_stream_arbiter/select_qos_reg
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/same_priorities_reg
add wave -noupdate -radix unsigned /tb_stream_arbiter/uut_stream_arbiter/quantity_one_prior
add wave -noupdate /tb_stream_arbiter/uut_stream_arbiter/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {304 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 383
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
WaveRestoreZoom {221 ps} {403 ps}
