module clock_gating (
    input logic i_CLK,
    input logic i_CLK_EN,
    output logic o_GATED_CLK
);
    logic r_sync_en;
    
    always_latch begin : blockName
        if(!i_CLK)
        begin
            r_sync_en <= i_CLK_EN;
        end
    end

    assign o_GATED_CLK = i_CLK & r_sync_en;

endmodule