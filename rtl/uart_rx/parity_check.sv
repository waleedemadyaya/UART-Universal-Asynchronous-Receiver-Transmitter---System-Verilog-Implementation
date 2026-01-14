module parity_check (
    input  logic i_clk,
    input  logic i_resetn,
    input  logic i_par_chk_en,   // Pulse to read the frame's parity bit
    input  logic i_stp_chk_en,   // Pulse at stop bit to reset accumulator
    input  logic i_par_typ,      // 0: Even, 1: Odd
    input  logic i_sampled_bit,  // Serial bit from the voter
    output logic o_par_err       // Parity error status
);

    // Internal register to store the accumulated XOR result
    logic r_parity_acc;

    // --- Serial Parity Accumulation & Reset ---
    
    always_ff @(posedge i_clk or negedge i_resetn) begin
        if (!i_resetn) begin
            r_parity_acc <= 1'b0;
        end else if (i_stp_chk_en) begin
            // Reset the accumulator at the stop bit to prepare for next frame
            r_parity_acc <= 1'b0;
        end else if (i_par_chk_en) begin
            // Accumulate parity by XORing incoming data bits
            r_parity_acc <= r_parity_acc ^ i_sampled_bit;
        end
    end

    // --- Error Detection at Parity Check Enable ---
    always_ff @(posedge i_clk or negedge i_resetn) begin
        if (!i_resetn) begin
            o_par_err <= 1'b0;
        end else if (i_par_chk_en) begin
            if (i_par_typ == 1'b0) begin : even_parity_check
                // Even: The XOR of data bits should match the parity bit
                o_par_err <= (r_parity_acc != i_sampled_bit);
            end else begin : odd_parity_check
                // Odd: The XOR of data bits should be the inverse of the parity bit
                o_par_err <= (r_parity_acc == i_sampled_bit);
            end
        end
    end

endmodule