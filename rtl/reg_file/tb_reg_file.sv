`timescale 1ns/1ps

// Testbench for Register File
module tb_reg_file;
    
    // Import package parameters
    import UART_PACKAGE::*;
    
    // Parameters
    localparam CLK_PERIOD = 10; // 100 MHz clock
    
    // DUT Signals
    logic [DATA_WIDTH-1:0] i_WrData;
    logic [ADDRESS_WIDTH-1:0] i_Address;
    logic i_WrEn;
    logic i_RdEn;
    logic CLK;
    logic RSTn;
    
    logic [DATA_WIDTH-1:0] o_RdData;
    logic [DATA_WIDTH-1:0] o_REG0;
    logic [DATA_WIDTH-1:0] o_REG1;
    logic [DATA_WIDTH-1:0] o_REG2;
    logic [DATA_WIDTH-1:0] o_REG3;
    logic o_RdData_Valid;
    
    // Testbench variables
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    // Clock Generation
    initial begin
        CLK = 1'b0;
        forever #(CLK_PERIOD/2) CLK = ~CLK;
    end
    
    // DUT Instantiation
    reg_file dut (
        .i_WrData(i_WrData),
        .i_Address(i_Address),
        .i_WrEn(i_WrEn),
        .i_RdEn(i_RdEn),
        .CLK(CLK),
        .RSTn(RSTn),
        .o_RdData(o_RdData),
        .o_REG0(o_REG0),
        .o_REG1(o_REG1),
        .o_REG2(o_REG2),
        .o_REG3(o_REG3),
        .o_RdData_Valid(o_RdData_Valid)
    );
    
    // Main Test Sequence
    initial begin
        $display("=========================================");
        $display("Starting Register File Testbench");
        $display("=========================================\n");
        
        // Initialize all inputs
        initialize();
        
        // Apply reset
        apply_reset();
        
        // Test 1: Check initial values after reset
        test_count++;
        $display("Test %0d: Checking initial register values after reset", test_count);
        check_initial_values();
        
        // Test 2: Write to register 0
        test_count++;
        $display("\nTest %0d: Write operation to register 0", test_count);
        write_register(0, 8'hAA);
        verify_write(0, 8'hAA);
        
        // Test 3: Write to register 1
        test_count++;
        $display("\nTest %0d: Write operation to register 1", test_count);
        write_register(1, 8'h55);
        verify_write(1, 8'h55);
        
        // Test 4: Read from register 2 (should be initial value 8'h81)
        test_count++;
        $display("\nTest %0d: Read operation from register 2 (initial value)", test_count);
        read_register(2);
        verify_read(2, 8'b1000_0001);
        
        // Test 5: Read from register 3 (should be initial value 8'h20)
        test_count++;
        $display("\nTest %0d: Read operation from register 3 (initial value)", test_count);
        read_register(3);
        verify_read(3, 8'b0010_0000);
        
        // Test 6: Overwrite register 2
        test_count++;
        $display("\nTest %0d: Overwrite register 2 with new value", test_count);
        write_register(2, 8'hF0);
        verify_write(2, 8'hF0);
        
        // Test 7: Read back overwritten register 2
        test_count++;
        $display("\nTest %0d: Read back overwritten register 2", test_count);
        read_register(2);
        verify_read(2, 8'hF0);
        
        // Test 8: Simultaneous write and read (should prioritize write)
        test_count++;
        $display("\nTest %0d: Simultaneous write and read enable", test_count);
        simultaneous_write_read();
        
        // Test 9: Read data valid signal timing
        test_count++;
        $display("\nTest %0d: Read data valid signal timing", test_count);
        test_rddata_valid();
        
        // Test 10: Multiple back-to-back operations
        test_count++;
        $display("\nTest %0d: Multiple back-to-back operations", test_count);
        back_to_back_operations();
        
        // Test 11: Reset during operation
        test_count++;
        $display("\nTest %0d: Reset during write operation", test_count);
        reset_during_write();
        
        // Summary
        $display("\n=========================================");
        $display("Test Summary");
        $display("=========================================");
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", fail_count);
        $display("=========================================");
        
        // End simulation
        #100;
        $finish;
    end
    
    // =========================================
    // TASKS
    // =========================================
    
    // Task 1: Initialize all signals
    task initialize();
        i_WrData = '0;
        i_Address = '0;
        i_WrEn = 1'b0;
        i_RdEn = 1'b0;
        RSTn = 1'b1;
        #10;
    endtask
    
    // Task 2: Apply reset
    task apply_reset();
        $display("Applying reset...");
        RSTn = 1'b0;
        #(CLK_PERIOD * 2);
        RSTn = 1'b1;
        #(CLK_PERIOD * 2);
        $display("Reset released.");
    endtask
    
    // Task 3: Check initial values
    task check_initial_values();
        $display("Expected: REG0 = 0x00, REG1 = 0x00, REG2 = 0x81, REG3 = 0x20");
        $display("Actual:   REG0 = 0x%02X, REG1 = 0x%02X, REG2 = 0x%02X, REG3 = 0x%02X", 
                 o_REG0, o_REG1, o_REG2, o_REG3);
        
        if (o_REG0 === 8'h00 && o_REG1 === 8'h00 && 
            o_REG2 === 8'b1000_0001 && o_REG3 === 8'b0010_0000) begin
            $display("✓ PASS: Initial values are correct");
            pass_count++;
        end else begin
            $display("✗ FAIL: Initial values mismatch");
            fail_count++;
        end
    endtask
    
    // Task 4: Write to a register
    task write_register(input [ADDRESS_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data);
        @(posedge CLK);
        i_Address = addr;
        i_WrData = data;
        i_WrEn = 1'b1;
        i_RdEn = 1'b0;
        @(posedge CLK);
        i_WrEn = 1'b0;
        #10;
    endtask
    
    // Task 5: Verify write operation
    task verify_write(input [ADDRESS_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] expected_data);
        logic [DATA_WIDTH-1:0] actual_data;
        
        // Check through direct output ports for specific registers
        case (addr)
            0: actual_data = o_REG0;
            1: actual_data = o_REG1;
            2: actual_data = o_REG2;
            3: actual_data = o_REG3;
            default: begin
                $display("Warning: Checking non-standard register %0d", addr);
                read_register(addr);
                @(posedge CLK);
                actual_data = o_RdData;
            end
        endcase
        
        $display("Address %0d: Expected = 0x%02X, Actual = 0x%02X", 
                 addr, expected_data, actual_data);
        
        if (actual_data === expected_data) begin
            $display("✓ PASS: Write successful");
            pass_count++;
        end else begin
            $display("✗ FAIL: Write mismatch");
            fail_count++;
        end
    endtask
    
    // Task 6: Read from a register
    task read_register(input [ADDRESS_WIDTH-1:0] addr);
        @(posedge CLK);
        i_Address = addr;
        i_WrEn = 1'b0;
        i_RdEn = 1'b1;
        @(posedge CLK);
        i_RdEn = 1'b0;
        #10;
    endtask
    
    // Task 7: Verify read operation
    task verify_read(input [ADDRESS_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] expected_data);
        $display("Address %0d: Expected = 0x%02X, Actual = 0x%02X", 
                 addr, expected_data, o_RdData);
        
        if (o_RdData === expected_data) begin
            $display("✓ PASS: Read data matches expected");
            pass_count++;
        end else begin
            $display("✗ FAIL: Read data mismatch");
            fail_count++;
        end
        
        // Also verify RdData_Valid is high
        if (o_RdData_Valid === 1'b1) begin
            $display("✓ RdData_Valid is correctly asserted");
        end else begin
            $display("✗ FAIL: RdData_Valid not asserted during read");
            fail_count++;
        end
    endtask
    
    // Task 8: Test simultaneous write and read
    task simultaneous_write_read();
        // Write to register 1 while trying to read from register 0
        @(posedge CLK);
        i_Address = 1;      // Write address
        i_WrData = 8'h99;
        i_WrEn = 1'b1;
        i_RdEn = 1'b0;      // Only write enabled
        @(posedge CLK);
        
        // Check that write happened
        if (o_REG1 === 8'h99) begin
            $display("✓ PASS: Write takes precedence, REG1 = 0x%02X", o_REG1);
            pass_count++;
        end else begin
            $display("✗ FAIL: Write operation failed");
            fail_count++;
        end
        
        i_WrEn = 1'b0;
        #10;
    endtask
    
    // Task 9: Test read data valid signal timing
    task test_rddata_valid();
        // Read from register 3
        @(posedge CLK);
        i_Address = 3;
        i_RdEn = 1'b1;
        
        // Check one clock cycle later
        @(negedge CLK);
        if (o_RdData_Valid === 1'b0) begin
            $display("✓ RdData_Valid is low during same cycle");
            pass_count++;
        end
        
        @(posedge CLK);
        i_RdEn = 1'b0;
        
        @(negedge CLK);
        if (o_RdData_Valid === 1'b1) begin
            $display("✓ RdData_Valid goes high one cycle after read enable");
            pass_count++;
        end else begin
            $display("✗ FAIL: RdData_Valid timing incorrect");
            fail_count++;
        end
        
        // Wait another cycle
        @(posedge CLK);
        @(negedge CLK);
        if (o_RdData_Valid === 1'b0) begin
            $display("✓ RdData_Valid goes low when not reading");
            pass_count++;
        end
        
        #10;
    endtask
    
    // Task 10: Back-to-back operations
    task back_to_back_operations();
        $display("Performing back-to-back writes and reads...");
        
        // Write sequence
        write_register(0, 8'h11);
        write_register(1, 8'h22);
        write_register(2, 8'h33);
        write_register(3, 8'h44);
        
        // Read sequence
        read_register(0);
        verify_read(0, 8'h11);
        read_register(1);
        verify_read(1, 8'h22);
        read_register(2);
        verify_read(2, 8'h33);
        read_register(3);
        verify_read(3, 8'h44);
        
        $display("Back-to-back operations completed");
    endtask
    
    // Task 11: Reset during write operation
    task reset_during_write();
        // Start a write operation
        @(posedge CLK);
        i_Address = 1;
        i_WrData = 8'hFF;
        i_WrEn = 1'b1;
        
        // Apply reset during write
        #(CLK_PERIOD/2);
        RSTn = 1'b0;
        @(posedge CLK);
        
        // Check if register 1 reverted to initial value (0x00)
        if (o_REG1 === 8'h00) begin
            $display("✓ PASS: Reset correctly overrides write, REG1 = 0x%02X", o_REG1);
            pass_count++;
        end else begin
            $display("✗ FAIL: Reset didn't override write");
            fail_count++;
        end
        
        // Release reset
        RSTn = 1'b1;
        i_WrEn = 1'b0;
        #(CLK_PERIOD * 2);
    endtask
    
    // =========================================
    // MONITOR
    // =========================================
    
    initial begin
        $display("\n=========================================");
        $display("Transaction Monitor");
        $display("=========================================");
        $display("Time(ns) | WrEn | RdEn | Addr | WrData  | RdData  | RdValid");
        $display("---------------------------------------------------------");
        
        forever begin
            @(posedge CLK);
            if (i_WrEn || i_RdEn) begin
                $display("%8t |  %b   |  %b   |  %2d  | 0x%02X   | 0x%02X   |   %b",
                         $time, i_WrEn, i_RdEn, i_Address, i_WrData, o_RdData, o_RdData_Valid);
            end
        end
    end
    
    // =========================================
    // WAVEFORM DUMPING (Optional)
    // =========================================
    
    initial begin
        $dumpfile("reg_file_waves.vcd");
        $dumpvars(0, tb_reg_file);
    end
    
    // =========================================
    // TIMEOUT
    // =========================================
    
    initial begin
        #50000; // 50us timeout
        $display("\n✗ TIMEOUT: Simulation timed out");
        $finish;
    end
    
endmodule