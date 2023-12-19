action = "simulation"
sim_tool = "modelsim"
sim_top = "tb_stream_arbiter"

sim_post_cmd = "vsim -voptargs=+acc -do wave.do -i tb_stream_arbiter"

modules = {
  "local" : [ "../../tb" ],
}
