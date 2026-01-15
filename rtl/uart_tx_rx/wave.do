onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {SYSTEM GLOBALS}
add wave -noupdate -color Cyan /Tx_Rx_Wrapper_tb/DUT/TX_CLK
add wave -noupdate -color Cyan /Tx_Rx_Wrapper_tb/DUT/RX_CLK
add wave -noupdate -color Cyan /Tx_Rx_Wrapper_tb/DUT/RSTn
add wave -noupdate -divider CONFIGURATION
add wave -noupdate -color White -radix unsigned /Tx_Rx_Wrapper_tb/DUT/Prescale
add wave -noupdate -color Yellow /Tx_Rx_Wrapper_tb/DUT/PAR_EN
add wave -noupdate -color Yellow /Tx_Rx_Wrapper_tb/DUT/PAR_TYP
add wave -noupdate -divider {SERIAL LINE}
add wave -noupdate -color Orange /Tx_Rx_Wrapper_tb/DUT/w_serial_line
add wave -noupdate -divider {TRANSMITTER INTERFACE}
add wave -noupdate -color Green -radix hexadecimal /Tx_Rx_Wrapper_tb/DUT/TX_P_DATA
add wave -noupdate -color Green /Tx_Rx_Wrapper_tb/DUT/TX_DATA_VALID
add wave -noupdate -color Red /Tx_Rx_Wrapper_tb/DUT/TX_BUSY
add wave -noupdate -divider {RECEIVER INTERFACE}
add wave -noupdate -color Green -radix hexadecimal /Tx_Rx_Wrapper_tb/DUT/RX_P_DATA
add wave -noupdate -color Green /Tx_Rx_Wrapper_tb/DUT/RX_DATA_VALID
add wave -noupdate -color Red /Tx_Rx_Wrapper_tb/DUT/RX_PARITY_ERR
add wave -noupdate -color Red /Tx_Rx_Wrapper_tb/DUT/RX_FRAMING_ERR
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/strt_glitch
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/bit_cnt
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/sampled_bit
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/stp_chk_en
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/stp_err
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/edge_cnt
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/par_chk_en
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/enable_cnt
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/par_err
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/strt_chk_en
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/data_samp_en
add wave -noupdate -group u_RX /Tx_Rx_Wrapper_tb/DUT/u_RX/deser_en
add wave -noupdate -group u_TX /Tx_Rx_Wrapper_tb/DUT/u_TX/mux_in_data
add wave -noupdate -group u_TX /Tx_Rx_Wrapper_tb/DUT/u_TX/mux_in_stop
add wave -noupdate -group u_TX /Tx_Rx_Wrapper_tb/DUT/u_TX/mux_in_start
add wave -noupdate -group u_TX /Tx_Rx_Wrapper_tb/DUT/u_TX/mux_out
add wave -noupdate -group u_TX /Tx_Rx_Wrapper_tb/DUT/u_TX/par_bit
add wave -noupdate -group u_TX /Tx_Rx_Wrapper_tb/DUT/u_TX/mux_sel
add wave -noupdate -group u_TX /Tx_Rx_Wrapper_tb/DUT/u_TX/latch_en
add wave -noupdate -group u_TX /Tx_Rx_Wrapper_tb/DUT/u_TX/ser_done
add wave -noupdate -group u_TX /Tx_Rx_Wrapper_tb/DUT/u_TX/ser_data
add wave -noupdate -group u_TX /Tx_Rx_Wrapper_tb/DUT/u_TX/mux_in_parity
add wave -noupdate -group u_TX /Tx_Rx_Wrapper_tb/DUT/u_TX/ser_en
add wave -noupdate /Tx_Rx_Wrapper_tb/DUT/u_RX/u_strt_check/i_clk
add wave -noupdate /Tx_Rx_Wrapper_tb/DUT/u_RX/u_strt_check/i_resetn
add wave -noupdate /Tx_Rx_Wrapper_tb/DUT/u_RX/u_strt_check/i_strt_chk_en
add wave -noupdate /Tx_Rx_Wrapper_tb/DUT/u_RX/u_strt_check/i_sampled_bit
add wave -noupdate /Tx_Rx_Wrapper_tb/DUT/u_RX/u_strt_check/o_strt_glitch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {512837935 ps}
