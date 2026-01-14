import UART_PACKAGE::*;

module data_sampling (
    input logic i_clk,
    input logic i_resetn,

    input logic [PRESCALE_WIDTH-1 : 0] i_prescale,
    input logic i_data_samp_en,
    input logic [PRESCALE_WIDTH-1 : 0] i_edge_cnt,
    input logic i_RX_IN,

    output logic o_sampled_bit
);

    reg [NUM_SAMPLED_BITS-1 : 0] r_sampled_bits;

    always_ff @( posedge i_clk, negedge i_resetn ) begin : data_sampling
        if(!i_resetn)begin
            r_sampled_bits <= 'b0;
        end else if (i_data_samp_en) begin
            if (i_edge_cnt == ((i_prescale >> 1) - 1))
            begin
                r_sampled_bits[0] <= i_RX_IN;
            end else if (i_edge_cnt == ((i_prescale >> 1)))
            begin
                r_sampled_bits[1] <= i_RX_IN;
            end else if (i_edge_cnt == ((i_prescale >> 1) + 1))
            begin
                r_sampled_bits[2] <= i_RX_IN;
            end
        end
    end

    assign o_sampled_bit = (r_sampled_bits[0] & r_sampled_bits[1]) |
                  (r_sampled_bits[1] & r_sampled_bits[2]) |
                  (r_sampled_bits[0] & r_sampled_bits[2]);

endmodule