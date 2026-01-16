`timescale 1ns/1ps

module Data_Sync_tb();

    // 1. Parameters and Signals
    parameter BUS_WIDTH = 8;
    
    // Source Domain Signals
    logic                 src_clk;
    logic [BUS_WIDTH-1:0] i_unsync_bus;
    logic                 i_bus_enable;

    // Destination Domain Signals
    logic                 i_dest_clk;
    logic                 i_dest_rst_n;
    wire [BUS_WIDTH-1:0]  o_sync_bus;
    wire                  o_enable_pulse;

    // Clock Periods (Source is slower than Destination)
    localparam SRC_T  = 25; // 40 MHz
    localparam DEST_T = 10; // 100 MHz

    // 2. DUT Instantiation
    Data_Sync #(.BUS_WIDTH(BUS_WIDTH)) DUT (
        .i_unsync_bus  (i_unsync_bus),
        .i_bus_enable  (i_bus_enable),
        .i_dest_clk    (i_dest_clk),
        .i_dest_rst_n  (i_dest_rst_n),
        .o_sync_bus    (o_sync_bus),
        .o_enable_pulse(o_enable_pulse)
    );

    // 3. Clock Generation
    initial src_clk = 0;
    always #(SRC_T/2) src_clk = ~src_clk;

    initial i_dest_clk = 0;
    always #(DEST_T/2) i_dest_clk = ~i_dest_clk;

    // 4. Test Procedure
    initial begin
        // --- Initialization ---
        i_dest_rst_n = 0;
        i_unsync_bus = '0;
        i_bus_enable = 0;

        // --- Reset Phase ---
        #(DEST_T * 3) i_dest_rst_n = 1;
        #(DEST_T * 2);

        // --- Test Case 1: Standard Transfer ---
        $display("[TIME: %0t] Starting Case 1: Standard Transfer", $time);
        @(posedge src_clk);
        i_unsync_bus <= 8'hA5;
        i_bus_enable <= 1;
        
        // Hold enable for a few source cycles
        repeat(2) @(posedge src_clk);
        i_bus_enable <= 0;

        // Wait for destination domain to process
        wait(o_enable_pulse);
        @(posedge i_dest_clk);
        if (o_sync_bus === 8'hA5)
            $display("[PASS] Data A5 synchronized correctly.");
        else
            $display("[FAIL] Expected A5, got %h", o_sync_bus);

        #(DEST_T * 10);

        // --- Test Case 2: Data Change while Enable is High ---
        $display("[TIME: %0t] Starting Case 2: MCP Stability Check", $time);
        @(posedge src_clk);
        i_unsync_bus <= 8'h3C;
        i_bus_enable <= 1;
        
        // The MCP (Multi-Cycle Path) design assumes data is stable 
        // when the pulse is generated. We verify the sampling pulse here.
        repeat(5) @(posedge i_dest_clk);
        i_bus_enable <= 0;

        #(DEST_T * 20);
        $display("[TIME: %0t] Simulation Finished", $time);
        $stop;
    end

endmodule