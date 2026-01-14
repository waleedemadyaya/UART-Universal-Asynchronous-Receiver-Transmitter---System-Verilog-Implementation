module strt_check (
    input  logic i_clk,
    input  logic i_resetn,
    input  logic i_strt_chk_en,
    input  logic i_sampled_bit,
    output logic o_strt_glitch
);

    always_ff @(posedge i_clk or negedge i_resetn) begin
        if (!i_resetn) begin
            o_strt_glitch <= 1'b0;
        end else if (i_strt_chk_en) begin
            // Start bit must be 0; if it's 1, it's a glitch
            o_strt_glitch <= i_sampled_bit; 
        end
    end

endmodule