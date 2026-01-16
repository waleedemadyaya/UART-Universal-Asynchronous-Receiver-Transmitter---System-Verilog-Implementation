module clk_div #(
    parameter DIVISION_RATION_WIDTH = 8
)(
    input  logic                                i_ref_clk,
    input  logic                                i_rst_n,
    input  logic                                i_clk_en,
    input  logic [DIVISION_RATION_WIDTH - 1 : 0] i_div_ratio,
    output logic                                o_div_clk
);

    logic [DIVISION_RATION_WIDTH - 1 : 0] r_div_counter;
    logic                                 r_latched_en;
    
    logic [DIVISION_RATION_WIDTH - 1 : 0] w_half_ratio;
    assign w_half_ratio = i_div_ratio >> 1;

    
    always_latch begin
        if (!i_ref_clk) begin
            r_latched_en = i_clk_en;
        end
    end

    always_ff @(posedge i_ref_clk or negedge i_rst_n) begin : proc_counter
        if (!i_rst_n) begin
            r_div_counter <= '0;
            o_div_clk     <= 1'b0;
        end else if (r_latched_en) begin
            
            if (i_div_ratio <= 1) begin
                o_div_clk <= !o_div_clk; 
            end else if (r_div_counter >= i_div_ratio - 1) begin
                r_div_counter <= '0;
                o_div_clk     <= 1'b0; 
            end else begin
                r_div_counter <= r_div_counter + 1'b1;
                
                // Toggle point for 50% duty cycle
                if (r_div_counter == w_half_ratio - 1) begin
                    o_div_clk <= 1'b1;
                end
            end
        end else begin
            // Reset state when disabled
            o_div_clk     <= 1'b0;
            r_div_counter <= '0;
        end
    end

endmodule