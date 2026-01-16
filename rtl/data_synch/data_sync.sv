module Data_Sync #(
    parameter BUS_WIDTH = 8
)(
    input  logic [BUS_WIDTH-1:0] i_unsync_bus,   // Unsynchronized data from source domain
    input  logic                 i_bus_enable,   // Enable signal from source domain
    input  logic                 i_dest_clk,     // Destination clock domain
    input  logic                 i_dest_rst_n,   // Destination active-low reset
    output logic [BUS_WIDTH-1:0] o_sync_bus,     // Synchronized data bus
    output logic                 o_enable_pulse  // Single-cycle pulse in dest domain
);

    // Internal synchronization registers for the enable signal
    logic [2:0] r_sync_chain;
    
    // -------------------------------------------------------------------------
    // 1. Synchronize the Enable Signal
    // We use a 3-stage synchronizer to minimize metastability risk.
    // -------------------------------------------------------------------------
    always_ff @(posedge i_dest_clk or negedge i_dest_rst_n) begin
        if (!i_dest_rst_n) begin
            r_sync_chain <= 3'b0;
        end else begin
            r_sync_chain <= {r_sync_chain[1:0], i_bus_enable};
        end
    end

    // -------------------------------------------------------------------------
    // 2. Pulse Generation (Rising Edge Detection)
    // Create a single-cycle pulse when the synchronized enable signal goes high.
    // -------------------------------------------------------------------------
    assign o_enable_pulse = r_sync_chain[1] & (~r_sync_chain[2]);

    // -------------------------------------------------------------------------
    // 3. Data Sampling (Multi-Cycle Path)
    // When the pulse is high, the data bus is guaranteed to be stable.
    // This prevents individual bits of the bus from "skewing."
    // -------------------------------------------------------------------------
    always_ff @(posedge i_dest_clk or negedge i_dest_rst_n) begin
        if (!i_dest_rst_n) begin
            o_sync_bus <= '0;
        end else begin
            o_sync_bus <= i_unsync_bus;
        end
    end

endmodule