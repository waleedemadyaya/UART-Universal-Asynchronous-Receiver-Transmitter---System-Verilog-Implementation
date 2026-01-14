onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TOP LEVEL PORTS}
add wave -noupdate -color Cyan /UART_RX_TB/DUT/CLK
add wave -noupdate -color Cyan /UART_RX_TB/DUT/RSTn
add wave -noupdate -color Yellow /UART_RX_TB/DUT/RX_IN
add wave -noupdate -color White /UART_RX_TB/DUT/Prescale
add wave -noupdate -color Green -radix hexadecimal /UART_RX_TB/DUT/P_DATA
add wave -noupdate -color Green /UART_RX_TB/DUT/data_valid
add wave -noupdate -color Red /UART_RX_TB/DUT/parity_error
add wave -noupdate -color Red /UART_RX_TB/DUT/framing_error
add wave -noupdate -divider {INTERNAL BLOCKS}
add wave -noupdate -group u_stop_check /UART_RX_TB/DUT/u_stop_check/i_stp_chk_en
add wave -noupdate -group u_stop_check /UART_RX_TB/DUT/u_stop_check/i_clk
add wave -noupdate -group u_stop_check /UART_RX_TB/DUT/u_stop_check/i_sampled_bit
add wave -noupdate -group u_stop_check /UART_RX_TB/DUT/u_stop_check/o_stp_err
add wave -noupdate -group u_stop_check /UART_RX_TB/DUT/u_stop_check/i_resetn
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/o_deser_en
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/i_bit_cnt
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/o_enable
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/i_PAR_EN
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/i_Prescale
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/i_stp_err
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/i_RX_IN
add wave -noupdate -expand -group u_fsm -radix decimal /UART_RX_TB/DUT/u_fsm/i_edge_cnt
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/i_clk
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/o_data_sample_en
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/i_par_err
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/o_stp_chk_en
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/next_state
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/crnt_state
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/o_data_valid
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/i_strt_glitch
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/o_par_chk_en
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/i_resetn
add wave -noupdate -expand -group u_fsm /UART_RX_TB/DUT/u_fsm/o_strt_chk_en
add wave -noupdate -group u_strt_check /UART_RX_TB/DUT/u_strt_check/i_sampled_bit
add wave -noupdate -group u_strt_check /UART_RX_TB/DUT/u_strt_check/i_strt_chk_en
add wave -noupdate -group u_strt_check /UART_RX_TB/DUT/u_strt_check/o_strt_glitch
add wave -noupdate -group u_strt_check /UART_RX_TB/DUT/u_strt_check/i_resetn
add wave -noupdate -group u_strt_check /UART_RX_TB/DUT/u_strt_check/i_clk
add wave -noupdate -group u_parity_check /UART_RX_TB/DUT/u_parity_check/i_par_typ
add wave -noupdate -group u_parity_check /UART_RX_TB/DUT/u_parity_check/r_parity_acc
add wave -noupdate -group u_parity_check /UART_RX_TB/DUT/u_parity_check/i_sampled_bit
add wave -noupdate -group u_parity_check /UART_RX_TB/DUT/u_parity_check/o_par_err
add wave -noupdate -group u_parity_check /UART_RX_TB/DUT/u_parity_check/i_resetn
add wave -noupdate -group u_parity_check /UART_RX_TB/DUT/u_parity_check/i_stp_chk_en
add wave -noupdate -group u_parity_check /UART_RX_TB/DUT/u_parity_check/i_par_chk_en
add wave -noupdate -group u_parity_check /UART_RX_TB/DUT/u_parity_check/i_clk
add wave -noupdate -group u_edge_bit_counter /UART_RX_TB/DUT/u_edge_bit_counter/o_edge_cnt
add wave -noupdate -group u_edge_bit_counter /UART_RX_TB/DUT/u_edge_bit_counter/i_prescale
add wave -noupdate -group u_edge_bit_counter /UART_RX_TB/DUT/u_edge_bit_counter/i_enable
add wave -noupdate -group u_edge_bit_counter /UART_RX_TB/DUT/u_edge_bit_counter/o_bit_cnt
add wave -noupdate -group u_edge_bit_counter /UART_RX_TB/DUT/u_edge_bit_counter/i_PAR_EN
add wave -noupdate -group u_edge_bit_counter /UART_RX_TB/DUT/u_edge_bit_counter/i_resetn
add wave -noupdate -group u_edge_bit_counter /UART_RX_TB/DUT/u_edge_bit_counter/i_clk
add wave -noupdate -group u_data_sampling /UART_RX_TB/DUT/u_data_sampling/i_edge_cnt
add wave -noupdate -group u_data_sampling /UART_RX_TB/DUT/u_data_sampling/i_resetn
add wave -noupdate -group u_data_sampling /UART_RX_TB/DUT/u_data_sampling/o_sampled_bit
add wave -noupdate -group u_data_sampling /UART_RX_TB/DUT/u_data_sampling/i_clk
add wave -noupdate -group u_data_sampling /UART_RX_TB/DUT/u_data_sampling/i_prescale
add wave -noupdate -group u_data_sampling /UART_RX_TB/DUT/u_data_sampling/r_sampled_bits
add wave -noupdate -group u_data_sampling /UART_RX_TB/DUT/u_data_sampling/i_RX_IN
add wave -noupdate -group u_data_sampling /UART_RX_TB/DUT/u_data_sampling/i_data_samp_en
add wave -noupdate -group u_deserializer /UART_RX_TB/DUT/u_deserializer/i_clk
add wave -noupdate -group u_deserializer /UART_RX_TB/DUT/u_deserializer/r_p_data_reg
add wave -noupdate -group u_deserializer /UART_RX_TB/DUT/u_deserializer/o_P_DATA
add wave -noupdate -group u_deserializer /UART_RX_TB/DUT/u_deserializer/i_sampled_bit
add wave -noupdate -group u_deserializer /UART_RX_TB/DUT/u_deserializer/i_deser_en
add wave -noupdate -group u_deserializer /UART_RX_TB/DUT/u_deserializer/i_resetn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {126344 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 250
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
WaveRestoreZoom {119527 ps} {126718 ps}
