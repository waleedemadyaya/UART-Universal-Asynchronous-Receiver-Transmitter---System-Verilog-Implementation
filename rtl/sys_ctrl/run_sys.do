# --- 1. CLEANUP ---
quit -sim
if {[file exists work]} { vdel -lib work -all }
vlib work

# --- 2. COMPILATION ---
# Compiling modules from their respective sub-folders
vlog ./alu_fsm/alu_fsm.sv
vlog ./reg_file_fsm/reg_file_fsm.sv
vlog ./top_fsm/top_fsm.sv
vlog ./sys_controller.sv
vlog ./sys_controller_tb.sv

# --- 3. START SIMULATION ---
# +acc ensures internal FSM states are visible in the waveform
vsim -voptargs="+acc" work.SYS_CTRL_tb

# --- 4. WAVEFORM SETUP ---
# Clear old waves
if {[string first ".wave" [view]] != -1} { delete wave * }

# Category: TOP LEVEL INTERFACE
add wave -noupdate -divider "TOP INTERFACE"
add wave -noupdate -color "Yellow"         /SYS_CTRL_tb/i_clk
add wave -noupdate -color "Red"            /SYS_CTRL_tb/i_RSTn
add wave -noupdate -color "Cyan"           /SYS_CTRL_tb/data_synchronizer_valid
add wave -noupdate -radix hexadecimal      /SYS_CTRL_tb/synch_data

# Category: TOP FSM (THE BRAIN)
add wave -noupdate -divider "TOP FSM"
add wave -noupdate -color "Orange"         /SYS_CTRL_tb/DUT/U_top_fsm/curr_state
add wave -noupdate -radix hexadecimal      /SYS_CTRL_tb/DUT/U_top_fsm/r_command

# Category: ALU SUB-SYSTEM
add wave -noupdate -divider "ALU SYSTEM"
add wave -noupdate -group "ALU_INTERNAL"   /SYS_CTRL_tb/DUT/U_alu_fsm/curr_state
add wave -noupdate -group "ALU_INTERNAL"   /SYS_CTRL_tb/DUT/U_alu_fsm/o_EN
add wave -noupdate -radix hexadecimal      /SYS_CTRL_tb/DUT/U_alu_fsm/o_ALU_OUT

# Category: REGISTER FILE SUB-SYSTEM
add wave -noupdate -divider "REG_FILE SYSTEM"
add wave -noupdate -group "RF_INTERNAL"    /SYS_CTRL_tb/DUT/U_reg_file_fsm/curr_state
add wave -noupdate -group "RF_INTERNAL"    /SYS_CTRL_tb/DUT/U_reg_file_fsm/o_WrEn
add wave -noupdate -group "RF_INTERNAL"    /SYS_CTRL_tb/DUT/U_reg_file_fsm/o_RdEn
add wave -noupdate -radix hexadecimal      /SYS_CTRL_tb/DUT/U_reg_file_fsm/o_Addr
add wave -noupdate -radix hexadecimal      /SYS_CTRL_tb/DUT/U_reg_file_fsm/o_Wr_D

# Category: OUTPUT (TX)
add wave -noupdate -divider "TX OUTPUT"
add wave -noupdate -color "Green"          /SYS_CTRL_tb/o_TX_WR_INC
add wave -noupdate -radix hexadecimal      /SYS_CTRL_tb/o_TX_DATA

# --- 5. EXECUTION ---
run 100000
wave zoom full

