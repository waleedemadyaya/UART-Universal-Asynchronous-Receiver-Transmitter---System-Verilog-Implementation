# ==============================================================================
# Script: run.do
# ==============================================================================

# 1. Reset Environment
if [file exists work] { vdel -all }
vlib work

# 2. Compilation
vlog UART_PACKAGE.sv
vlog FSM.sv
vlog data_sampling.sv
vlog edge_bit_counter.sv
vlog parity_check.sv
vlog start_check.sv
vlog stop_check.sv
vlog deserializer.sv
vlog UART.sv
vlog UART_RX_TB.sv

# 3. Simulation with Full Visibility
# +acc=npr allows access to nets, ports, and registers
vsim -voptargs="+acc=npr" work.UART_RX_TB

# 4. Standard Waveform Setup
add wave -noupdate -divider "TOP LEVEL PORTS"
add wave -noupdate -color Cyan /UART_RX_TB/DUT/CLK
add wave -noupdate -color Cyan /UART_RX_TB/DUT/RSTn
add wave -noupdate -color Yellow /UART_RX_TB/DUT/RX_IN
add wave -noupdate -color White /UART_RX_TB/DUT/Prescale
add wave -noupdate -color Green -radix hex /UART_RX_TB/DUT/P_DATA
add wave -noupdate -color Green /UART_RX_TB/DUT/data_valid
add wave -noupdate -color Red /UART_RX_TB/DUT/parity_error
add wave -noupdate -color Red /UART_RX_TB/DUT/framing_error

# ==============================================================================
# Section 5: Advanced Recursive Grouping (Fixed for List Expansion)
# ==============================================================================
add wave -noupdate -divider "INTERNAL BLOCKS"

# Find only the direct children instances of the DUT
set sub_instances [find instances /UART_RX_TB/DUT/*]

foreach inst $sub_instances {
    # Clean the path: Strips out "(module_name)" if present
    set clean_inst [lindex [split $inst " "] 0]
    set group_name [file tail $clean_inst]
    
    # Find all signals (ports and internal nets)
    set sigs [find signals $clean_inst/*]
    
    # Use {*} to expand the list into individual arguments for add wave
    if { [llength $sigs] > 0 } {
        add wave -noupdate -group "$group_name" {*}$sigs
    }
}

# 6. Final UI Adjustments
configure wave -signalnamewidth 1
configure wave -namecolwidth 250
run 1000000
wave zoom full