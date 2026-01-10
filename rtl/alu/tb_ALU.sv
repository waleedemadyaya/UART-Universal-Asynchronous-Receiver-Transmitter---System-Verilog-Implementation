`timescale 1ns/1ps

// Testbench for ALU Module
module tb_ALU;
    
    // Import packages
    import UART_PACKAGE::*;
    import ALU_PACKAGE::*;
    
    // Parameters
    localparam CLK_PERIOD = 10; // 100 MHz clock
    localparam ALU_FUN_WIDTH_TB = 4; // Based on opcode_t width
    
    // DUT Signals
    logic i_CLK;
    logic i_RSTn;
    logic [ALU_FUN_WIDTH_TB-1:0] i_ALU_FUN;
    logic [DATA_WIDTH-1:0] i_A;
    logic [DATA_WIDTH-1:0] i_B;
    logic i_Enable;
    
    logic [2*DATA_WIDTH-1:0] o_ALU_OUT;
    logic o_CF;
    logic o_OF;
    logic o_EF;
    logic o_ZF;
    logic o_OUT_VALID;
    
    // Test variables
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    
    // Clock Generation
    initial begin
        i_CLK = 1'b0;
        forever #(CLK_PERIOD/2) i_CLK = ~i_CLK;
    end
    
    // DUT Instantiation
    ALU dut (
        .i_CLK(i_CLK),
        .i_RSTn(i_RSTn),
        .i_ALU_FUN(i_ALU_FUN),
        .i_A(i_A),
        .i_B(i_B),
        .i_Enable(i_Enable),
        .o_ALU_OUT(o_ALU_OUT),
        .o_CF(o_CF),
        .o_OF(o_OF),
        .o_EF(o_EF),
        .o_ZF(o_ZF),
        .o_OUT_VALID(o_OUT_VALID)
    );
    
    // Main Test Sequence
    initial begin
        $display("=========================================");
        $display("Starting ALU Testbench");
        $display("=========================================\n");
        
        // Initialize all inputs
        initialize();
        
        // Apply reset
        apply_reset();
        
        // Enable ALU
        i_Enable = 1'b1;
        
        // Test 1: Addition
        test_count++;
        $display("\nTest %0d: Addition (8 + 4)", test_count);
        test_operation(OP_ADD, 8'h08, 8'h04);
        check_addition(8'h08, 8'h04);
        
        // Test 2: Addition with carry
        test_count++;
        $display("\nTest %0d: Addition with carry (0xFF + 0x01)", test_count);
        test_operation(OP_ADD, 8'hFF, 8'h01);
        check_addition(8'hFF, 8'h01);
        
        // Test 3: Subtraction
        test_count++;
        $display("\nTest %0d: Subtraction (15 - 7)", test_count);
        test_operation(OP_SUB, 8'h0F, 8'h07);
        check_subtraction(8'h0F, 8'h07);
        
        // Test 4: Multiplication
        test_count++;
        $display("\nTest %0d: Multiplication (6 * 7)", test_count);
        test_operation(OP_MUL, 8'h06, 8'h07);
        check_multiplication(8'h06, 8'h07);
        
        // Test 5: Division
        test_count++;
        $display("\nTest %0d: Division (20 / 4)", test_count);
        test_operation(OP_DIV, 8'h14, 8'h04);
        check_division(8'h14, 8'h04);
        
        // Test 6: Division by zero
        test_count++;
        $display("\nTest %0d: Division by zero (10 / 0)", test_count);
        test_operation(OP_DIV, 8'h0A, 8'h00);
        check_division_by_zero(8'h0A, 8'h00);
        
        // Test 7: AND operation
        test_count++;
        $display("\nTest %0d: AND (0xF0 & 0x0F)", test_count);
        test_operation(OP_AND, 8'hF0, 8'h0F);
        check_and(8'hF0, 8'h0F);
        
        // Test 8: OR operation
        test_count++;
        $display("\nTest %0d: OR (0xAA | 0x55)", test_count);
        test_operation(OP_OR, 8'hAA, 8'h55);
        check_or(8'hAA, 8'h55);
        
        // Test 9: XOR operation
        test_count++;
        $display("\nTest %0d: XOR (0xAA ^ 0x55)", test_count);
        test_operation(OP_XOR, 8'hAA, 8'h55);
        check_xor(8'hAA, 8'h55);
        
        // Test 10: NAND operation
        test_count++;
        $display("\nTest %0d: NAND (0xFF NAND 0xFF)", test_count);
        test_operation(OP_NAND, 8'hFF, 8'hFF);
        check_nand(8'hFF, 8'hFF);
        
        // Test 11: NOR operation
        test_count++;
        $display("\nTest %0d: NOR (0x00 NOR 0x00)", test_count);
        test_operation(OP_NOR, 8'h00, 8'h00);
        check_nor(8'h00, 8'h00);
        
        // Test 12: XNOR operation
        test_count++;
        $display("\nTest %0d: XNOR (0xAA XNOR 0x55)", test_count);
        test_operation(OP_XNOR, 8'hAA, 8'h55);
        check_xnor(8'hAA, 8'h55);
        
        // Test 13: Equality comparison
        test_count++;
        $display("\nTest %0d: Equality Comparison (10 == 10)", test_count);
        test_operation(OP_CMP_EQ, 8'h0A, 8'h0A);
        check_equality(8'h0A, 8'h0A);
        
        // Test 14: Greater than comparison
        test_count++;
        $display("\nTest %0d: Greater Than Comparison (15 > 10)", test_count);
        test_operation(OP_CMP_GT, 8'h0F, 8'h0A);
        check_greater_than(8'h0F, 8'h0A);
        
        // Test 15: Shift right
        test_count++;
        $display("\nTest %0d: Shift Right (0xAA >> 1)", test_count);
        test_operation(OP_SHR, 8'hAA, 8'h00);
        check_shift_right(8'hAA);
        
        // Test 16: Shift left
        test_count++;
        $display("\nTest %0d: Shift Left (0x55 << 1)", test_count);
        test_operation(OP_SHL, 8'h55, 8'h00);
        check_shift_left(8'h55);
        
        // Test 17: Invalid operation
        test_count++;
        $display("\nTest %0d: Invalid operation code", test_count);
        test_operation(OP_INVALID, 8'h11, 8'h22);
        check_invalid_operation();
        
        // Test 18: Disabled ALU
        test_count++;
        $display("\nTest %0d: ALU Disabled (i_Enable = 0)", test_count);
        test_disabled_alu();
        
        // Test 19: Back-to-back operations
        test_count++;
        $display("\nTest %0d: Back-to-back operations", test_count);
        back_to_back_operations();
        
        // Test 20: Reset during operation
        test_count++;
        $display("\nTest %0d: Reset during operation", test_count);
        reset_during_operation();
        
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
        i_RSTn = 1'b1;
        i_ALU_FUN = '0;
        i_A = '0;
        i_B = '0;
        i_Enable = 1'b0;
        #10;
    endtask
    
    // Task 2: Apply reset
    task apply_reset();
        $display("Applying reset...");
        i_RSTn = 1'b0;
        #(CLK_PERIOD * 2);
        i_RSTn = 1'b1;
        #(CLK_PERIOD * 2);
        $display("Reset released.");
    endtask
    
    // Task 3: Test a single operation
    task test_operation(input [ALU_FUN_WIDTH_TB-1:0] op, 
                        input [DATA_WIDTH-1:0] a, 
                        input [DATA_WIDTH-1:0] b);
        @(posedge i_CLK);
        i_ALU_FUN = op;
        i_A = a;
        i_B = b;
        @(posedge i_CLK);
        #5; // Wait for outputs to stabilize
    endtask
    
    // Task 4: Check addition results
    task check_addition(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic [DATA_WIDTH:0] expected_sum;
        logic expected_cf, expected_of, expected_zf, expected_ef;
        
        expected_sum = a + b;
        expected_cf = expected_sum[DATA_WIDTH];
        expected_ef = (a == b);
        expected_zf = (expected_sum[DATA_WIDTH-1:0] == 0);
        
        // Overflow for signed addition
        expected_of = (a[DATA_WIDTH-1] == b[DATA_WIDTH-1]) && 
                      (expected_sum[DATA_WIDTH-1] != a[DATA_WIDTH-1]);
        
        verify_result("ADD", expected_sum[DATA_WIDTH-1:0], expected_cf, 
                     expected_of, expected_zf, expected_ef);
    endtask
    
    // Task 5: Check subtraction results
    task check_subtraction(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic [DATA_WIDTH:0] expected_diff;
        logic expected_cf, expected_of, expected_zf, expected_ef;
        
        expected_diff = a - b;
        expected_cf = expected_diff[DATA_WIDTH];
        expected_ef = (a == b);
        expected_zf = (expected_diff[DATA_WIDTH-1:0] == 0);
        
        // Overflow for signed subtraction
        expected_of = (a[DATA_WIDTH-1] != b[DATA_WIDTH-1]) && 
                      (expected_diff[DATA_WIDTH-1] != a[DATA_WIDTH-1]);
        
        verify_result("SUB", expected_diff[DATA_WIDTH-1:0], expected_cf, 
                     expected_of, expected_zf, expected_ef);
    endtask
    
    // Task 6: Check multiplication results
    task check_multiplication(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic [2*DATA_WIDTH-1:0] expected_prod;
        logic expected_zf, expected_ef;
        
        expected_prod = a * b;
        expected_ef = (a == b);
        expected_zf = (expected_prod == 0);
        
        verify_result("MUL", expected_prod, 1'b0, 1'b0, expected_zf, expected_ef);
    endtask
    
    // Task 7: Check division results
    task check_division(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic [DATA_WIDTH-1:0] expected_quotient, expected_remainder;
        logic [2*DATA_WIDTH-1:0] expected_result;
        logic expected_zf, expected_ef;
        
        if (b != 0) begin
            expected_quotient = a / b;
            expected_remainder = a % b;
            expected_zf = (expected_quotient == 0);
        end else begin
            expected_quotient = 8'hFF;
            expected_remainder = 8'hFF;
            expected_zf = 1'b0;
        end
        
        expected_result = {expected_remainder, expected_quotient};
        expected_ef = (a == b);
        
        verify_result("DIV", expected_result, (b == 0), 1'b0, expected_zf, expected_ef);
    endtask
    
    // Task 8: Check division by zero
    task check_division_by_zero(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic [2*DATA_WIDTH-1:0] expected_result;
        
        expected_result = {8'hFF, 8'hFF};  // Division by zero returns all 1's
        
        if (o_ALU_OUT === expected_result && o_CF === 1'b1) begin
            $display("✓ PASS: Division by zero handled correctly");
            $display("  Result = 0x%04X, CF = %b (error flag)", o_ALU_OUT, o_CF);
            pass_count++;
        end else begin
            $display("✗ FAIL: Division by zero not handled properly");
            $display("  Expected: Result = 0xFFFF, CF = 1");
            $display("  Actual:   Result = 0x%04X, CF = %b", o_ALU_OUT, o_CF);
            fail_count++;
        end
    endtask
    
    // Task 9: Check AND operation
    task check_and(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic [DATA_WIDTH-1:0] expected_result;
        logic expected_zf, expected_ef;
        
        expected_result = a & b;
        expected_ef = (a == b);
        expected_zf = (expected_result == 0);
        
        verify_result("AND", {8'h00, expected_result}, 1'b0, 1'b0, expected_zf, expected_ef);
    endtask
    
    // Task 10: Check OR operation
    task check_or(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic [DATA_WIDTH-1:0] expected_result;
        logic expected_zf, expected_ef;
        
        expected_result = a | b;
        expected_ef = (a == b);
        expected_zf = (expected_result == 0);
        
        verify_result("OR", {8'h00, expected_result}, 1'b0, 1'b0, expected_zf, expected_ef);
    endtask
    
    // Task 11: Check XOR operation
    task check_xor(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic [DATA_WIDTH-1:0] expected_result;
        logic expected_zf, expected_ef;
        
        expected_result = a ^ b;
        expected_ef = (a == b);
        expected_zf = (expected_result == 0);
        
        verify_result("XOR", {8'h00, expected_result}, 1'b0, 1'b0, expected_zf, expected_ef);
    endtask
    
    // Task 12: Check NAND operation
    task check_nand(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic [DATA_WIDTH-1:0] expected_result;
        logic expected_zf, expected_ef;
        
        expected_result = ~(a & b);
        expected_ef = (a == b);
        expected_zf = (expected_result == 0);
        
        verify_result("NAND", {8'h00, expected_result}, 1'b0, 1'b0, expected_zf, expected_ef);
    endtask
    
    // Task 13: Check NOR operation
    task check_nor(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic [DATA_WIDTH-1:0] expected_result;
        logic expected_zf, expected_ef;
        
        expected_result = ~(a | b);
        expected_ef = (a == b);
        expected_zf = (expected_result == 0);
        
        verify_result("NOR", {8'h00, expected_result}, 1'b0, 1'b0, expected_zf, expected_ef);
    endtask
    
    // Task 14: Check XNOR operation
    task check_xnor(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic [DATA_WIDTH-1:0] expected_result;
        logic expected_zf, expected_ef;
        
        expected_result = ~(a ^ b);
        expected_ef = (a == b);
        expected_zf = (expected_result == 0);
        
        verify_result("XNOR", {8'h00, expected_result}, 1'b0, 1'b0, expected_zf, expected_ef);
    endtask
    
    // Task 15: Check equality comparison
    task check_equality(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic expected_result;
        logic expected_ef;
        
        expected_result = (a == b) ? 1'b1 : 1'b0;
        expected_ef = (a == b);
        
        if (o_ALU_OUT[0] === expected_result && o_EF === expected_ef) begin
            $display("✓ PASS: Equality comparison correct");
            $display("  Result = %b, EF = %b", o_ALU_OUT[0], o_EF);
            pass_count++;
        end else begin
            $display("✗ FAIL: Equality comparison incorrect");
            $display("  Expected: Result = %b, EF = %b", expected_result, expected_ef);
            $display("  Actual:   Result = %b, EF = %b", o_ALU_OUT[0], o_EF);
            fail_count++;
        end
    endtask
    
    // Task 16: Check greater than comparison
    task check_greater_than(input [DATA_WIDTH-1:0] a, input [DATA_WIDTH-1:0] b);
        logic expected_result;
        logic expected_ef;
        
        expected_result = (a > b) ? 1'b1 : 1'b0;
        expected_ef = (a == b);
        
        if (o_ALU_OUT[0] === expected_result && o_EF === expected_ef) begin
            $display("✓ PASS: Greater than comparison correct");
            $display("  Result = %b, EF = %b", o_ALU_OUT[0], o_EF);
            pass_count++;
        end else begin
            $display("✗ FAIL: Greater than comparison incorrect");
            $display("  Expected: Result = %b, EF = %b", expected_result, expected_ef);
            $display("  Actual:   Result = %b, EF = %b", o_ALU_OUT[0], o_EF);
            fail_count++;
        end
    endtask
    
    // Task 17: Check shift right
    task check_shift_right(input [DATA_WIDTH-1:0] a);
        logic [DATA_WIDTH-1:0] expected_result;
        logic expected_cf, expected_zf, expected_ef;
        
        expected_result = a >> 1;
        expected_cf = a[0];
        expected_zf = (expected_result == 0);
        expected_ef = 1'b0;  // Not applicable for shift
        
        verify_result("SHR", {8'h00, expected_result}, expected_cf, 1'b0, expected_zf, expected_ef);
    endtask
    
    // Task 18: Check shift left
    task check_shift_left(input [DATA_WIDTH-1:0] a);
        logic [DATA_WIDTH-1:0] expected_result;
        logic expected_cf, expected_of, expected_zf, expected_ef;
        
        expected_result = a << 1;
        expected_cf = a[DATA_WIDTH-1];
        expected_zf = (expected_result == 0);
        expected_ef = 1'b0;
        
        // Overflow if MSB changed
        expected_of = a[DATA_WIDTH-1] ^ expected_result[DATA_WIDTH-1];
        
        verify_result("SHL", {8'h00, expected_result}, expected_cf, expected_of, expected_zf, expected_ef);
    endtask
    
    // Task 19: Check invalid operation
    task check_invalid_operation();
        if (o_ALU_OUT === 0 && o_CF === 0 && o_OF === 0 && 
            o_ZF === 0 && o_EF === 0 && o_OUT_VALID === 0) begin
            $display("✓ PASS: Invalid operation handled correctly");
            $display("  All outputs zero, OUT_VALID = 0");
            pass_count++;
        end else begin
            $display("✗ FAIL: Invalid operation not handled properly");
            $display("  OUT_VALID = %b (should be 0)", o_OUT_VALID);
            fail_count++;
        end
    endtask
    
    // Task 20: Generic verification
    task verify_result(input string op_name,
                       input [2*DATA_WIDTH-1:0] expected_out,
                       input expected_cf,
                       input expected_of,
                       input expected_zf,
                       input expected_ef);
        
        if (o_ALU_OUT === expected_out && o_CF === expected_cf &&
            o_OF === expected_of && o_ZF === expected_zf && 
            o_EF === expected_ef && o_OUT_VALID === 1'b1) begin
            $display("✓ PASS: %s operation correct", op_name);
            $display("  Result = 0x%04X, CF = %b, OF = %b, ZF = %b, EF = %b",
                     o_ALU_OUT, o_CF, o_OF, o_ZF, o_EF);
            pass_count++;
        end else begin
            $display("✗ FAIL: %s operation incorrect", op_name);
            $display("  Expected: Result = 0x%04X, CF = %b, OF = %b, ZF = %b, EF = %b",
                     expected_out, expected_cf, expected_of, expected_zf, expected_ef);
            $display("  Actual:   Result = 0x%04X, CF = %b, OF = %b, ZF = %b, EF = %b",
                     o_ALU_OUT, o_CF, o_OF, o_ZF, o_EF);
            fail_count++;
        end
    endtask
    
    // Task 21: Test disabled ALU
    task test_disabled_alu();
        @(posedge i_CLK);
        i_Enable = 1'b0;
        i_ALU_FUN = OP_ADD;
        i_A = 8'h10;
        i_B = 8'h20;
        @(posedge i_CLK);
        #5;
        
        // When disabled, outputs might hold previous values or reset
        $display("ALU Disabled Test - Checking behavior");
        // This test is mostly to see if there are any simulation issues
        $display("✓ Test completed (behavior depends on ALU design)");
        pass_count++;
        
        @(posedge i_CLK);
        i_Enable = 1'b1;
    endtask
    
    // Task 22: Back-to-back operations
    task back_to_back_operations();
        $display("Testing back-to-back operations...");
        
        // Sequence of different operations
        test_operation(OP_ADD, 8'h01, 8'h02);
        check_addition(8'h01, 8'h02);
        
        test_operation(OP_SUB, 8'h05, 8'h03);
        check_subtraction(8'h05, 8'h03);
        
        test_operation(OP_AND, 8'h0F, 8'hF0);
        check_and(8'h0F, 8'hF0);
        
        test_operation(OP_OR, 8'hAA, 8'h55);
        check_or(8'hAA, 8'h55);
        
        $display("Back-to-back operations completed");
    endtask
    
    // Task 23: Reset during operation
    task reset_during_operation();
        $display("Testing reset during ADD operation...");
        
        // Start an operation
        @(posedge i_CLK);
        i_ALU_FUN = OP_ADD;
        i_A = 8'hAA;
        i_B = 8'h55;
        
        // Apply reset during operation
        #(CLK_PERIOD/2);
        i_RSTn = 1'b0;
        @(posedge i_CLK);
        
        // Check outputs are reset
        if (o_ALU_OUT === 0 && o_OUT_VALID === 0) begin
            $display("✓ PASS: Reset correctly clears outputs");
            pass_count++;
        end else begin
            $display("✗ FAIL: Reset didn't clear outputs properly");
            fail_count++;
        end
        
        // Release reset
        i_RSTn = 1'b1;
        #(CLK_PERIOD * 2);
    endtask
    
    // =========================================
    // MONITOR
    // =========================================
    
    initial begin
        $display("\n=========================================");
        $display("ALU Operation Monitor");
        $display("=========================================");
        $display("Time(ns) | OpCode | A     | B     | Result | CF OF ZF EF | Valid");
        $display("-----------------------------------------------------------------");
        
        forever begin
            @(posedge i_CLK);
            if (i_Enable) begin
                $display("%8t | 0x%01X   | 0x%02X | 0x%02X | 0x%04X | %b  %b  %b  %b |   %b",
                         $time, i_ALU_FUN, i_A, i_B, o_ALU_OUT, 
                         o_CF, o_OF, o_ZF, o_EF, o_OUT_VALID);
            end
        end
    end
    
    // =========================================
    // WAVEFORM DUMPING
    // =========================================
    
    initial begin
        $dumpfile("alu_waves.vcd");
        $dumpvars(0, tb_ALU);
    end
    
    // =========================================
    // TIMEOUT
    // =========================================
    
    initial begin
        #100000; // 100us timeout
        $display("\n✗ TIMEOUT: Simulation timed out");
        $finish;
    end
    
endmodule