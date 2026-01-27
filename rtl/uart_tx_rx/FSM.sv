import SYS_PACKAGE::*;

module fsm_controller (
    input  logic i_clk,
    input  logic i_resetn,
    input  logic i_RX_IN,
    input  logic [PRESCALE_WIDTH-1:0] i_Prescale,
    input  logic i_PAR_EN,
    input  logic i_par_err,
    input  logic i_strt_glitch,
    input  logic i_stp_err,
    input  logic [$clog2(DATA_WIDTH+3)-1 : 0] i_bit_cnt,
    input  logic [PRESCALE_WIDTH-1: 0] i_edge_cnt,
    output logic o_par_chk_en,
    output logic o_par_ser_en,
    output logic o_strt_chk_en,
    output logic o_stp_chk_en,
    output logic o_data_valid,
    output logic o_deser_en,
    output logic o_enable,
    output logic o_data_sample_en
);

// Note: Ensure rx_state is defined in your UART_PACKAGE or here
// typedef enum {IDLE, START, DATA, PARITY, STOP} rx_state;
typedef enum logic [2:0] {IDLE, START, DATA, PARITY, STOP} rx_state;
rx_state crnt_state, next_state;

always_ff @(posedge i_clk or negedge i_resetn) begin
    if (!i_resetn)
        crnt_state <= IDLE;
    else
        crnt_state <= next_state;
end

always_comb begin
    // --- Default Assignments (Prevents Latches) ---
    next_state       = crnt_state; 
    o_par_chk_en     = 'b0; 
    o_par_ser_en     = 'b0; 
    o_strt_chk_en    = 'b0; 
    o_stp_chk_en     = 'b0; 
    o_data_valid     = 'b0; 
    o_deser_en       = 'b0; 
    o_enable         = 'b0; 
    o_data_sample_en = 'b0; 

    case (crnt_state)
        IDLE: begin
            if (!i_RX_IN) next_state = START;
            else          next_state = IDLE;
        end

        START: begin
            o_strt_chk_en    = 1;
            o_enable         = 1;
            o_data_sample_en = 1;

            if ((i_bit_cnt == 1) && !i_strt_glitch) next_state = DATA;
            else if (i_strt_glitch && (i_edge_cnt == (i_Prescale - 1)))                 next_state = IDLE;
            else                                    next_state = START;
        end

        DATA: begin
            o_enable         = 1;
            o_data_sample_en = 1;
            o_par_ser_en     = 1;

            if(i_edge_cnt == (i_Prescale - 1))
                o_deser_en = 'b1;

            if (i_bit_cnt == DATA_WIDTH+1) begin
                if (i_PAR_EN) next_state = PARITY;
                else          next_state = STOP;
            end else begin
                next_state = DATA;
            end
        end

        PARITY: begin
            o_par_chk_en     = 1;
            o_enable         = 1;
            o_data_sample_en = 1;

            if ((i_bit_cnt == DATA_WIDTH+2) && !i_stp_err) next_state = STOP;
            else if (i_stp_err)                            next_state = IDLE;
            else                                           next_state = PARITY;
        end

        STOP: begin
            if(i_edge_cnt == (i_Prescale - 1))
                o_data_valid = 'b1;
            o_stp_chk_en     = 1;
            o_enable         = 1;
            o_data_sample_en = 1;

            if (i_bit_cnt == 0) next_state = IDLE;
            else                next_state = STOP;
        end

        default: begin
            next_state = IDLE;
            // All outputs already covered by default assignments at top
        end
    endcase
end

endmodule