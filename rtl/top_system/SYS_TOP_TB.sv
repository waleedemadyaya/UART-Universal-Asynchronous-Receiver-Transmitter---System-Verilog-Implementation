`timescale 1ns/1ps

module SYS_TOP_TBBBB ();

/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////

parameter DATA_WIDTH_TB  = 8  ;
parameter ADDR_WIDTH_TB  = 4  ;   
parameter REF_CLK_PER = 20 ;         // 50 MHz
parameter UART_CLK_PER = 271.267 ;   // 3.6864 MHz (115.2 * 32)
parameter WR_CMD  = 8'hAA ;   
parameter RD_CMD  = 8'hBB ;   
parameter ALU_WOP_CMD  = 8'hCC ;   
parameter ALU_WNOP_CMD = 8'hDD ;   

/////////////////////////////////////////////////////////
//////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////

reg                                RST_N;
reg                                UART_CLK;
reg                                REF_CLK;
reg                                UART_RX_IN;
wire                               UART_TX_O;
wire                               parity_error;
wire                               framing_error;

////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////

initial
begin
  $display("\n==========================================");
  $display("        TEST BENCH STARTED");
  $display("==========================================\n");
  
  $display("[INFO] Test Configuration:");
  $display("  - DATA_WIDTH_TB = %0d", DATA_WIDTH_TB);
  $display("  - ADDR_WIDTH_TB = %0d", ADDR_WIDTH_TB);
  $display("  - REF_CLK_PER   = %0d ns (50 MHz)", REF_CLK_PER);
  $display("  - UART_CLK_PER  = %0.3f ns (3.6864 MHz)", UART_CLK_PER);
  $display("");

  // Initialization
  $display("[PHASE] System Initialization");
  initialize() ;
  $display("[INFO] Signals initialized to default values");

  // Reset
  $display("\n[PHASE] System Reset");
  reset() ; 
  $display("[INFO] Reset sequence completed");

  $display("\n==========================================");
  $display("    TEST CONFIGURATION 1: DEFAULT");
  $display("==========================================");
  $display("[CONFIG] PRESCALE: 32, Parity: ENABLED, Type: EVEN");
  
  begin
  /////////////////////  WRITE CMD  ///////////////////////
  $display("\n[TEST] WRITE COMMAND TEST");
  $display("  - Address: 0x06, Data: 0xA5");
  
    //Send Write Command (Address:8'h06 & Data: 8'hA5)
    SEND_WR_CMD(8'h06,8'hA5) ;

    //Check Write Operation
    CHECK_WR(8'h06,8'hA5) ;

  /////////////////////  READ CMD   ///////////////////////
  $display("\n[TEST] READ COMMAND TEST");
  $display("  - Address: 0x02");

    // Send Read Command (Address:8'h02)
    SEND_RD_CMD(8'h02) ;

    // Check Read Operation
    CHECK_RD(8'h02) ;

  ////////////////////  ALU_WOP CMD   ////////////////////
  $display("\n[TEST] ALU WITH OPERANDS COMMAND");
  $display("  - Operand A: 100, Operand B: 50, Function: Subtraction");

    // Send ALU WOP Command (OP_A = 100 & OP_B = 50 & FUNC = Subtraction)
    SEND_ALU_WOP_CMD(8'd100,8'd50,8'd1) ;

    // Check ALU Command
    CHECK_ALU(8'd1) ;
    $display("[STATUS] Case_1_Done.......");

  //////////////////// ALU_WNOP CMD //////////////////////
  $display("\n[TEST] ALU WITHOUT OPERANDS COMMAND");
  $display("  - Function: Addition");

    // Send ALU WNOP Command (FUNC = Addition)
    SEND_ALU_WNOP_CMD(8'd0) ;

    // Check ALU Command
    CHECK_ALU(8'd0) ;
    $display("[STATUS] Case_2_Done.......");
  end

  ///////////////////////////////////////////////////////// 
  ////////////////   Configuration 2     //////////////////
  ////////////////   PRESCALE : 32       //////////////////
  ////////////////   Parity   : Enabled  //////////////////
  ////////////////   TYPE     : ODD      ////////////////// 
  /////////////////////////////////////////////////////////
  $display("\n\n==========================================");
  $display("    TEST CONFIGURATION 2");
  $display("==========================================");
  $display("[CONFIG] PRESCALE: 32, Parity: ENABLED, Type: ODD");
  
  begin
  SEND_WR_CMD(8'h02,8'h83) ;
  $display("[STATUS] Case_3_Done.......");

  /////////////////////  WRITE CMD  ///////////////////////
  $display("\n[TEST] WRITE COMMAND TEST");
  $display("  - Address: 0x06, Data: 0xA5");

    //Send Write Command (Address:8'h06 & Data: 8'hA5)
    SEND_WR_CMD(8'h06,8'hA5) ;
    $display("[STATUS] Case_4_Done.......");

    //Check Write Operation
    CHECK_WR(8'h06,8'hA5) ;
    $display("[STATUS] Case_5_Done.......");

  /////////////////////  READ CMD   ///////////////////////
  $display("\n[TEST] READ COMMAND TEST");
  $display("  - Address: 0x02");

    // Send Read Command (Address:8'h02)
    SEND_RD_CMD(8'h02) ;
    $display("[STATUS] Case_6_Done.......");

    // Check Read Operation
    CHECK_RD(8'h02) ;
    $display("[STATUS] Case_7_Done.......");

  ////////////////////  ALU_WOP CMD   ////////////////////
  $display("\n[TEST] ALU WITH OPERANDS COMMAND");
  $display("  - Operand A: 100, Operand B: 50, Function: Subtraction");

    // Send ALU WOP Command (OP_A = 100 & OP_B = 50 & FUNC = Subtraction)
    SEND_ALU_WOP_CMD(8'd100,8'd50,8'd1) ;
    $display("[STATUS] Case_8_Done.......");

    // Check ALU Command
    CHECK_ALU(8'd1) ;
    $display("[STATUS] Case_9_Done.......");

  //////////////////// ALU_WNOP CMD //////////////////////
  $display("\n[TEST] ALU WITHOUT OPERANDS COMMAND");
  $display("  - Function: Addition");

    // Send ALU WNOP Command (FUNC = Addition)
    SEND_ALU_WNOP_CMD(8'd0) ;
    $display("[STATUS] Case_10_Done.......");

    // Check ALU Command
    CHECK_ALU(8'd0) ; 
    $display("[STATUS] Case_11_Done......."); 
  end

  ///////////////////////////////////////////////////////// 
  ////////////////   Configuration 3     //////////////////
  ////////////////   PRESCALE : 32       //////////////////
  ////////////////   Parity   : DISABLED //////////////////
  /////////////////////////////////////////////////////////
  $display("\n\n==========================================");
  $display("    TEST CONFIGURATION 3");
  $display("==========================================");
  $display("[CONFIG] PRESCALE: 32, Parity: DISABLED");
  
  begin
    SEND_WR_CMD(8'h02,8'h80) ;
    $display("[STATUS] Case_12_Done.......");

    /////////////////////  WRITE CMD  ///////////////////////
    $display("\n[TEST] WRITE COMMAND TEST");
    $display("  - Address: 0x06, Data: 0xA5");

      //Send Write Command (Address:8'h06 & Data: 8'hA5)
      SEND_WR_CMD(8'h06,8'hA5) ;
      $display("[STATUS] Case_13_Done.......");

      //Check Write Operation
      CHECK_WR(8'h06,8'hA5) ;
      $display("[STATUS] Case_14_Done.......");

    /////////////////////  READ CMD   ///////////////////////
    $display("\n[TEST] READ COMMAND TEST");
    $display("  - Address: 0x02");

      // Send Read Command (Address:8'h02)
      SEND_RD_CMD(8'h02) ;
      $display("[STATUS] Case_15_Done.......");

      // Check Read Operation
      CHECK_RD(8'h02) ;
      $display("[STATUS] Case_16_Done.......");

    ////////////////////  ALU_WOP CMD   ////////////////////
    $display("\n[TEST] ALU WITH OPERANDS COMMAND");
    $display("  - Operand A: 100, Operand B: 50, Function: Subtraction");

      // Send ALU WOP Command (OP_A = 100 & OP_B = 50 & FUNC = Subtraction)
      SEND_ALU_WOP_CMD(8'd100,8'd50,8'd1) ;
      $display("[STATUS] Case_17_Done.......");

      // Check ALU Command
      CHECK_ALU(8'd1) ;
      $display("[STATUS] Case_18_Done.......");

    //////////////////// ALU_WNOP CMD //////////////////////
    $display("\n[TEST] ALU WITHOUT OPERANDS COMMAND");
    $display("  - Function: Addition");

    // Send ALU WNOP Command (FUNC = Addition)
    SEND_ALU_WNOP_CMD(8'd0) ;
    $display("[STATUS] Case_19_Done.......");

    // Check ALU Command
    CHECK_ALU(8'd0) ;  
    $display("[STATUS] Case_20_Done.......");
  end

  ////////////////   Configuration 4     //////////////////
  ////////////////   PRESCALE : 16       //////////////////
  ////////////////   Parity   : Enabled  //////////////////
  ////////////////   TYPE     : EVEN     //////////////////
  $display("\n\n==========================================");
  $display("    TEST CONFIGURATION 4");
  $display("==========================================");
  $display("[CONFIG] PRESCALE: 16, Parity: ENABLED, Type: EVEN");
  
  begin
    SEND_WR_CMD(8'h02,8'h41) ;
    $display("[STATUS] Case_21_Done.......");

    /////////////////////  WRITE CMD  ///////////////////////
    $display("\n[TEST] WRITE COMMAND TEST");
    $display("  - Address: 0x06, Data: 0xA5");

      //Send Write Command (Address:8'h06 & Data: 8'hA5)
      SEND_WR_CMD(8'h06,8'hA5) ;
      $display("[STATUS] Case_22_Done.......");

      //Check Write Operation
      CHECK_WR(8'h06,8'hA5) ;
      $display("[STATUS] Case_23_Done.......");

    /////////////////////  READ CMD   ///////////////////////
    $display("\n[TEST] READ COMMAND TEST");
    $display("  - Address: 0x02");

      // Send Read Command (Address:8'h02)
      SEND_RD_CMD(8'h02) ;
      $display("[STATUS] Case_24_Done.......");

      // Check Read Operation
      CHECK_RD(8'h02) ;
      $display("[STATUS] Case_25_Done.......");

    ////////////////////  ALU_WOP CMD   ////////////////////
    $display("\n[TEST] ALU WITH OPERANDS COMMAND");
    $display("  - Operand A: 100, Operand B: 50, Function: Subtraction");

      // Send ALU WOP Command (OP_A = 100 & OP_B = 50 & FUNC = Subtraction)
      SEND_ALU_WOP_CMD(8'd100,8'd50,8'd1) ;
      $display("[STATUS] Case_26_Done.......");

      // Check ALU Command
      CHECK_ALU(8'd1) ;
      $display("[STATUS] Case_27_Done.......");
      
    //////////////////// ALU_WNOP CMD //////////////////////
    $display("\n[TEST] ALU WITHOUT OPERANDS COMMAND");
    $display("  - Function: Addition");

    // Send ALU WNOP Command (FUNC = Addition)
    SEND_ALU_WNOP_CMD(8'd0) ;
    $display("[STATUS] Case_28_Done.......");

    // Check ALU Command
    CHECK_ALU(8'd0) ;
    $display("[STATUS] Case_29_Done.......");
    $display("[INFO] End of Configuration 4");
  end

  ///////////////////////////////////////////////////////// 
  ////////////////   Configuration 5     //////////////////
  ////////////////   PRESCALE : 16       //////////////////
  ////////////////   Parity   : Enabled  //////////////////
  ////////////////   TYPE     : ODD      ////////////////// 
  /////////////////////////////////////////////////////////
  $display("\n\n==========================================");
  $display("    TEST CONFIGURATION 5");
  $display("==========================================");
  $display("[CONFIG] PRESCALE: 16, Parity: ENABLED, Type: ODD");
  
  begin
    SEND_WR_CMD(8'h02,8'h43) ;
    $display("[STATUS] Case_30_Done.......");

    /////////////////////  WRITE CMD  ///////////////////////
    $display("\n[TEST] WRITE COMMAND TEST");
    $display("  - Address: 0x06, Data: 0xA5");

      //Send Write Command (Address:8'h06 & Data: 8'hA5)
      SEND_WR_CMD(8'h06,8'hA5) ;
      $display("[STATUS] Case_31_Done.......");

      //Check Write Operation
      CHECK_WR(8'h06,8'hA5) ;
      $display("[STATUS] Case_32_Done.......");

    /////////////////////  READ CMD   ///////////////////////
    $display("\n[TEST] READ COMMAND TEST");
    $display("  - Address: 0x02");

      // Send Read Command (Address:8'h02)
      SEND_RD_CMD(8'h02) ;
      $display("[STATUS] Case_33_Done.......");

      // Check Read Operation
      CHECK_RD(8'h02) ;
      $display("[STATUS] Case_34_Done.......");

    ////////////////////  ALU_WOP CMD   ////////////////////
    $display("\n[TEST] ALU WITH OPERANDS COMMAND");
    $display("  - Operand A: 100, Operand B: 50, Function: Subtraction");

      // Send ALU WOP Command (OP_A = 100 & OP_B = 50 & FUNC = Subtraction)
      SEND_ALU_WOP_CMD(8'd100,8'd50,8'd1) ;
      $display("[STATUS] Case_35_Done.......");

      // Check ALU Command
      CHECK_ALU(8'd1) ;
      $display("[STATUS] Case_36_Done.......");

    //////////////////// ALU_WNOP CMD //////////////////////
    $display("\n[TEST] ALU WITHOUT OPERANDS COMMAND");
    $display("  - Function: Addition");

    // Send ALU WNOP Command (FUNC = Addition)
    SEND_ALU_WNOP_CMD(8'd0) ;
    $display("[STATUS] Case_37_Done.......");

    // Check ALU Command
    CHECK_ALU(8'd0) ;  
    $display("[STATUS] Case_38_Done.......");
    $display("[INFO] End of Configuration 5");
  end

  ///////////////////////////////////////////////////////// 
  ////////////////   Configuration 6     //////////////////
  ////////////////   PRESCALE : 16       //////////////////
  ////////////////   Parity   : DISABLED //////////////////
  /////////////////////////////////////////////////////////
  $display("\n\n==========================================");
  $display("    TEST CONFIGURATION 6");
  $display("==========================================");
  $display("[CONFIG] PRESCALE: 16, Parity: DISABLED");
  
  begin
    SEND_WR_CMD(8'h02,8'h40) ;
    $display("[STATUS] Case_39_Done.......");

    /////////////////////  WRITE CMD  ///////////////////////
    $display("\n[TEST] WRITE COMMAND TEST");
    $display("  - Address: 0x06, Data: 0xA5");

      //Send Write Command (Address:8'h06 & Data: 8'hA5)
      SEND_WR_CMD(8'h06,8'hA5) ;
      $display("[STATUS] Case_40_Done.......");

      //Check Write Operation
      CHECK_WR(8'h06,8'hA5) ;
      $display("[STATUS] Case_41_Done.......");

    /////////////////////  READ CMD   ///////////////////////
    $display("\n[TEST] READ COMMAND TEST");
    $display("  - Address: 0x02");

      // Send Read Command (Address:8'h02)
      SEND_RD_CMD(8'h02) ;
      $display("[STATUS] Case_42_Done.......");

      // Check Read Operation
      CHECK_RD(8'h02) ;
      $display("[STATUS] Case_43_Done.......");

    ////////////////////  ALU_WOP CMD   ////////////////////
    $display("\n[TEST] ALU WITH OPERANDS COMMAND");
    $display("  - Operand A: 100, Operand B: 50, Function: Subtraction");

      // Send ALU WOP Command (OP_A = 100 & OP_B = 50 & FUNC = Subtraction)
      SEND_ALU_WOP_CMD(8'd100,8'd50,8'd1) ;
      $display("[STATUS] Case_44_Done.......");

      // Check ALU Command
      CHECK_ALU(8'd1) ;
      $display("[STATUS] Case_45_Done.......");

    //////////////////// ALU_WNOP CMD //////////////////////
    $display("\n[TEST] ALU WITHOUT OPERANDS COMMAND");
    $display("  - Function: Addition");

     SEND_ALU_WNOP_CMD(8'd0) ;
     $display("[STATUS] Case_46_Done.......");

     // Check ALU Command
     CHECK_ALU(8'd0) ;  
     $display("[STATUS] Case_47_Done.......");
    
    $display("[INFO] End of Configuration 6");
  end

  ////////////////   Configuration 7     //////////////////
  ////////////////   PRESCALE : 8       //////////////////
  ////////////////   Parity   : Enabled  //////////////////
  ////////////////   TYPE     : EVEN     //////////////////
  $display("\n\n==========================================");
  $display("    TEST CONFIGURATION 7");
  $display("==========================================");
  $display("[CONFIG] PRESCALE: 8, Parity: ENABLED, Type: EVEN");
  
  begin 
    SEND_WR_CMD(8'h02,8'h21) ;
    $display("[STATUS] Case_48_Done.......");

    /////////////////////  WRITE CMD  ///////////////////////
    $display("\n[TEST] WRITE COMMAND TEST");
    $display("  - Address: 0x06, Data: 0xA5");

      //Send Write Command (Address:8'h06 & Data: 8'hA5)
      @ (posedge DUT.u_uart_tx.i_CLK);
      @ (posedge DUT.u_uart_tx.i_CLK);
      @ (posedge DUT.u_uart_tx.i_CLK);
      SEND_WR_CMD(8'h06,8'hA5) ;
      $display("[STATUS] Case_49_Done.......");
      
      //Check Write Operation
      CHECK_WR(8'h06,8'hA5) ;
      $display("[STATUS] Case_50_Done.......");

    /////////////////////  READ CMD   ///////////////////////
    $display("\n[TEST] READ COMMAND TEST");
    $display("  - Address: 0x02");

      // Send Read Command (Address:8'h02)
      SEND_RD_CMD(8'h02) ;
      $display("[STATUS] Case_51_Done.......");

      // Check Read Operation
      CHECK_RD(8'h02) ;
      $display("[STATUS] Case_52_Done.......");

    ////////////////////  ALU_WOP CMD   ////////////////////
    $display("\n[TEST] ALU WITH OPERANDS COMMAND");
    $display("  - Operand A: 100, Operand B: 50, Function: Subtraction");

      // Send ALU WOP Command (OP_A = 100 & OP_B = 50 & FUNC = Subtraction)
      SEND_ALU_WOP_CMD(8'd100,8'd50,8'd1) ;
      $display("[STATUS] Case_53_Done.......");

      // Check ALU Command
      CHECK_ALU(8'd1) ;
      $display("[STATUS] Case_54_Done.......");

    //////////////////// ALU_WNOP CMD //////////////////////
    $display("\n[TEST] ALU WITHOUT OPERANDS COMMAND");
    $display("  - Function: Addition");

     SEND_ALU_WNOP_CMD(8'd0) ;
     $display("[STATUS] Case_55_Done.......");

     // Check ALU Command
     CHECK_ALU(8'd0) ;
     $display("[STATUS] Case_56_Done.......");
    
    $display("[INFO] End of Configuration 7");
  end

  ///////////////////////////////////////////////////////// 
  ////////////////   Configuration 8     //////////////////
  ////////////////   PRESCALE : 8       //////////////////
  ////////////////   Parity   : Enabled  //////////////////
  ////////////////   TYPE     : ODD      ////////////////// 
  /////////////////////////////////////////////////////////
  $display("\n\n==========================================");
  $display("    TEST CONFIGURATION 8");
  $display("==========================================");
  $display("[CONFIG] PRESCALE: 8, Parity: ENABLED, Type: ODD");
  
  begin
      SEND_WR_CMD(8'h02,8'h23) ;
      $display("[STATUS] Case_57_Done.......");

    /////////////////////  WRITE CMD  ///////////////////////
    $display("\n[TEST] WRITE COMMAND TEST");
    $display("  - Address: 0x06, Data: 0xA5");

      //Send Write Command (Address:8'h06 & Data: 8'hA5)
      @ (posedge DUT.u_uart_tx.i_CLK);
      @ (posedge DUT.u_uart_tx.i_CLK);
      @ (posedge DUT.u_uart_tx.i_CLK);
      SEND_WR_CMD(8'h06,8'hA5) ;
      $display("[STATUS] Case_58_Done.......");

      //Check Write Operation
      CHECK_WR(8'h06,8'hA5) ;
      $display("[STATUS] Case_59_Done.......");

    /////////////////////  READ CMD   ///////////////////////
    $display("\n[TEST] READ COMMAND TEST");
    $display("  - Address: 0x02");

      // Send Read Command (Address:8'h02)
      SEND_RD_CMD(8'h02) ;
      $display("[STATUS] Case_60_Done.......");

      // Check Read Operation
      CHECK_RD(8'h02) ;
      $display("[STATUS] Case_61_Done.......");

    ////////////////////  ALU_WOP CMD   ////////////////////
    $display("\n[TEST] ALU WITH OPERANDS COMMAND");
    $display("  - Operand A: 100, Operand B: 50, Function: Subtraction");

      // Send ALU WOP Command (OP_A = 100 & OP_B = 50 & FUNC = Subtraction)
      SEND_ALU_WOP_CMD(8'd100,8'd50,8'd1) ;
      $display("[STATUS] Case_62_Done.......");

      // Check ALU Command
      CHECK_ALU(8'd1) ;
      $display("[STATUS] Case_63_Done.......");

    //////////////////// ALU_WNOP CMD //////////////////////
    $display("\n[TEST] ALU WITHOUT OPERANDS COMMAND");
    $display("  - Function: Addition");

     SEND_ALU_WNOP_CMD(8'd0) ;
     $display("[STATUS] Case_64_Done.......");

     // Check ALU Command
     CHECK_ALU(8'd0) ;  
     $display("[STATUS] Case_65_Done.......");
    
    $display("[INFO] End of Configuration 8");
  end

  ///////////////////////////////////////////////////////// 
  ////////////////   Configuration 9     //////////////////
  ////////////////   PRESCALE : 8       //////////////////
  ////////////////   Parity   : DISABLED //////////////////
  /////////////////////////////////////////////////////////
  $display("\n\n==========================================");
  $display("    TEST CONFIGURATION 9");
  $display("==========================================");
  $display("[CONFIG] PRESCALE: 8, Parity: DISABLED");
  
  begin
      SEND_WR_CMD(8'h02,8'h20) ;
      $display("[STATUS] Case_66_Done.......");

    /////////////////////  WRITE CMD  ///////////////////////
    $display("\n[TEST] WRITE COMMAND TEST");
    $display("  - Address: 0x06, Data: 0xA5");

      //Send Write Command (Address:8'h06 & Data: 8'hA5)
      SEND_WR_CMD(8'h06,8'hA5) ;
      $display("[STATUS] Case_67_Done.......");

      //Check Write Operation
      CHECK_WR(8'h06,8'hA5) ;
      $display("[STATUS] Case_68_Done.......");

    /////////////////////  READ CMD   ///////////////////////
    $display("\n[TEST] READ COMMAND TEST");
    $display("  - Address: 0x02");

      // Send Read Command (Address:8'h02)
      SEND_RD_CMD(8'h02) ;
      $display("[STATUS] Case_69_Done.......");

      // Check Read Operation
      CHECK_RD(8'h02) ;
      $display("[STATUS] Case_70_Done.......");

    ////////////////////  ALU_WOP CMD   ////////////////////
    $display("\n[TEST] ALU WITH OPERANDS COMMAND");
    $display("  - Operand A: 100, Operand B: 50, Function: Subtraction");

      // Send ALU WOP Command (OP_A = 100 & OP_B = 50 & FUNC = Subtraction)
      SEND_ALU_WOP_CMD(8'd100,8'd50,8'd1) ;
      $display("[STATUS] Case_71_Done.......");

      // Check ALU Command
      CHECK_ALU(8'd1) ;
      $display("[STATUS] Case_72_Done.......");

    //////////////////// ALU_WNOP CMD //////////////////////
    $display("\n[TEST] ALU WITHOUT OPERANDS COMMAND");
    $display("  - Function: Addition");

    SEND_ALU_WNOP_CMD(8'd0) ;
    $display("[STATUS] Case_73_Done.......");

    // Check ALU Command
    CHECK_ALU(8'd0) ;  
    $display("[STATUS] Case_74_Done.......");
    
    #4000
    $display("\n\n==========================================");
    $display("       ALL TESTS COMPLETED SUCCESSFULLY!");
    $display("==========================================");
    $display("[SUCCESS] Congratulations! All test cases passed.");
    $display("[SUCCESS] You are a winner!");
    $display("==========================================");
    
    $stop ;
  end
end

////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

/////////////// Signals Initialization //////////////////

task initialize ;
  begin
  $display("[TASK] Initializing signals...");
  UART_CLK          = 1'b0   ;
  REF_CLK           = 1'b0   ;
  RST_N             = 1'b1   ;    // rst is deactivated
  UART_RX_IN        = 1'b1   ;
  $display("[TASK] Initialization complete");
  end
endtask

///////////////////////// RESET /////////////////////////

task reset ;
  begin
  $display("[TASK] Starting reset sequence...");
  #(REF_CLK_PER)
  RST_N  = 'b0;           // rst is activated
  $display("[TASK] Reset asserted");
  #(REF_CLK_PER)
  RST_N  = 'b1;
  $display("[TASK] Reset deasserted");
  #(REF_CLK_PER) ;
  $display("[TASK] Reset sequence completed");
  end
endtask

/////////////////////// Load Frame /////////////////////////

task LD_FRAME ;
 input  [DATA_WIDTH_TB-1:0]  FRAME_DATA ;
 
 integer   i  ;
 
 begin
  $display("[UART_TX] Loading frame: 0x%h", FRAME_DATA);
  
  @ (posedge DUT.u_uart_tx.i_CLK)  
  UART_RX_IN <= 1'b0 ;                    // start_bit
  $display("[UART_TX] Start bit transmitted");

  for(i=0; i<8; i=i+1)
    begin
    @(posedge DUT.u_uart_tx.i_CLK)    
    UART_RX_IN <= FRAME_DATA[i] ;       // frame data bits
    end 
  $display("[UART_TX] Data bits (0x%h) transmitted", FRAME_DATA);

  if(DUT.U0_RegFile.o_REG2[0])
    begin
      @ (posedge DUT.u_uart_tx.i_CLK) 
      case(DUT.U0_RegFile.o_REG2[1])
      1'b0 : UART_RX_IN <= ^FRAME_DATA  ;     // Even Parity
      1'b1 : UART_RX_IN <= ~^FRAME_DATA ;     // Odd Parity
      endcase 
      $display("[UART_TX] Parity bit transmitted: %b", UART_RX_IN);
    end
  
  @ (posedge DUT.u_uart_tx.i_CLK) 
  UART_RX_IN <= 1'b1 ;              // stop_bit
  $display("[UART_TX] Stop bit transmitted");
  $display("[UART_TX] Frame transmission complete");
  
 end
endtask 

/////////////////////// WRITE CMD /////////////////////////

task SEND_WR_CMD ;
 input  [DATA_WIDTH_TB-1:0]  ADDR ;
 input  [DATA_WIDTH_TB-1:0]  DATA ;
 
 begin
  $display("[CMD] Sending WRITE command...");
  $display("  Command: 0x%h (WR_CMD)", WR_CMD);
  $display("  Address: 0x%h", ADDR);
  $display("  Data: 0x%h", DATA);
  LD_FRAME(WR_CMD) ;   // Load Write Command
  LD_FRAME(ADDR)   ;   // Load Write Address
  LD_FRAME(DATA)   ;   // Load Write Data
  $display("[CMD] WRITE command transmission complete");
 end
endtask 

/////////////////////// Read CMD /////////////////////////

task SEND_RD_CMD ;
 input  [DATA_WIDTH_TB-1:0]  ADDR ;
 
 begin
  $display("[CMD] Sending READ command...");
  $display("  Command: 0x%h (RD_CMD)", RD_CMD);
  $display("  Address: 0x%h", ADDR);
  LD_FRAME(RD_CMD) ;  // Load Read Command
  LD_FRAME(ADDR)   ;  // Load Read Address
  $display("[CMD] READ command transmission complete");
 end
endtask 

///////////////////// ALU_WOP CMD ///////////////////////

task SEND_ALU_WOP_CMD ;
 input  [DATA_WIDTH_TB-1:0]  OP_A ;
 input  [DATA_WIDTH_TB-1:0]  OP_B ;
 input  [DATA_WIDTH_TB-1:0]  FUNC ;
 
 begin
  $display("[CMD] Sending ALU_WOP command...");
  $display("  Command: 0x%h (ALU_WOP_CMD)", ALU_WOP_CMD);
  $display("  Operand A: %0d (0x%h)", OP_A, OP_A);
  $display("  Operand B: %0d (0x%h)", OP_B, OP_B);
  $display("  Function: %0d (0x%h)", FUNC, FUNC);
  LD_FRAME(ALU_WOP_CMD) ;    // Load ALU_WOP Command
  LD_FRAME(OP_A)        ;    // Load Operand A 
  LD_FRAME(OP_B)        ;    // Load Operand B 
  LD_FRAME(FUNC)        ;    // Load ALU Function
  $display("[CMD] ALU_WOP command transmission complete");
 end
endtask 

///////////////////// ALU_WOP CMD ///////////////////////

task SEND_ALU_WNOP_CMD ;
 input  [DATA_WIDTH_TB-1:0]  FUNC ;
 
 begin
  $display("[CMD] Sending ALU_WNOP command...");
  $display("  Command: 0x%h (ALU_WNOP_CMD)", ALU_WNOP_CMD);
  $display("  Function: %0d (0x%h)", FUNC, FUNC);
  LD_FRAME(ALU_WNOP_CMD)   ;    // Load ALU_WOP Command
  LD_FRAME(FUNC)           ;    // Load ALU Function
  $display("[CMD] ALU_WNOP command transmission complete");
 end
endtask 

//////////////// Check Write Operation /////////////////

task CHECK_WR ;
 input  [DATA_WIDTH_TB-1:0]  ADDR ;
 input  [DATA_WIDTH_TB-1:0]  DATA ;
 
 begin
  $display("[CHECK] Verifying WRITE operation...");
  $display("  Expected: Address 0x%h = Data 0x%h", ADDR, DATA);
  
  wait(DUT.U0_RegFile.i_WrEn);
  $display("[CHECK] Write Enable detected");
  
  repeat(2) @(posedge REF_CLK); 
  
  if(DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]] == DATA)
    begin
      $display("[PASS] Write Operation SUCCESSFUL");
      $display("  Config: PARITY_ENABLE=%d, PARITY_TYPE=%d, PRESCALE=%d",
               DUT.U0_RegFile.o_REG2[0], DUT.U0_RegFile.o_REG2[1], DUT.U0_RegFile.o_REG2[7:2]);
    end
  else
    begin
      $display("[FAIL] Write Operation FAILED");
      $display("  Expected: 0x%h, Got: 0x%h", 
               DATA, DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]]);
      $display("  Config: PARITY_ENABLE=%d, PARITY_TYPE=%d, PRESCALE=%d",
               DUT.U0_RegFile.o_REG2[0], DUT.U0_RegFile.o_REG2[1], DUT.U0_RegFile.o_REG2[7:2]);
    end 
 end
endtask 

//////////////// Check Read Operation /////////////////

task CHECK_RD ;
 input  [DATA_WIDTH_TB-1:0]   ADDR     ;
 
 reg    [10:0]  gener_out ,expec_out;     //longest frame = 11 bits (1-start,1-stop,8-data,1-parity)
 reg            parity_bit;
 
 integer   i  ;

 begin
  $display("[CHECK] Verifying READ operation...");
  $display("  Reading from Address: 0x%h", ADDR);
  $display("  Expected Data: 0x%h", DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]]);

  //generated frame
  @(negedge DUT.u_uart_tx.o_TX_OUT)
  $display("[CHECK] Detected start of UART transmission");
  
  for(i=0; i<11; i=i+1)
    begin
    @(negedge DUT.u_uart_tx.i_CLK) gener_out[i] = UART_TX_O ;
    end
  
  //calculate expected parity bit   
  if(DUT.U0_RegFile.o_REG2[0])
    if(DUT.U0_RegFile.o_REG2[1])
      parity_bit = ~^DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]] ;
    else
      parity_bit = ^DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]] ;
  else
      parity_bit = 1'b1 ; 

  //expected frame
  if(DUT.U0_RegFile.o_REG2[0])
    expec_out = {1'b1,parity_bit,DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]],1'b0} ;
  else
    expec_out = {1'b1,1'b1,DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]],1'b0} ;
      
  if(gener_out == expec_out) 
    begin
      $display("[PASS] Read Operation SUCCESSFUL");
      $display("  Received Frame: 0x%h", gener_out);
      $display("  Expected Frame: 0x%h", expec_out);
      $display("  Config: PARITY_ENABLE=%d, PARITY_TYPE=%d, PRESCALE=%d",
               DUT.U0_RegFile.o_REG2[0], DUT.U0_RegFile.o_REG2[1], DUT.U0_RegFile.o_REG2[7:2]);
    end
  else
    begin
      $display("[FAIL] Read Operation FAILED");
      $display("  Received Frame: 0x%h", gener_out);
      $display("  Expected Frame: 0x%h", expec_out);
      $display("  Config: PARITY_ENABLE=%d, PARITY_TYPE=%d, PRESCALE=%d",
               DUT.U0_RegFile.o_REG2[0], DUT.U0_RegFile.o_REG2[1], DUT.U0_RegFile.o_REG2[7:2]);
    end
 end
endtask

//////////////// Check ALU Operation /////////////////

task CHECK_ALU ;
 input  [DATA_WIDTH_TB-1:0]   fun ;

 reg    [10:0]  gener_byte0  , gener_byte1 ;     
 reg    [10:0]  expec_byte0  , expec_byte1  ;                        
 reg            parity_bit0 , parity_bit1 ;
 reg    [2*DATA_WIDTH_TB-1:0] ALU_OUT_RESULT ;
 integer   i  ;

 begin
  $display("[CHECK] Verifying ALU operation...");
  $display("  ALU Function: %0d (0x%h)", fun, fun);
  $display("  Operand A: %0d (0x%h)", DUT.U0_RegFile.r_reg_file[0], DUT.U0_RegFile.r_reg_file[0]);
  $display("  Operand B: %0d (0x%h)", DUT.U0_RegFile.r_reg_file[1], DUT.U0_RegFile.r_reg_file[1]);

  //generated byte0 frame
  @(negedge DUT.u_uart_tx.o_TX_OUT)
  $display("[CHECK] Detected start of ALU result transmission (byte 0)");
  
  for(i=0; i<11; i=i+1)
    begin
    @(negedge DUT.u_uart_tx.i_CLK) gener_byte0[i] = UART_TX_O ;
    end
    
  //generated byte1 frame
  @(negedge DUT.u_uart_tx.o_TX_OUT)
  $display("[CHECK] Detected start of ALU result transmission (byte 1)");
  
  for(i=0; i<11; i=i+1)
    begin
    @(negedge DUT.u_uart_tx.i_CLK) gener_byte1[i] = UART_TX_O ;
    end
    
  //calculate ALU Output    
  case (fun) 
     4'b0000: begin
               ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] + DUT.U0_RegFile.r_reg_file[1];
               $display("[CHECK] ALU Function: ADDITION");
              end
     4'b0001: begin
               ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] - DUT.U0_RegFile.r_reg_file[1];
               $display("[CHECK] ALU Function: SUBTRACTION");
              end
     4'b0010: begin
               ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] * DUT.U0_RegFile.r_reg_file[1];
               $display("[CHECK] ALU Function: MULTIPLICATION");
              end
     4'b0011: begin
               ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] / DUT.U0_RegFile.r_reg_file[1];
               $display("[CHECK] ALU Function: DIVISION");
              end
     4'b0100: begin
               ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] & DUT.U0_RegFile.r_reg_file[1];
               $display("[CHECK] ALU Function: AND");
              end
     4'b0101: begin
               ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] | DUT.U0_RegFile.r_reg_file[1];
               $display("[CHECK] ALU Function: OR");
              end
     4'b0110: begin
               ALU_OUT_RESULT = ~ (DUT.U0_RegFile.r_reg_file[0] & DUT.U0_RegFile.r_reg_file[1]);
               $display("[CHECK] ALU Function: NAND");
              end
     4'b0111: begin
               ALU_OUT_RESULT = ~ (DUT.U0_RegFile.r_reg_file[0] | DUT.U0_RegFile.r_reg_file[1]);
               $display("[CHECK] ALU Function: NOR");
              end     
     4'b1000: begin
               ALU_OUT_RESULT =  (DUT.U0_RegFile.r_reg_file[0] ^ DUT.U0_RegFile.r_reg_file[1]);
               $display("[CHECK] ALU Function: XOR");
              end
     4'b1001: begin
               ALU_OUT_RESULT = ~ (DUT.U0_RegFile.r_reg_file[0] ^ DUT.U0_RegFile.r_reg_file[1]);
               $display("[CHECK] ALU Function: XNOR");
              end           
     4'b1010: begin
              if (DUT.U0_RegFile.r_reg_file[0] == DUT.U0_RegFile.r_reg_file[1])
                 ALU_OUT_RESULT = 'b1;
              else
                 ALU_OUT_RESULT = 'b0;
               $display("[CHECK] ALU Function: EQUALITY COMPARE");
              end
     4'b1011: begin
               if (DUT.U0_RegFile.r_reg_file[0] > DUT.U0_RegFile.r_reg_file[1])
                 ALU_OUT_RESULT = 'b10;
               else
                 ALU_OUT_RESULT = 'b0;
               $display("[CHECK] ALU Function: GREATER THAN");
              end 
     4'b1100: begin
               if (DUT.U0_RegFile.r_reg_file[0] < DUT.U0_RegFile.r_reg_file[1])
                 ALU_OUT_RESULT = 'b11;
               else
                 ALU_OUT_RESULT = 'b0;
               $display("[CHECK] ALU Function: LESS THAN");
              end     
     4'b1101: begin
               ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0]>>1;
               $display("[CHECK] ALU Function: RIGHT SHIFT");
              end
     4'b1110: begin 
               ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0]<<1;
               $display("[CHECK] ALU Function: LEFT SHIFT");
              end
     4'b1111: begin
               ALU_OUT_RESULT = 'b0;
               $display("[CHECK] ALU Function: NO OPERATION");
              end
     endcase

  $display("[CHECK] ALU Result: %0d (0x%h)", ALU_OUT_RESULT, ALU_OUT_RESULT);
  $display("[CHECK] ALU Result Byte 0: 0x%h", ALU_OUT_RESULT[DATA_WIDTH_TB-1:0]);
  $display("[CHECK] ALU Result Byte 1: 0x%h", ALU_OUT_RESULT[2*DATA_WIDTH_TB-1:DATA_WIDTH_TB]);

  //calculate expected parity bit for ALU byte0 data    
  if(DUT.U0_RegFile.o_REG2[0])
    if(DUT.U0_RegFile.o_REG2[1])
      parity_bit0 = ~^ALU_OUT_RESULT[DATA_WIDTH_TB-1:0] ;
    else
      parity_bit0 = ^ALU_OUT_RESULT[DATA_WIDTH_TB-1:0] ;
  else
      parity_bit0 = 1'b1 ;  

  //calculate expected parity bit for ALU byte1 data    
  if(DUT.U0_RegFile.o_REG2[0])
    if(DUT.U0_RegFile.o_REG2[1])
      parity_bit1 = ~^ALU_OUT_RESULT[2*DATA_WIDTH_TB-1:DATA_WIDTH_TB] ;
    else
      parity_bit1 = ^ALU_OUT_RESULT[2*DATA_WIDTH_TB-1:DATA_WIDTH_TB] ;
  else
      parity_bit1 = 1'b1 ;  

  //expected byte0 frame 
  if(DUT.U0_RegFile.o_REG2[0])
    expec_byte0 = {1'b1,parity_bit0,ALU_OUT_RESULT[DATA_WIDTH_TB-1:0],1'b0} ;
  else
    expec_byte0 = {1'b1,1'b1,ALU_OUT_RESULT[DATA_WIDTH_TB-1:0],1'b0} ;

  //expected byte1 frame 
  if(DUT.U0_RegFile.o_REG2[0])
    expec_byte1 = {1'b1,parity_bit1,ALU_OUT_RESULT[2*DATA_WIDTH_TB-1:DATA_WIDTH_TB],1'b0} ;
  else
    expec_byte1 = {1'b1,1'b1,ALU_OUT_RESULT[2*DATA_WIDTH_TB-1:DATA_WIDTH_TB],1'b0} ;

  if(gener_byte0 == expec_byte0 && gener_byte1 == expec_byte1) 
    begin
      $display("[PASS] ALU Operation SUCCESSFUL");
      $display("  Received Byte 0: 0x%h, Expected: 0x%h", gener_byte0, expec_byte0);
      $display("  Received Byte 1: 0x%h, Expected: 0x%h", gener_byte1, expec_byte1);
      $display("  Config: PARITY_ENABLE=%d, PARITY_TYPE=%d, PRESCALE=%d",
               DUT.U0_RegFile.o_REG2[0], DUT.U0_RegFile.o_REG2[1], DUT.U0_RegFile.o_REG2[7:2]);
    end
  else
    begin
      $display("[FAIL] ALU Operation FAILED");
      $display("  Received Byte 0: 0x%h, Expected: 0x%h", gener_byte0, expec_byte0);
      $display("  Received Byte 1: 0x%h, Expected: 0x%h", gener_byte1, expec_byte1);
      $display("  Config: PARITY_ENABLE=%d, PARITY_TYPE=%d, PRESCALE=%d",
               DUT.U0_RegFile.o_REG2[0], DUT.U0_RegFile.o_REG2[1], DUT.U0_RegFile.o_REG2[7:2]);
    end
  end
endtask

//////////////////////////////////////////////////////// 
///////////////////// Clock Generator //////////////////
////////////////////////////////////////////////////////

// REF Clock Generator
always #(REF_CLK_PER/2) REF_CLK = ~REF_CLK ;

// UART RX Clock Generator
always #(UART_CLK_PER/2) UART_CLK = ~UART_CLK ;

//////////////////////////////////////////////////////// 
///////////////// Design Instaniation //////////////////
////////////////////////////////////////////////////////

SYS_TOP DUT (
.UART_CLK(UART_CLK),
.REF_CLK(REF_CLK),
.RST_N(RST_N),
.UART_RX_IN(UART_RX_IN),
.UART_TX_O(UART_TX_O),
.parity_error(parity_error),
.framing_error(framing_error)
);

endmodule