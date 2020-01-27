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

module ImmediateGen_SignExt(
    input [31:0] inst, 
    output  [31:0] out);

reg [11:0] compImm;
reg [31:0] imm;

wire [31:0] innerInst = inst;

always @ (*) begin
    case (`OPCODE)
        `OPCODE_JAL:   imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0}; // jal
        `OPCODE_Branch:   imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};  // branch
        `OPCODE_Load:   imm =  {{21{inst[31]}}, inst[30:20]}; // load
        `OPCODE_Arith_I:   case(inst[14:12])
                                 3'b101: imm={{21{inst[31]}},6'b0 ,inst[24:20]};
                                 default:imm =  {{21{inst[31]}}, inst[30:20]}; // Arith_I
                                endcase
        `OPCODE_Store:   imm =  {{21{inst[31]}}, inst[30:25], inst[11:7]}; // store
        `OPCODE_LUI:   imm = {inst[31], inst[30:12], 12'b0}; // lui
        `OPCODE_AUIPC:   imm = {inst[31], inst[30:12], 12'b0}; // aupic
        `OPCODE_JALR:   imm = {{21{inst[31]}}, inst[30:20]}; // jalr
        default:    imm = {{21{inst[31]}}, inst[30:20]};
    endcase
end

assign out = imm;
endmodule
