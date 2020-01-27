`timescale 1ns / 1ps
`include "defines.vh"

/*******************************************************************
*
* Module: Datapath.v
* Project: Pipelined-RISCV
* Author1: Yahya Abbas.
* Email: yahya-abbas@aucegypt.edu
* Author2: Ali Ghazal.
* Email: AliGhazal@aucegypt.edu
* Author3: Omer Hassan.
* Email: omermosa@aucegypt.edu
* Description: Pipelined RISCV processor with support for RV32IC instructions that map to true 32I instructions
*              and support for the full RV32IM instruction set.
* Change history:
**********************************************************************/


module Datapath(
    input clk, 
    input rst, 
    input [1:0] ledSel, 
    input [3:0] ssdSel, 
    output reg [15:0] LEDs, 
    output reg [12:0] SSD);

wire [31:0] inst, PC_in, PC_out, PC_plus_4, PC_plus_2, Compressed_PC_MUX_out, 
        Write_data, Read_data1, Read_data2, ImmGen_out, ALU_In2, 
        ALU_result, Branch_Adder_out, DataMem_Read, 
        MEM_WB_Mem_out, MEM_WB_ALU_out, IF_ID_PC, IF_ID_Inst, ID_EX_PC, 
        ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm,  EX_MEM_BranchAddOut, EX_MEM_ALU_out, 
        EX_MEM_RegR2, ALU_In1_MUX_OUT, ALU_In2_MUX_OUT,EX_MEM_PC, MEM_WB_PC, 
        MEM_WB_BranchAddOut, Mem_Read, Compressed_out, IF_ID_Control_MUX_OUT;
wire [8:0] ID_EX_Ctrl, ID_EX_Control_MUX_Out;
wire [5:0] EX_MEM_Ctrl, EX_MEM_Control_MUX_Out;
wire [4:0] MEM_WB_Rd, ID_EX_Rd, EX_MEM_Rd, ID_EX_Rs1, ID_EX_Rs2, ID_EX_OP;
wire [3:0] aluSel, ID_EX_Func;
wire [2:0] MEM_WB_Ctrl, EX_MEM_fun3;
wire [1:0] ALUOp, MemtoReg, branch_decision, EX_MEM_branch_decision, jumpNow, forwardA, 
    forwardB,  signed_unsigned, MEM_WB_branch_decision;
wire adder1_overflow, adder2_overflow, RegWrite, Branch, MemRead, MemWrite, ALUSrc, Zero_flag,
        overflow_flag,sign_flag,carry_flag, loadPC, EX_MEM_Zero, Stall,clk_out, isInst, 
        IF_ID_isInst, ID_EX_isInst, Is_compressed, ID_EX25;

assign PC_plus_4 = PC_out + 4;
assign PC_plus_2 = PC_out + 2;

Clock_divider   half_freq(.clock_in(clk),.clock_out(clk_out));

mux_32b Compressed_PC_MUX(.x(PC_plus_4), .y(PC_plus_2), .s(Is_compressed), .out(Compressed_PC_MUX_out));

mux_4x1 PC_MUX(.in1(Compressed_PC_MUX_out), .in2(MEM_WB_BranchAddOut), .in3(MEM_WB_ALU_out), 
    .in4(Compressed_PC_MUX_out), .sel(MEM_WB_branch_decision), .out(PC_in));

PC  PC_instance(.clk(clk_out), .rst(rst), .load((loadPC & ~Stall)), .in(PC_in), .out(PC_out)); 

memory  mem(.clk(clk), .clk_out(clk_out), .rst(rst), .PCsrc(EX_MEM_branch_decision) , 
    .func3(ID_EX_Func[2:0]), .MemRead(ID_EX_Ctrl[4]), .MemWrite(ID_EX_Ctrl[3]), .addr(PC_out[8:0]), 
    .addr2(ALU_result[8:0]), .data_in(ALU_In2_MUX_OUT), .isInst(isInst), .inst(inst), 
    .data_out(DataMem_Read));
    /*module memory(input clk,input [2:0] func3, input MemRead,
      input MemWrite, input [7:0]addr,  input addr2, input [31:0] data_in, output reg [31:0] data_out);*/


RV32IC  Compressed_module(.in(inst), .out(Compressed_out), .Is_compressed(Is_compressed));

mux_32b MemOut_MUX(.x(Compressed_out), .y(DataMem_Read), .s(~isInst), .out(Mem_Read));

RegFile register_file(.clk(clk), .rst(rst), .readreg1(IF_ID_Inst[`IR_rs1]), .readreg2(IF_ID_Inst[`IR_rs2]), 
    .writereg(MEM_WB_Rd), .writedata(Write_data), .regwrite(MEM_WB_Ctrl[2]), 
    .readdata1(Read_data1), .readdata2(Read_data2));  
    /*input clk, rst, input [4:0] readreg1, readreg2, writereg, input [31:0] 
        writedata, input regwrite, output [31:0] readdata1, readdata2)*/

ControlUnit CU(.inst(IF_ID_Inst), .isInst(IF_ID_isInst), .Branch(Branch), .MemRead(MemRead), .MemWrite(MemWrite), .ALUSrc(ALUSrc), 
    .RegWrite(RegWrite), .jumpNow(jumpNow), .ALUOp(ALUOp), .MemtoReg(MemtoReg), .loadPC(loadPC)); 
    /*(input [31:0] inst, output reg Branch, reg MemRead, reg MemWrite, reg ALUSrc, 
        reg RegWrite, reg[1:0] jumpNow,  reg [1:0] ALUOp, reg [1:0] MemtoReg);*/

ImmediateGen_SignExt    ImmGen(.inst(IF_ID_Inst), .out(ImmGen_out));
    //input [31:0] inst, output reg [31:0] gen_out

mux_4x1 ALU_In1_MUX(.in1(ID_EX_RegR1), .in2(Write_data), .in3(EX_MEM_ALU_out), .in4(0), .sel(forwardA), .out(ALU_In1_MUX_OUT));
    //mux_4x1( input [31:0] in1, in2, in3, in4, input [1:0] sel, output reg [31:0] out);

mux_4x1 ALU_In2_MUX(.in1(ID_EX_RegR2), .in2(Write_data), .in3(EX_MEM_ALU_out), .in4(0), .sel(forwardB), .out(ALU_In2_MUX_OUT));
    //mux_4x1( input [31:0] in1, in2, in3, in4, input [1:0] sel, output reg [31:0] out);

mux_32b RF_MUX(.x(ALU_In2_MUX_OUT), .y(ID_EX_Imm), .s(ID_EX_Ctrl[0]), .out(ALU_In2));
    //input x, y, s, output out

ALU32bit    ALU(.in1(ALU_In1_MUX_OUT), .in2(ALU_In2), .signed_unsigned(signed_unsigned), .aluSel(aluSel), .result(ALU_result), 
    .zero_flag(Zero_flag), .carry_flag(carry_flag), .overflow_flag(overflow_flag), .sign_flag(sign_flag));   
    /*(input [31:0] in1, in2, input [3:0] aluSel, output reg [31:0] result,
        output wire zero_flag,carry_flag, overflow_flag, sign_flag);*/

ALU_CU  ALU_control(.Opcode(ID_EX_OP), .ALUOp(ID_EX_Ctrl[2:1]), .inst14(ID_EX_Func[2:0]), 
    .inst30(ID_EX_Func[3]), .inst25(ID_EX25), .signed_unsigned(signed_unsigned), .aluSel(aluSel));  
    /*ALU_CU(input [4:0] Opcode, input [1:0] ALUOp, input [2:0] inst14, 
        input inst30, output reg [3:0] aluSel);*/


RCA Branch_Adder(.cin(1'b0), .x(ID_EX_PC), .y(ID_EX_Imm), .cout(adder2_overflow), .sum(Branch_Adder_out));
    //RCA Branch_Adder(0, ID_EX_PC, Shift_left_output, adder2_overflow, Branch_Adder_out);


mux_4x1 RF_Write_MUX (.in1(MEM_WB_ALU_out), .in2(MEM_WB_Mem_out), .in3(MEM_WB_PC + 4), 
    .in4(MEM_WB_BranchAddOut), .sel(MEM_WB_Ctrl[1:0]), .out(Write_data));

BranchDecisionUnit BDU(.func3(ID_EX_Func[2:0]),.bf(ID_EX_Ctrl[5]),.zf(Zero_flag),
    .cf(carry_flag),.vf(overflow_flag),.sf(sign_flag),.branch(branch_decision),.jump_decision(jumpNow));  
    //module BranchDecisionUnit(input[2:0] func3, input bf, zf, cf,vf,sf,output reg branch);

Register32bit #(65) IF_ID (.clk(clk), .load(~Stall), .reset(rst), .D({PC_out, IF_ID_Control_MUX_OUT, isInst}),
    .regQ({IF_ID_PC, IF_ID_Inst, IF_ID_isInst}));
    //module Register32bit(input clk, load, reset, [31:0] D, output  [31:0]regQ);

mux_32b IF_ID_Control_MUX(Mem_Read,32'b0000000_00000_00000_000_00000_0110011, (MEM_WB_branch_decision != 0),IF_ID_Control_MUX_OUT);

mux_9bits ID_EX_Control_MUX(.x({RegWrite, MemtoReg, Branch, MemRead, MemWrite, ALUOp, ALUSrc}),
 .y(9'b0), .s(Stall | (EX_MEM_branch_decision != 0)), .out(ID_EX_Control_MUX_Out));



Register32bit #(163) ID_EX (.clk(clk), .load(1'b1), .reset(rst), .D({ID_EX_Control_MUX_Out, IF_ID_PC, Read_data1, 
    Read_data2, ImmGen_out , IF_ID_Inst[30], IF_ID_Inst[14:12], IF_ID_Inst[19:15], IF_ID_Inst[24:20], 
    IF_ID_Inst[11:7], IF_ID_Inst[6:2], IF_ID_isInst, IF_ID_Inst[25]}),
    .regQ({ID_EX_Ctrl, ID_EX_PC, ID_EX_RegR1, ID_EX_RegR2, ID_EX_Imm, ID_EX_Func, ID_EX_Rs1, 
    ID_EX_Rs2, ID_EX_Rd, ID_EX_OP, ID_EX_isInst, ID_EX25}));
 
mux_6bits EX_MEM_control_mux (.x({ID_EX_Ctrl[8:6], ID_EX_Ctrl[5:3]}), .y(6'b0), 
    .s((branch_decision  != 0)), .out(EX_MEM_Control_MUX_Out));

Register32bit #(145) EX_MEM (.clk(clk), .load(1'b1), .reset(rst), .D({branch_decision, EX_MEM_Control_MUX_Out , 
    Branch_Adder_out, Zero_flag, ALU_result, ID_EX_RegR2, ID_EX_Rd,ID_EX_Func[2:0], ID_EX_PC}),
    .regQ({EX_MEM_branch_decision, EX_MEM_Ctrl, EX_MEM_BranchAddOut, EX_MEM_Zero, 
    EX_MEM_ALU_out, EX_MEM_RegR2, EX_MEM_Rd,EX_MEM_fun3, EX_MEM_PC}));

Register32bit #(138) MEM_WB (.clk(clk), .load(1'b1), .reset(rst),
    .D({EX_MEM_branch_decision, EX_MEM_Ctrl[5:3], Mem_Read, EX_MEM_ALU_out, EX_MEM_Rd,EX_MEM_PC, EX_MEM_BranchAddOut}),
    .regQ({MEM_WB_branch_decision, MEM_WB_Ctrl,MEM_WB_Mem_out, MEM_WB_ALU_out, MEM_WB_Rd, MEM_WB_PC, MEM_WB_BranchAddOut}));


Forwarding_Unit FU(.EX_MEM_regwrite(EX_MEM_Ctrl[5]), .MEM_WB_regwrite(MEM_WB_Ctrl[2]), .EX_MEM_rd(EX_MEM_Rd), 
    .MEM_WB_rd(MEM_WB_Rd), .ID_EX_rs1(ID_EX_Rs1), .ID_EX_rs2(ID_EX_Rs2), .forwardA(forwardA), .forwardB(forwardB));
    /*module Forwarding_Unit(input EX_MEM_regwrite,MEM_WB_regwrite,input[4:0]EX_MEM_rd,
    MEM_WB_rd,ID_EX_rs1,ID_EX_rs2,output reg[1:0] forwardA,forwardB );*/


Hazard_Detection Hazard_DetectionUnit (.IF_ID_RegisterRs1(IF_ID_Inst[`IR_rs1]), .IF_ID_RegisterRs2(IF_ID_Inst[`IR_rs2]), 
    .ID_EX_RegisterRd(ID_EX_Rd), .ID_EX_MemRead(ID_EX_Ctrl[4]), .Stall(Stall));

always @ (ledSel) begin
    case(ledSel)
        2'b00:  
            LEDs=Mem_Read[15:0];
        2'b01: 
            LEDs=Mem_Read[31:16];
        2'b10: 
            LEDs={2'b0,Branch,MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp,aluSel,Zero_flag,(Branch && Zero_flag)};
        default: 
            LEDs=16'b1;
    endcase
end 

always @ (ssdSel) begin
    case(ssdSel)
        4'b00_00:
            SSD=PC_out;
        4'b00_01:
            SSD=PC_plus_4;
        4'b00_10:
            SSD=Branch_Adder_out;
        4'b00_11:
            SSD=PC_in;
        4'b01_00:
            SSD=Read_data1;
        4'b01_01:
            SSD=Read_data2;  
        4'b01_10:
            SSD=Write_data;
        4'b01_11:
            SSD=ImmGen_out;
        4'b10_01:
            SSD=ALU_In2;
        4'b1010:
            SSD=ALU_result; 
        4'b1011:
            SSD=Mem_Read;
    endcase
end 

endmodule
