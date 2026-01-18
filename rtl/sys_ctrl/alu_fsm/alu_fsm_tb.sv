`timescale 1ns/1ps

module alu_fsm_tb();

    // 1. Parameters and Signals
    parameter ALU_FUN_WIDTH = 4;
    parameter DATA_WIDTH    = 8;
    localparam T = 10; 

    logic                      i_clk;
    logic                      i_RSTn;
    logic                      i_alu_start;            
    logic                      data_synchronizer_valid;
    logic [DATA_WIDTH-1 : 0]   synch_data;
    logic                      i_operands_en;

    wire                       o_read_operands;
    logic                      i_read_operands_done;

    wire [ALU_FUN_WIDTH-1 : 0] o_Func;
    wire                       o_EN;
    logic                      i_OUT_Valid;
    wire                       o_alu_done;

    // 2. DUT Instantiation
    alu_fsm #(
        .ALU_FUN_WIDTH(ALU_FUN_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (.*);

    // 3. Clock Generation
    always #(T/2) i_clk = ~i_clk;

    // 4. Test Procedure
    initial begin
        // --- Initialization ---
        i_clk = 0; i_RSTn = 0; i_alu_start = 0;
        data_synchronizer_valid = 0; synch_data = '0; 
        i_operands_en = 0; i_read_operands_done = 0; i_OUT_Valid = 0;

        // --- Reset ---
        #(T*2) i_RSTn = 1;
        #(T*2);

        // --- TEST CASE 1: ALU OP with Operand Fetch (e.g., ADD) ---
        $display("[TIME: %0t] --- STARTING ALU OP WITH FETCH ---", $time);
        @(posedge i_clk);
        i_alu_start   <= 1;
        i_operands_en <= 1; // Signal that we need to fetch from RegFile
        @(posedge i_clk);
        i_alu_start   <= 0;

        // Simulate RegFile Master fetching operands
        wait(o_read_operands);
        #(T*3); // Simulate delay for fetching Op A and Op B
        @(posedge i_clk);
        i_read_operands_done <= 1;
        @(posedge i_clk);
        i_read_operands_done <= 0;

        // Send ALU Function code (e.g., 4'b0000 for ADD)
        #(T*2);
        @(posedge i_clk);
        synch_data <= 8'h00; 
        data_synchronizer_valid <= 1;
        @(posedge i_clk);
        data_synchronizer_valid <= 0;

        // Wait for ALU to finish calculation
        wait(o_EN);
        #(T*4); // Simulate ALU processing time
        @(posedge i_clk);
        i_OUT_Valid <= 1;
        @(posedge i_clk);
        i_OUT_Valid <= 0;

        wait(o_alu_done);
        $display("[SUCCESS] Case 1: ALU ADD operation completed.");

        #(T*5);

        // --- TEST CASE 2: ALU OP without Fetch (Operands already in ALU) ---
        $display("[TIME: %0t] --- STARTING ALU OP WITHOUT FETCH ---", $time);
        @(posedge i_clk);
        i_alu_start   <= 1;
        i_operands_en <= 0; 
        @(posedge i_clk);
        i_alu_start   <= 0;

        // Should skip READ_OPERANDS and go straight to WAIT_FUNC
        #(T*2);
        @(posedge i_clk);
        synch_data <= 8'h01; // Function 0x1 (e.g., SUB)
        data_synchronizer_valid <= 1;
        @(posedge i_clk);
        data_synchronizer_valid <= 0;

        wait(o_EN);
        #(T*2);
        @(posedge i_clk);
        i_OUT_Valid <= 1;
        @(posedge i_clk);
        i_OUT_Valid <= 0;

        wait(o_alu_done);
        if (o_Func === 4'h1)
            $display("[SUCCESS] Case 2: ALU SUB operation completed with correct function.");
        else
            $display("[FAILURE] Case 2: Incorrect Function Code detected!");

        #(T*10);
        $display("[TIME: %0t] ALL ALU TESTS COMPLETED", $time);
        $stop;
    end

    // --- Monitor ALU Enable Strobe ---
    always @(posedge i_clk) begin
        if (o_EN) $display("[ALU_ACTIVE] o_EN is High, Func: %h", o_Func);
    end

endmodule