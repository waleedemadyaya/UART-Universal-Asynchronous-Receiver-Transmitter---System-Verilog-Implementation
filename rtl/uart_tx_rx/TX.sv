`timescale 1ns/1ps

// ============================================
// Package Import (Assuming UART_PACKAGE exists)
// ============================================
import UART_PACKAGE::*;

module UART_TX (
    // ============================================
    // Clock & Reset (Primary Interface)
    // ============================================
    input  logic       i_clk,           // 200 MHz clock
    input  logic       i_rst_n,         // Active-low asynchronous reset
    
    // ============================================
    // Configuration Signals
    // ============================================
    input  logic       i_PAR_EN,        // Parity enable (0: disable, 1: enable)
    input  logic       i_PAR_TYP,       // Parity type (0: even, 1: odd)
    
    // ============================================
    // Data Interface
    // ============================================
    input  logic [7:0] i_P_DATA,        // Parallel input data (8-bit)
    input  logic       i_DATA_VALID,    // Data valid pulse (1 cycle)
    
    // ============================================
    // Status & Output
    // ============================================
    output logic       o_TX_OUT,        // Serial data output
    output logic       o_BUSY           // Busy signal during transmission
);



// ============================================
// Internal Signals
// ============================================
logic       ser_en;          // Serializer enable
logic       latch_en;        // Serializer latch enable
logic [1:0] mux_sel;         // Mux select for FSM
logic       ser_data;        // Serialized data output
logic       ser_done;        // Serializer done flag
logic       par_bit;         // Calculated parity bit
logic       mux_out;         // Mux output before TX_OUT


// ============================================
// Mux Inputs Definition
// ============================================
logic mux_in_start;   // Start bit (always 0)
logic mux_in_stop;    // Stop bit/Idle (always 1)
logic mux_in_data;    // Data from serializer
logic mux_in_parity;  // Parity bit from parity calculator

assign mux_in_start = 1'b0;   // Start bit = 0
assign mux_in_stop = 1'b1;    // Stop/Idle = 1
assign mux_in_data = ser_data; // Data from serializer
assign mux_in_parity = par_bit; // Parity from calculator

// ============================================
// Instantiate FSM Controller
// ============================================
FSM_controller u_FSM (
    .i_clk(i_clk),
    .i_resetn(i_rst_n),
    .i_Data_Valid(i_DATA_VALID),
    .i_PAR_EN(i_PAR_EN),
    .i_ser_done(ser_done),
    .o_ser_en(ser_en),
    .o_latch_en(latch_en),
    .o_mux_sel(mux_sel),
    .o_busy(o_BUSY)
);

// ============================================
// Instantiate Serializer (8-bit)
// ============================================
serializer u_serializer (
    .i_clk(i_clk),
    .i_resetn(i_rst_n),
    .i_P_DATA(i_P_DATA),
    .i_ser_en(ser_en),
    .i_latche_en(latch_en),
    .o_ser_data(ser_data),
    .o_ser_done(ser_done)
);

// ============================================
// Instantiate Parity Calculator
// ============================================
parity_calc u_parity_calc (
    .P_DATA(i_P_DATA),
    .Data_Valid(latch_en),      // Calculate parity when data is latched
    .PAR_TYP(i_PAR_TYP),
    .par_bit(par_bit)
);

// ============================================
// Instantiate Output Mux
// ============================================
mux_4_1 u_output_mux (
    .i_1(mux_in_start),      // Start bit (0)
    .i_2(mux_in_stop),       // Stop/Idle bit (1)
    .i_3(mux_in_data),       // Serial data
    .i_4(mux_in_parity),     // Parity bit
    .sel(mux_sel),   // 2-bit select from FSM
    .o(mux_out)              // Mux output
);

// ============================================
// Output Register (Optional for timing)
// ============================================
//always_ff @(posedge i_clk or negedge i_rst_n) begin : output_register
//    if (!i_rst_n) begin
//        o_TX_OUT <= 1'b1;    // Idle state = high
//    end else begin
//        o_TX_OUT <= mux_out;
//    end
//end

// ============================================
// Optional: Output without register for combinational path
// ============================================
 assign o_TX_OUT = mux_out;  // Use this for unregistered output


endmodule