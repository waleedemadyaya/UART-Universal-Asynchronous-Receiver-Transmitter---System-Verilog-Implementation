`timescale 1ns/1ps

module SYS_TOP_TBBBB ();

// ... [Parameters and Signals remain exactly as you provided] ...
parameter DATA_WIDTH_TB  = 8  ;
parameter ADDR_WIDTH_TB  = 4  ;   
parameter REF_CLK_PER = 20 ;         
parameter UART_CLK_PER = 271.267 ;   
parameter WR_CMD  = 8'hAA ;   
parameter RD_CMD  = 8'hBB ;   
parameter ALU_WOP_CMD  = 8'hCC ;   
parameter ALU_WNOP_CMD = 8'hDD ;   

reg         RST_N;
reg         UART_CLK;
reg         REF_CLK;
reg         UART_RX_IN;
wire        UART_TX_O;
wire        parity_error;
wire        framing_error;

// Professional Tracking variables (No effect on DUT logic)
integer tests_passed = 0;
integer tests_failed = 0;

initial
begin
  $display("\n============================================================");
  $display("     SYSTEM LEVEL VERIFICATION STARTING - IC DESIGN     ");
  $display("============================================================\n");

  initialize();
  reset(); 

  // --- Configuration 1 ---
  print_config(1, 32, "Enabled", "EVEN");
  SEND_WR_CMD(8'h06, 8'hA5);
  CHECK_WR(8'h06, 8'hA5);

  SEND_RD_CMD(8'h02);
  CHECK_RD(8'h02);

  SEND_ALU_WOP_CMD(8'd100, 8'd50, 8'd1);
  CHECK_ALU(8'd1);

  SEND_ALU_WNOP_CMD(8'd0);
  CHECK_ALU(8'd0);

  // --- Configuration 2 ---
  print_config(2, 32, "Enabled", "ODD");
  SEND_WR_CMD(8'h02, 8'h83);
  SEND_WR_CMD(8'h06, 8'hA5);
  CHECK_WR(8'h06, 8'hA5);
  SEND_RD_CMD(8'h02);
  CHECK_RD(8'h02);
  SEND_ALU_WOP_CMD(8'd100, 8'd50, 8'd1);
  CHECK_ALU(8'd1);
  SEND_ALU_WNOP_CMD(8'd0);
  CHECK_ALU(8'd0);

  // --- Configuration 3 ---
  print_config(3, 32, "Disabled", "N/A");
  SEND_WR_CMD(8'h02, 8'h80);
  SEND_WR_CMD(8'h06, 8'hA5);
  CHECK_WR(8'h06, 8'hA5);
  SEND_RD_CMD(8'h02);
  CHECK_RD(8'h02);
  SEND_ALU_WOP_CMD(8'd100, 8'd50, 8'd1);
  CHECK_ALU(8'd1);
  SEND_ALU_WNOP_CMD(8'd0);
  CHECK_ALU(8'd0);

  // --- Configuration 4 ---
  print_config(4, 16, "Enabled", "EVEN");
  SEND_WR_CMD(8'h02, 8'h41);
  SEND_WR_CMD(8'h06, 8'hA5);
  CHECK_WR(8'h06, 8'hA5);
  SEND_RD_CMD(8'h02);
  CHECK_RD(8'h02);
  SEND_ALU_WOP_CMD(8'd100, 8'd50, 8'd1);
  CHECK_ALU(8'd1);
  SEND_ALU_WNOP_CMD(8'd0);
  CHECK_ALU(8'd0);

  // --- Configuration 5 ---
  print_config(5, 16, "Enabled", "ODD");
  SEND_WR_CMD(8'h02, 8'h43);
  SEND_WR_CMD(8'h06, 8'hA5);
  CHECK_WR(8'h06, 8'hA5);
  SEND_RD_CMD(8'h02);
  CHECK_RD(8'h02);
  SEND_ALU_WOP_CMD(8'd100, 8'd50, 8'd1);
  CHECK_ALU(8'd1);
  SEND_ALU_WNOP_CMD(8'd0);
  CHECK_ALU(8'd0);

  // --- Configuration 6 ---
  print_config(6, 16, "Disabled", "N/A");
  SEND_WR_CMD(8'h02, 8'h40);
  SEND_WR_CMD(8'h06, 8'hA5);
  CHECK_WR(8'h06, 8'hA5);
  SEND_RD_CMD(8'h02);
  CHECK_RD(8'h02);
  SEND_ALU_WOP_CMD(8'd100, 8'd50, 8'd1);
  CHECK_ALU(8'd1);
  SEND_ALU_WNOP_CMD(8'd0);
  CHECK_ALU(8'd0);

  // --- Configuration 7 ---
  print_config(7, 8, "Enabled", "EVEN");
  SEND_WR_CMD(8'h02, 8'h21);
  @ (posedge DUT.u_uart_tx.i_CLK);
  @ (posedge DUT.u_uart_tx.i_CLK);
  @ (posedge DUT.u_uart_tx.i_CLK);
  SEND_WR_CMD(8'h06, 8'hA5);
  CHECK_WR(8'h06, 8'hA5);
  SEND_RD_CMD(8'h02);
  CHECK_RD(8'h02);
  SEND_ALU_WOP_CMD(8'd100, 8'd50, 8'd1);
  CHECK_ALU(8'd1);
  SEND_ALU_WNOP_CMD(8'd0);
  CHECK_ALU(8'd0);

  // --- Configuration 8 ---
  print_config(8, 8, "Enabled", "ODD");
  SEND_WR_CMD(8'h02, 8'h23);
  @ (posedge DUT.u_uart_tx.i_CLK);
  @ (posedge DUT.u_uart_tx.i_CLK);
  @ (posedge DUT.u_uart_tx.i_CLK);
  SEND_WR_CMD(8'h06, 8'hA5);
  CHECK_WR(8'h06, 8'hA5);
  SEND_RD_CMD(8'h02);
  CHECK_RD(8'h02);
  SEND_ALU_WOP_CMD(8'd100, 8'd50, 8'd1);
  CHECK_ALU(8'd1);
  SEND_ALU_WNOP_CMD(8'd0);
  CHECK_ALU(8'd0);

  // --- Configuration 9 ---
  print_config(9, 8, "Disabled", "N/A");
  SEND_WR_CMD(8'h02, 8'h20);
  SEND_WR_CMD(8'h06, 8'hA5);
  CHECK_WR(8'h06, 8'hA5);
  SEND_RD_CMD(8'h02);
  CHECK_RD(8'h02);
  SEND_ALU_WOP_CMD(8'd100, 8'd50, 8'd1);
  CHECK_ALU(8'd1);
  SEND_ALU_WNOP_CMD(8'd0);
  CHECK_ALU(8'd0);

  #4000
  $display("\n============================================================");
  $display("                  FINAL VERIFICATION REPORT                 ");
  $display("============================================================");
  $display(" TOTAL TESTCASES : %d", (tests_passed + tests_failed));
  $display(" PASSED          : %d", tests_passed);
  $display(" FAILED          : %d", tests_failed);
  $display("============================================================");
  if(tests_failed == 0) $display(" RESULT: [PASS] - CHAMPION! YOU ARE THE WINNER!");
  else                  $display(" RESULT: [FAIL] - CHECK TRANSCRIPT FOR ERRORS");
  $display("============================================================\n");
  $stop;
end

////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

// New Task for reporting configurations
task print_config;
  input integer cfg_num;
  input integer prescale;
  input string parity;
  input string p_type;
  begin
    $display("\n[TIME: %0t] --- Starting Configuration %0d ---", $time, cfg_num);
    $display("[CFG] Prescale: %0d | Parity: %s | Type: %s", prescale, parity, p_type);
    $display("------------------------------------------------------------");
  end
endtask

task initialize;
  begin
    UART_CLK = 1'b0;
    REF_CLK = 1'b0;
    RST_N = 1'b1;
    UART_RX_IN = 1'b1;
  end
endtask

task reset;
  begin
    #(REF_CLK_PER) RST_N = 'b0;
    #(REF_CLK_PER) RST_N = 'b1;
    #(REF_CLK_PER);
    $display("[TIME: %0t] System Reset Completed.", $time);
  end
endtask

// ... [LD_FRAME, SEND_WR_CMD, SEND_RD_CMD, SEND_ALU_WOP_CMD, SEND_ALU_WNOP_CMD remain exactly as original] ...
task LD_FRAME ;
 input  [DATA_WIDTH_TB-1:0]  FRAME_DATA ;
 integer   i  ;
 begin
  @ (posedge DUT.u_uart_tx.i_CLK)  
  UART_RX_IN <= 1'b0 ; 
  for(i=0; i<8; i=i+1)
    begin
    @(posedge DUT.u_uart_tx.i_CLK)    
    UART_RX_IN <= FRAME_DATA[i] ; 
    end 
  if(DUT.U0_RegFile.o_REG2[0])
    begin
      @ (posedge DUT.u_uart_tx.i_CLK) 
      case(DUT.U0_RegFile.o_REG2[1])
      1'b0 : UART_RX_IN <= ^FRAME_DATA  ; 
      1'b1 : UART_RX_IN <= ~^FRAME_DATA ; 
      endcase 
    end
  @ (posedge DUT.u_uart_tx.i_CLK) 
  UART_RX_IN <= 1'b1 ; 
 end
endtask 

task SEND_WR_CMD ;
 input  [DATA_WIDTH_TB-1:0]  ADDR ;
 input  [DATA_WIDTH_TB-1:0]  DATA ;
 begin
  $display("[TIME: %0t] CMD: WRITE | Addr: 0x%h | Data: 0x%h", $time, ADDR, DATA);
  LD_FRAME(WR_CMD) ; 
  LD_FRAME(ADDR)   ; 
  LD_FRAME(DATA)   ; 
 end
endtask 

task SEND_RD_CMD ;
 input  [DATA_WIDTH_TB-1:0]  ADDR ;
 begin
  $display("[TIME: %0t] CMD: READ | Addr: 0x%h", $time, ADDR);
  LD_FRAME(RD_CMD) ;
  LD_FRAME(ADDR)   ;
 end
endtask 

task SEND_ALU_WOP_CMD ;
 input  [DATA_WIDTH_TB-1:0]  OP_A ;
 input  [DATA_WIDTH_TB-1:0]  OP_B ;
 input  [DATA_WIDTH_TB-1:0]  FUNC ;
 begin
  $display("[TIME: %0t] CMD: ALU_WOP | OP_A: %d | OP_B: %d | Func: %d", $time, OP_A, OP_B, FUNC);
  LD_FRAME(ALU_WOP_CMD) ;
  LD_FRAME(OP_A)        ;
  LD_FRAME(OP_B)        ;
  LD_FRAME(FUNC)        ;
 end
endtask 

task SEND_ALU_WNOP_CMD ;
 input  [DATA_WIDTH_TB-1:0]  FUNC ;
 begin
  $display("[TIME: %0t] CMD: ALU_WNOP | Func: %d", $time, FUNC);
  LD_FRAME(ALU_WNOP_CMD)   ;
  LD_FRAME(FUNC)           ;
 end
endtask 

task CHECK_WR ;
 input  [DATA_WIDTH_TB-1:0]  ADDR ;
 input  [DATA_WIDTH_TB-1:0]  DATA ;
 begin
  wait(DUT.U0_RegFile.i_WrEn);
  repeat(2) @(posedge REF_CLK); 
  if(DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]] == DATA) begin
      $display(" >>> [PASS] Write Success at Addr: 0x%h", ADDR);
      tests_passed = tests_passed + 1;
  end else begin
      $display(" >>> [FAIL] Write Mismatch! Addr: 0x%h | Exp: 0x%h | Got: 0x%h", ADDR, DATA, DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]]);
      tests_failed = tests_failed + 1;
  end 
 end
endtask 

task CHECK_RD ;
 input  [DATA_WIDTH_TB-1:0]   ADDR     ;
 reg    [10:0]  gener_out ,expec_out; 
 reg            parity_bit;
 integer   i  ;
 begin
  @(negedge DUT.u_uart_tx.o_TX_OUT)
  for(i=0; i<11; i=i+1) begin
    @(negedge DUT.u_uart_tx.i_CLK) gener_out[i] = UART_TX_O ;
  end
  
  if(DUT.U0_RegFile.o_REG2[0])
    if(DUT.U0_RegFile.o_REG2[1]) parity_bit = ~^DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]] ;
    else                         parity_bit = ^DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]] ;
  else                           parity_bit = 1'b1 ; 
  
  if(DUT.U0_RegFile.o_REG2[0]) expec_out = {1'b1,parity_bit,DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]],1'b0} ;
  else                         expec_out = {1'b1,1'b1,DUT.U0_RegFile.r_reg_file[ADDR[ADDR_WIDTH_TB-1:0]],1'b0} ;
      
  if(gener_out == expec_out) begin
      $display(" >>> [PASS] Read Match! Data Received: 0x%h", gener_out[8:1]);
      tests_passed = tests_passed + 1;
  end else begin
      $display(" >>> [FAIL] Read Mismatch! Exp: %h | Got: %h", expec_out, gener_out);
      tests_failed = tests_failed + 1;
  end
 end
endtask

task CHECK_ALU ;
 input  [DATA_WIDTH_TB-1:0]   fun ;
 reg    [10:0]  gener_byte0   , gener_byte1 ;     
 reg    [10:0]  expec_byte0   , expec_byte1  ;                        
 reg            parity_bit0 , parity_bit1 ;
 reg    [2*DATA_WIDTH_TB-1:0] ALU_OUT_RESULT ;
 integer   i  ;
 begin
  @(negedge DUT.u_uart_tx.o_TX_OUT)
  for(i=0; i<11; i=i+1) @(negedge DUT.u_uart_tx.i_CLK) gener_byte0[i] = UART_TX_O ;
    
  @(negedge DUT.u_uart_tx.o_TX_OUT)
  for(i=0; i<11; i=i+1) @(negedge DUT.u_uart_tx.i_CLK) gener_byte1[i] = UART_TX_O ;
    
  case (fun) 
     4'b0000: ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] + DUT.U0_RegFile.r_reg_file[1];
     4'b0001: ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] - DUT.U0_RegFile.r_reg_file[1];
     4'b0010: ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] * DUT.U0_RegFile.r_reg_file[1];
     4'b0011: ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] / DUT.U0_RegFile.r_reg_file[1];
     4'b0100: ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] & DUT.U0_RegFile.r_reg_file[1];
     4'b0101: ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0] | DUT.U0_RegFile.r_reg_file[1];
     4'b0110: ALU_OUT_RESULT = ~(DUT.U0_RegFile.r_reg_file[0] & DUT.U0_RegFile.r_reg_file[1]);
     4'b0111: ALU_OUT_RESULT = ~(DUT.U0_RegFile.r_reg_file[0] | DUT.U0_RegFile.r_reg_file[1]);
     4'b1000: ALU_OUT_RESULT = (DUT.U0_RegFile.r_reg_file[0] ^ DUT.U0_RegFile.r_reg_file[1]);
     4'b1001: ALU_OUT_RESULT = ~(DUT.U0_RegFile.r_reg_file[0] ^ DUT.U0_RegFile.r_reg_file[1]);
     4'b1010: ALU_OUT_RESULT = (DUT.U0_RegFile.r_reg_file[0] == DUT.U0_RegFile.r_reg_file[1]) ? 'b1 : 'b0;
     4'b1011: ALU_OUT_RESULT = (DUT.U0_RegFile.r_reg_file[0] >  DUT.U0_RegFile.r_reg_file[1]) ? 'b10 : 'b0;
     4'b1100: ALU_OUT_RESULT = (DUT.U0_RegFile.r_reg_file[0] <  DUT.U0_RegFile.r_reg_file[1]) ? 'b11 : 'b0;
     4'b1101: ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0]>>1;
     4'b1110: ALU_OUT_RESULT = DUT.U0_RegFile.r_reg_file[0]<<1;
     4'b1111: ALU_OUT_RESULT = 'b0;
  endcase

  if(DUT.U0_RegFile.o_REG2[0]) begin
    parity_bit0 = (DUT.U0_RegFile.o_REG2[1]) ? ~^ALU_OUT_RESULT[7:0] : ^ALU_OUT_RESULT[7:0];
    parity_bit1 = (DUT.U0_RegFile.o_REG2[1]) ? ~^ALU_OUT_RESULT[15:8] : ^ALU_OUT_RESULT[15:8];
  end else begin
    parity_bit0 = 1'b1; parity_bit1 = 1'b1;
  end

  expec_byte0 = {1'b1,parity_bit0,ALU_OUT_RESULT[7:0],1'b0};
  expec_byte1 = {1'b1,parity_bit1,ALU_OUT_RESULT[15:8],1'b0};

  if(gener_byte0 == expec_byte0 && gener_byte1 == expec_byte1) begin
      $display(" >>> [PASS] ALU Output Match! Result: %d", ALU_OUT_RESULT);
      tests_passed = tests_passed + 1;
  end else begin
      $display(" >>> [FAIL] ALU Mismatch! Got: %d", ALU_OUT_RESULT);
      tests_failed = tests_failed + 1;
  end
 end
endtask

// ... [Clock Gen and Instantiation remain exactly as original] ...
always #(REF_CLK_PER/2) REF_CLK = ~REF_CLK ;
always #(UART_CLK_PER/2) UART_CLK = ~UART_CLK ;

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