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

module ControlUnit(
    input [31:0] inst, 
    input isInst, 
    output reg Branch, 
    output reg MemRead,  
    output reg MemWrite, 
    output reg ALUSrc, 
    output reg RegWrite, 
    output reg[1:0] jumpNow,  
    output reg [1:0] ALUOp, 
    output reg [1:0] MemtoReg,
    output reg loadPC);

always @(*) begin
    if (isInst) begin
        case(`OPCODE)
            `OPCODE_Arith_R: begin//R-format
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 2'b10;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 1;
                jumpNow = 0;
                loadPC=1;
            end
            `OPCODE_Load: begin//LW
                Branch = 0;
                MemRead = 1;
                MemtoReg = 2'b01;
                ALUOp = 2'b00;
                MemWrite = 0;
                ALUSrc = 1;
                RegWrite = 1;
                jumpNow = 0;
                loadPC=1;
            end
            `OPCODE_Store: begin//SW
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 2'b00;
                MemWrite = 1;
                ALUSrc = 1;
                RegWrite = 0;
                jumpNow = 0;
                loadPC=1;
            end
            `OPCODE_Branch: begin//Branch
                Branch = 1;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 2'b01;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
                jumpNow = 0;
                loadPC=1;
            end
            `OPCODE_JAL: begin // jal
                Branch = 0;//check
                MemRead = 0;
                MemtoReg = 2'b10; // special
                ALUOp = 2'b00; // addition
                MemWrite = 0;
                ALUSrc = 1; // form imm
                RegWrite = 1; //yes
                jumpNow = 2'b01;
                loadPC=1;
            end
            `OPCODE_JALR: begin //jalr
                Branch = 0;
                MemRead = 0;
                MemtoReg = 2'b10;
                ALUOp = 2'b00;//add
                MemWrite = 0;
                ALUSrc = 1;
                RegWrite = 1;
                jumpNow = 2'b10;
                loadPC=1;
    
            end
            `OPCODE_Arith_I: begin//I-format
                Branch = 0;
                MemRead = 0;
                MemtoReg = 00;
                ALUOp = 2'b00;
                MemWrite = 0;
                ALUSrc = 1;
                RegWrite = 1;
                jumpNow = 0;
                loadPC=1;
            end
            `OPCODE_LUI: begin //for LUI-format use, still needs some work
                Branch = 0;
                MemRead = 0;
                MemtoReg = 0;
                ALUOp = 2'b11;
                MemWrite = 0;
                ALUSrc = 1;
                RegWrite = 1;
                jumpNow = 0;
                loadPC=1;
            end
            `OPCODE_AUIPC: begin //for AUPIC-format use
                Branch = 0;
                MemRead = 0;
                MemtoReg =2'b11;
                ALUOp = 2'b11;
                MemWrite = 0;
                ALUSrc = 1;
                RegWrite = 1;
                jumpNow = 0;
                loadPC=1;
            end
            `OPCODE_SYSTEM : begin //for Ebreak-format use    
                if (inst[`IR_funct3] == `F3_ADD_MUL & inst[20] == 1'b1)begin //Ebreak
                    Branch = 0;
                    MemRead = 0;
                    MemtoReg =0;
                    ALUOp = 0;
                    MemWrite = 0;
                    ALUSrc = 0;
                    RegWrite = 0;
                    jumpNow = 0;
                    loadPC=0;
                end 
                else begin
                    Branch = 0;
                    MemRead = 0;
                    MemtoReg =0;
                    ALUOp = 0;
                    MemWrite = 0;
                    ALUSrc = 0;
                    RegWrite = 0;
                    jumpNow = 0;
                    loadPC=1;   
                end
            end    
            `OPCODE_Custom: begin //for FENCE Instruction use (perform Addi X0, X0, 0)
                Branch = 0;
                MemRead = 0;
                MemtoReg =0;
                ALUOp = 2'b00;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
                jumpNow = 0;
                loadPC=1;
            end        
            default: begin
                Branch = 0;
                MemRead = 0;
                MemtoReg = 00;
                ALUOp = 2'b00;
                MemWrite = 0;
                ALUSrc = 0;
                RegWrite = 0;
                jumpNow = 0;
                loadPC=1;
            end
        endcase
    end else begin 
               Branch = 0;
               MemRead = 0;
               MemtoReg = 00;
               ALUOp = 2'b00;
               MemWrite = 0;
               ALUSrc = 0;
               RegWrite = 0;
               jumpNow = 0;
               loadPC=1;
    end    
end

endmodule
