import UART_PACKAGE::*;

module FSM_controller (
    input i_clk,
    input i_resetn,
    input i_Data_Valid,
    input i_PAR_EN,
    input i_ser_done,
    output logic o_ser_en,
    output logic o_latch_en,
    output logic [1:0] o_mux_sel,
    output logic o_busy
);
    localparam NUM_BITS = DATA_WIDTH;

    typedef enum logic [2:0] {
        S_IDLE      = 3'd0,    // Waiting for data
        S_LATCH     = 3'd1,    // Latch parallel data
        S_START     = 3'd2,    // Send start bit
        S_DATA      = 3'd3,    // Send data bits
        S_PARITY    = 3'd4,    // Send parity bit
        S_STOP     = 3'd5      // First stop bit
    } state_t;

    state_t c_state;
    state_t n_state;
    reg [$clog2(DATA_WIDTH):0] bit_counter;

    always_ff @( posedge i_clk, negedge i_resetn ) begin : FSM_controller
        if(!i_resetn)
        begin
            c_state <= S_IDLE;
        end else begin
            c_state <= n_state;
        end
    end

    always_ff @( posedge i_clk, negedge i_resetn ) begin : Bit_Counter
        if(!i_resetn)
        begin
            bit_counter <= 'b0;
        end else if (c_state == S_DATA) begin
            bit_counter <= bit_counter + 'b1;
        end else begin
            bit_counter <= 'b0;
        end
    end

    always_comb begin : next_state_outputs
        o_ser_en = 0;
        o_latch_en = 0;
        o_mux_sel = 1;
        o_busy = 0;
        n_state = c_state;
        case (c_state) 
            S_IDLE:
            begin
                if(i_Data_Valid)
                begin
                    n_state = S_LATCH;
                end
            end
            S_LATCH:
            begin
                n_state = S_START;
                o_latch_en = 1;
            end
            S_START:
            begin
                n_state = S_DATA;
                o_mux_sel = 0;
                o_busy = 1;
            end
            S_DATA:
            begin
                if(i_PAR_EN && (bit_counter==NUM_BITS-1))
                    n_state = S_PARITY;
                else if(bit_counter==NUM_BITS-1)
                    n_state = S_STOP;
                else
                    n_state = S_DATA;

                o_ser_en = 1;
                o_busy = 1;
                o_mux_sel = 2;
            end
            S_PARITY:
            begin
                n_state = S_STOP;
                
                o_busy = 1;
                o_mux_sel = 3;
            end
            S_STOP:
            begin   
                n_state = S_IDLE;
                
                o_busy = 1;
                o_mux_sel = 1;
            end
        endcase
    end
endmodule