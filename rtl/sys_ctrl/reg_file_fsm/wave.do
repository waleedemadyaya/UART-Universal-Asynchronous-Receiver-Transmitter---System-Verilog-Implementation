onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /reg_file_fsm_tb/DUT/ADDRESS_WIDTH
add wave -noupdate /reg_file_fsm_tb/DUT/next_state
add wave -noupdate /reg_file_fsm_tb/DUT/data_synchronizer_valid
add wave -noupdate /reg_file_fsm_tb/DUT/i_alu_fetch_en
add wave -noupdate /reg_file_fsm_tb/DUT/i_clk
add wave -noupdate /reg_file_fsm_tb/DUT/i_reg_start
add wave -noupdate /reg_file_fsm_tb/DUT/i_RSTn
add wave -noupdate /reg_file_fsm_tb/DUT/i_rw_en
add wave -noupdate /reg_file_fsm_tb/DUT/synch_data
add wave -noupdate /reg_file_fsm_tb/DUT/curr_state
add wave -noupdate /reg_file_fsm_tb/DUT/o_Addr
add wave -noupdate /reg_file_fsm_tb/DUT/o_Wr_D
add wave -noupdate /reg_file_fsm_tb/DUT/o_WrEn
add wave -noupdate /reg_file_fsm_tb/DUT/o_RdEn
add wave -noupdate /reg_file_fsm_tb/DUT/o_reg_done
add wave -noupdate /reg_file_fsm_tb/DUT/WRDATA_WIDTH
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {255000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {383250 ps}
