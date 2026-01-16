module RST_SYNC (
    input  logic i_CLK,       // System Clock
    input  logic i_RST_n,     // Asynchronous Reset Input (Active Low)
    output logic o_SYNC_RST_n // Synchronized Reset Output (Active Low)
);

    // Two-stage shift register for synchronization
    logic r_sync_reg_1, r_sync_reg_2;

    always_ff @(posedge i_CLK or negedge i_RST_n) begin
        if (!i_RST_n) begin
            // On reset, immediately clear synchronizers to '0'
            r_sync_reg_1 <= 1'b0;
            r_sync_reg_2 <= 1'b0;
        end else begin
            // Shift in a '1' to release the reset synchronously
            r_sync_reg_1 <= 1'b1;
            r_sync_reg_2 <= r_sync_reg_1;
        end
    end

    // The output is the second stage of the synchronizer
    assign o_SYNC_RST_n = r_sync_reg_2;

endmodule