import SYS_PACKAGE::*;

module edge_bit_counter (
    input  logic i_clk,
    input  logic i_resetn,
    input  logic i_enable,
    input  logic i_PAR_EN,
    input  logic [PRESCALE_WIDTH - 1     : 0]  i_prescale,
    output logic [$clog2(DATA_WIDTH+3) - 1 : 0]  o_bit_cnt,
    output logic [PRESCALE_WIDTH - 1     : 0]  o_edge_cnt
);

logic latched_PAR_en;
logic [PRESCALE_WIDTH - 1     : 0] latched_prescale;

always_latch begin : PAR_EN_latch
    if(!i_enable)
    begin
        latched_PAR_en <= i_PAR_EN;
        latched_prescale <= i_prescale;
    end
end

always_ff @( posedge i_clk, negedge i_resetn ) begin : edge_bit_counter
    if (!i_resetn) begin
        o_bit_cnt  <= 'b0;
        o_edge_cnt <= 'b0;
    end else if (i_enable) begin
        if (latched_PAR_en)
        begin
             if ((o_bit_cnt == (DATA_WIDTH + 2)) && (o_edge_cnt == (latched_prescale-1))) begin
                o_bit_cnt <= 'b0;
                o_edge_cnt <= 'b0;
             end else if (o_edge_cnt == (latched_prescale-1)) begin
                o_edge_cnt <= 'b0;
                o_bit_cnt <= o_bit_cnt + 1;
             end else begin
                o_edge_cnt <= o_edge_cnt + 1;
             end
        end else begin
            if ((o_bit_cnt == DATA_WIDTH + 1) && (o_edge_cnt == (latched_prescale-1))) begin
                o_bit_cnt <= 'b0;
                o_edge_cnt <= 'b0;
            end else if (o_edge_cnt == (latched_prescale-1)) begin
                o_edge_cnt <= 'b0;
                o_bit_cnt <= o_bit_cnt + 1;
            end else begin
                o_edge_cnt <= o_edge_cnt + 1;
            end
        end
    end
end

endmodule