# ============================================================================
# Project: Final System Integration - Stable Nested Hierarchy
# Engineer: IC / Automation Engineer
# ============================================================================

.main clear

# 1. Compilation (Unchanged)
vlib work
vmap work work

vlog -sv SYS_PACKAGE.sv
vlog -sv ../uart_tx_rx/*.sv
vlog -sv ../puls_gen/puls_gen.sv
vlog -sv ../reset_synch/reset_synch.sv
vlog -sv ../reg_file/reg_file.sv
vlog -sv ../alu/ALU.sv
vlog -sv ../data_synch/data_sync.sv
vlog -sv ../clock_gating/clock_gating.sv
vlog -sv ../clock_divider/clk_div.sv
vlog -sv ../asynch_fifo/*.sv
vlog -sv ../sys_ctrl/reg_file_fsm/reg_file_fsm.sv
vlog -sv ../sys_ctrl/alu_fsm/alu_fsm.sv
vlog -sv ../sys_ctrl/top_fsm/top_fsm.sv
vlog -sv ../sys_ctrl/sys_controller.sv
vlog -sv top_sys.sv
vlog -sv SYS_TOP_TB.sv

# 2. Start Simulation
vsim -voptargs=+acc work.SYS_TOP_TBBBB 

# 3. Waveform Organization
radix -hexadecimal

# --- Group 1: TESTBENCH ---
add wave -group "TB" -color "SpringGreen" /SYS_TOP_TBBBB/REF_CLK
add wave -group "TB" -color "SpringGreen" /SYS_TOP_TBBBB/UART_CLK
add wave -group "TB" -color "Yellow"      /SYS_TOP_TBBBB/RST_N
add wave -group "TB" -color "Orange"      /SYS_TOP_TBBBB/UART_RX_IN
add wave -group "TB" -color "Cyan"        /SYS_TOP_TBBBB/*

# --- Group 2: SYSTEM CONTROLLER (Hierarchical) ---
# Professional Tip: We create the groups by path directly to avoid "No objects found"
add wave -group "SYS_CTRL_TOP" /SYS_TOP_TBBBB/DUT/u_sys_ctrl/*
add wave -group "SYS_CTRL_TOP" -group "FSM_TOP" /SYS_TOP_TBBBB/DUT/u_sys_ctrl/U_top_fsm/*
add wave -group "SYS_CTRL_TOP" -group "FSM_ALU" /SYS_TOP_TBBBB/DUT/u_sys_ctrl/U_alu_fsm/*
add wave -group "SYS_CTRL_TOP" -group "FSM_REG" /SYS_TOP_TBBBB/DUT/u_sys_ctrl/U_reg_file_fsm/*

# --- Group 3: REGISTER FILE & ALU ---
add wave -group "REG_FILE" /SYS_TOP_TBBBB/DUT/U0_RegFile/*
add wave -group "ALU"      /SYS_TOP_TBBBB/DUT/u_alu/*

# --- Group 4: UART RECEIVER (Deep Hierarchy) ---
add wave -group "UART_RX_TOP" /SYS_TOP_TBBBB/DUT/u_uart_rx/*
add wave -group "UART_RX_TOP" -group "RX_FSM"        /SYS_TOP_TBBBB/DUT/u_uart_rx/u_fsm/*
add wave -group "UART_RX_TOP" -group "RX_SAMPLING"   /SYS_TOP_TBBBB/DUT/u_uart_rx/u_data_sampling/*
add wave -group "UART_RX_TOP" -group "RX_COUNTER"    /SYS_TOP_TBBBB/DUT/u_uart_rx/u_edge_bit_counter/*
add wave -group "UART_RX_TOP" -group "RX_DESERIAL"   /SYS_TOP_TBBBB/DUT/u_uart_rx/u_deserializer/*
add wave -group "UART_RX_TOP" -group "Parity_Checker" /SYS_TOP_TBBBB/DUT/u_uart_rx/u_parity_check/*
add wave -group "UART_RX_TOP" -group "Start_Checker"  /SYS_TOP_TBBBB/DUT/u_uart_rx/u_strt_check/*
add wave -group "UART_RX_TOP" -group "Stop_Checker"   /SYS_TOP_TBBBB/DUT/u_uart_rx/u_stop_check/*

# --- Group 5: ASYNC FIFO (Hierarchy) ---
add wave -group "FIFO_TOP"      /SYS_TOP_TBBBB/DUT/u_async_fifo/*
add wave -group "FIFO_TOP" -group "FIFO_MEM"      /SYS_TOP_TBBBB/DUT/u_async_fifo/fifomem/*
add wave -group "FIFO_TOP" -group "FIFO_SYNC_W2R" /SYS_TOP_TBBBB/DUT/u_async_fifo/sync_w2r/*
add wave -group "FIFO_TOP" -group "FIFO_SYNC_R2W" /SYS_TOP_TBBBB/DUT/u_async_fifo/sync_r2w/*
add wave -group "FIFO_TOP" -group "Empty" /SYS_TOP_TBBBB/DUT/u_async_fifo/rptr_empty/*
add wave -group "FIFO_TOP" -group "Full" /SYS_TOP_TBBBB/DUT/u_async_fifo/wptr_full/*

# --- Group 6: UART TRANSMITTER (Deep Hierarchy) ---
add wave -group "UART_TX_TOP"        /SYS_TOP_TBBBB/DUT/u_uart_tx/*
add wave -group "UART_TX_TOP" -group "TX_FSM"             /SYS_TOP_TBBBB/DUT/u_uart_tx/u_FSM/*
add wave -group "UART_TX_TOP" -group "TX_SERIAL"          /SYS_TOP_TBBBB/DUT/u_uart_tx/u_serializer/*
add wave -group "UART_TX_TOP" -group "Parity_Calculator"  /SYS_TOP_TBBBB/DUT/u_uart_tx/u_parity_calc/*
add wave -group "UART_TX_TOP" -group "Output_Mux"         /SYS_TOP_TBBBB/DUT/u_uart_tx/u_output_mux/*

# --- Group 7: INFRASTRUCTURE ---
add wave -group "Data_Sych" /SYS_TOP_TBBBB/DUT/u_data_sync/*
add wave -group "Clk_Divider_TX" /SYS_TOP_TBBBB/DUT/u_clk_divider_tx/*
add wave -group "Clk_Divider_RX" /SYS_TOP_TBBBB/DUT/u_clk_divider_rx/*
add wave -group "Clk_Gating" /SYS_TOP_TBBBB/DUT/u_clock_gate/*
add wave -group "Pulse_Generator" /SYS_TOP_TBBBB/DUT/u_pulse_gen/*

# 4. Simulation Control
run -all
wave zoom full