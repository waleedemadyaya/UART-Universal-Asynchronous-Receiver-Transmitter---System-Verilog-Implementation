module stp_check (
    input  logic i_clk,
    input  logic i_resetn,
    input  logic i_stp_chk_en,
    input  logic i_sampled_bit,
    output logic o_stp_err
);

    always_ff @(posedge i_clk or negedge i_resetn) begin
        if (!i_resetn) begin
            o_stp_err <= 1'b0;
        end else if (i_stp_chk_en) begin
            // Stop bit must be 1; if it's 0, it's a framing error
            o_stp_err <= !i_sampled_bit;
        end
    end

endmodule