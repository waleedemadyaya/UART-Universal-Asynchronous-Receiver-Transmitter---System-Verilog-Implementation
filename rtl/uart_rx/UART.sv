`include "UART_PACKAGE.sv"
import UART_PACKAGE::*;

module UART_RX (
    input  logic                     CLK,
    input  logic                     RSTn,
    input  logic                     RX_IN,
    input  logic [PRESCALE_WIDTH-1:0] Prescale,
    input  logic                     PAR_EN,
    input  logic                     PAR_TYP,
    output logic [DATA_WIDTH-1:0]    P_DATA,
    output logic                     data_valid,
    output logic                     parity_error,
    output logic                     framing_error
);

    // --- Internal Wires (Interconnects) ---
    
    // FSM Outputs -> Inputs of other blocks
    logic par_chk_en;
    logic strt_chk_en;
    logic stp_chk_en;
    logic deser_en;
    logic enable_cnt;
    logic data_samp_en;

    // Checker Outputs -> FSM Inputs
    logic par_err;
    logic strt_glitch;
    logic stp_err;

    // Counter Outputs -> FSM & Data Sampling
    logic [$clog2(DATA_WIDTH+3)-1:0] bit_cnt;
    logic [PRESCALE_WIDTH-1:0]       edge_cnt;

    // Data Sampling Output -> Deserializer & Checkers
    logic sampled_bit;


    assign parity_error = par_err;
    assign framing_error = stp_err | par_err;

    // --- Module Instantiations ---

    // 1. FSM Controller
    fsm_controller u_fsm (
        .i_clk(CLK),
        .i_resetn(RSTn),
        .i_RX_IN(RX_IN),
        .i_Prescale(Prescale),
        .i_PAR_EN(PAR_EN),
        .i_par_err(par_err),
        .i_strt_glitch(strt_glitch),
        .i_stp_err(stp_err),
        .i_bit_cnt(bit_cnt), 
        .i_edge_cnt(edge_cnt),
        .o_par_chk_en(par_chk_en),
        .o_strt_chk_en(strt_chk_en),
        .o_stp_chk_en(stp_chk_en),
        .o_data_valid(data_valid),
        .o_deser_en(deser_en),
        .o_enable(enable_cnt),
        .o_data_sample_en(data_samp_en)
    );

    // 2. Data Sampling Block
    data_sampling u_data_sampling (
        .i_clk(CLK),
        .i_resetn(RSTn),
        .i_prescale(Prescale),
        .i_data_samp_en(data_samp_en),
        .i_edge_cnt(edge_cnt),
        .i_RX_IN(RX_IN),
        .o_sampled_bit(sampled_bit)
    );

    // 3. Edge and Bit Counter
    edge_bit_counter u_edge_bit_counter (
        .i_clk(CLK),
        .i_resetn(RSTn),
        .i_enable(enable_cnt),
        .i_PAR_EN(PAR_EN),
        .i_prescale(Prescale),
        .o_bit_cnt(bit_cnt),
        .o_edge_cnt(edge_cnt)
    );

    // 4. Parity Checker
    parity_check u_parity_check (
        .i_clk(CLK),
        .i_resetn(RSTn),
        .i_par_chk_en(par_chk_en),
        .i_stp_chk_en(stp_chk_en),
        .i_par_typ(PAR_TYP),
        .i_sampled_bit(sampled_bit),
        .o_par_err(par_err)
    );

    // 5. Start Checker
    strt_check u_strt_check (
        .i_clk(CLK),
        .i_resetn(RSTn),
        .i_strt_chk_en(strt_chk_en),
        .i_sampled_bit(sampled_bit),
        .o_strt_glitch(strt_glitch)
    );

    // 6. Stop Checker
    stp_check u_stop_check (
        .i_clk(CLK),
        .i_resetn(RSTn),
        .i_stp_chk_en(stp_chk_en),
        .i_sampled_bit(sampled_bit),
        .o_stp_err(stp_err)
    );

    // 7. Deserializer
    deserializer u_deserializer (
        .i_clk(CLK),
        .i_resetn(RSTn),
        .i_deser_en(deser_en),
        .i_sampled_bit(sampled_bit),
        .o_P_DATA(P_DATA)
    );

endmodule