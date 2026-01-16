module clock_gating (
    input logic i_clk,
    input logic i_en,
    output logic o_clk
);
    logic r_sync_en;
    
    always_latch begin : blockName
        if(!i_clk)
        begin
            r_sync_en <= i_en;
        end
    end

    assign o_clk = i_clk & r_sync_en;

endmodule