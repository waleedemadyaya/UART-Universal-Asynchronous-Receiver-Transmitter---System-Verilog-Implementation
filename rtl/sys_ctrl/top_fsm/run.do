# --- 1. CLEANUP & ENVIRONMENT ---
# Stop current simulation
quit -sim

# Check if wave window is open, then clear all signals using the '*' wildcard
if {[string first ".wave" [view]] != -1} {
    delete wave *
}

# --- 2. COMPILATION ---
# Create work library
vlib work

# Compile ONLY the Top FSM and its Testbench (Assuming sub-modules are already in 'work')
vlog top_fsm.sv 
vlog top_fsm_tb.sv

# --- 3. START SIMULATION ---
# +acc gives visibility to internal signals/registers for debugging
vsim -voptargs="+acc" work.top_fsm_tb

# --- 4. WAVEFORM SETUP ---
# System Signals
add wave -noupdate -divider "SYSTEM"
add wave -noupdate -color "Yellow"         /top_fsm_tb/i_clk
add wave -noupdate -color "Red"            /top_fsm_tb/i_RSTn

# Input from UART
add wave -noupdate -divider "UART INPUT"
add wave -noupdate -color "Cyan"           /top_fsm_tb/data_synchronizer_valid
add wave -noupdate -radix hexadecimal      /top_fsm_tb/synch_data

# Top FSM Internal Logic
add wave -noupdate -divider "TOP FSM"
add wave -noupdate -color "Orange"         /top_fsm_tb/DUT/curr_state
add wave -noupdate -radix hexadecimal      /top_fsm_tb/DUT/r_command

# Handshakes with sub-modules (ALU and RegFile)
add wave -noupdate -divider "HANDSHAKES"
add wave -noupdate -group "ALU_IF"         /top_fsm_tb/o_alu_start /top_fsm_tb/i_alu_done
add wave -noupdate -group "REG_IF"         /top_fsm_tb/o_reg_start /top_fsm_tb/i_reg_done

# Output Result Path
add wave -noupdate -divider "OUTPUT"
add wave -noupdate -color "Green"          /top_fsm_tb/o_WR_INC
add wave -noupdate -radix hexadecimal      /top_fsm_tb/o_WR_DATA

# --- 5. EXECUTION ---
run -all
wave zoom full