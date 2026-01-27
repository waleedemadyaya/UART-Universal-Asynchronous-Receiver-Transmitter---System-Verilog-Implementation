import SYS_PACKAGE::*;

module deserializer (
    input  logic                   i_clk,
    input  logic                   i_resetn,
    input  logic                   i_deser_en,    // Enable signal from block diagram
    input  logic                   i_sampled_bit, // Serial input bit from voter
    output logic [DATA_WIDTH-1:0]  o_P_DATA       // Parallel data output
);

    // Internal shift register to collect bits
    logic [DATA_WIDTH-1:0] r_p_data_reg;

    always_ff @(posedge i_clk or negedge i_resetn) begin : deserializer_logic
        if (!i_resetn) begin
            r_p_data_reg <= '0;
        end else if (i_deser_en) begin
            /* Since the serializer sent the LSB first (latched_data[0]), 
               we shift the incoming bit into the MSB and shift the 
               existing bits down toward the LSB.
            */
            r_p_data_reg <= {i_sampled_bit, r_p_data_reg[DATA_WIDTH-1:1]};
        end
    end

    // Continuous assignment to output the collected parallel data
    assign o_P_DATA = r_p_data_reg;

endmodule