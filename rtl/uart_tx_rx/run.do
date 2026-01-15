# ==============================================================================
# Script: run.do
# ==============================================================================
.main clear

# 1. Clean and Compile
if [file exists work] { vdel -all }
vlib work

# Compile Package first, then everything else
vlog UART_PACKAGE.sv
vlog *.sv

# 2. Start Simulation
# Use +acc to preserve signal names for the wave window
vsim -voptargs="+acc" work.Tx_Rx_Wrapper_tb

# 3. Professional Waveform Organization
# ------------------------------------------------------------------------------
add wave -noupdate -divider "SYSTEM GLOBALS"
add wave -noupdate -color Cyan      /Tx_Rx_Wrapper_tb/DUT/TX_CLK
add wave -noupdate -color Cyan      /Tx_Rx_Wrapper_tb/DUT/RX_CLK
add wave -noupdate -color Cyan      /Tx_Rx_Wrapper_tb/DUT/RSTn

add wave -noupdate -divider "CONFIGURATION"
add wave -noupdate -color White     -radix unsigned /Tx_Rx_Wrapper_tb/DUT/Prescale
add wave -noupdate -color Yellow    /Tx_Rx_Wrapper_tb/DUT/PAR_EN
add wave -noupdate -color Yellow    /Tx_Rx_Wrapper_tb/DUT/PAR_TYP

add wave -noupdate -divider "SERIAL LINE"
add wave -noupdate -color Orange    /Tx_Rx_Wrapper_tb/DUT/w_serial_line

add wave -noupdate -divider "TRANSMITTER INTERFACE"
add wave -noupdate -color Green     -radix hex /Tx_Rx_Wrapper_tb/DUT/TX_P_DATA
add wave -noupdate -color Green     /Tx_Rx_Wrapper_tb/DUT/TX_DATA_VALID
add wave -noupdate -color Red       /Tx_Rx_Wrapper_tb/DUT/TX_BUSY

add wave -noupdate -divider "RECEIVER INTERFACE"
add wave -noupdate -color Green     -radix hex /Tx_Rx_Wrapper_tb/DUT/RX_P_DATA
add wave -noupdate -color Green     /Tx_Rx_Wrapper_tb/DUT/RX_DATA_VALID
add wave -noupdate -color Red       /Tx_Rx_Wrapper_tb/DUT/RX_PARITY_ERR
add wave -noupdate -color Red       /Tx_Rx_Wrapper_tb/DUT/RX_FRAMING_ERR

# 4. Automated Internal Logic Grouping
# ------------------------------------------------------------------------------
# This loop finds sub-modules (FSMs, Deserializer, etc.) and groups them
set sub_instances [find instances /Tx_Rx_Wrapper_tb/DUT/*]

foreach inst $sub_instances {
    set clean_inst [lindex [split $inst " "] 0]
    set group_name [file tail $clean_inst]
    set sigs [find signals -internal $clean_inst/*]
    
    if { [llength $sigs] > 0 } {
        add wave -noupdate -group "$group_name" {*}$sigs
    }
}

# 5. Simulation Setup
configure wave -signalnamewidth 1
configure wave -namecolwidth 250
run -all
wave zoom full