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

module ALU_CU(
    input [4:0] Opcode, 
    input [1:0] ALUOp, 
    input [2:0] inst14, 
    input inst30, 
    input inst25,
    output reg [1:0] signed_unsigned, 
    output reg [3:0] aluSel);

always @(*) begin
    case(ALUOp)
        2'b00: begin //for I-format instructions
            if(inst14==`F3_ADD_MUL) begin          //inst14==`F3_ADD for Addi
                aluSel = `ALU_ADD;//addi
                signed_unsigned = 2'b00;
            end
            else if(inst14==`F3_SLL_MULH) begin    //for SLLI instruction
                 if(Opcode == `OPCODE_Arith_I) begin
                    aluSel = `ALU_SLL;
                    signed_unsigned = 2'b00;
                 end 
                 else if(Opcode == `OPCODE_Load || Opcode == `OPCODE_Store) begin
                    aluSel = `ALU_ADD;
                    signed_unsigned = 2'b00;
                 end
            end
            else if (inst14==`F3_SLT_MULHSU) begin // slti 
                 if (Opcode == `OPCODE_Arith_I) begin
                    aluSel = `ALU_SLT;
                    signed_unsigned = 2'b00;
                 end
                 else if(Opcode == `OPCODE_Load || Opcode == `OPCODE_Store) begin
                    aluSel = `ALU_ADD;
                    signed_unsigned = 2'b00;
                 end
            end
            else if(inst14==`F3_XOR_DIV) begin
                if(Opcode == `OPCODE_Arith_I) begin
                    aluSel = `ALU_XOR;
                    signed_unsigned = 2'b00;
                end
                else if(Opcode == `OPCODE_Load) begin
                    aluSel = `ALU_ADD;
                    signed_unsigned = 2'b00;
                end
            end
            else if(inst14==`F3_SRL_DIVU) begin     //for SRLI instruction
                 if(Opcode == `OPCODE_Arith_I) begin
                    if(inst30 == 1'b0) begin
                        aluSel = `ALU_SRL;
                        signed_unsigned = 2'b00;
                    end
                    else if(inst30 == 1'b1) begin
                        aluSel = `ALU_SRA;
                        signed_unsigned = 2'b00;
                    end
                 end
                 else if(Opcode == `OPCODE_Load) begin
                    aluSel = `ALU_ADD;
                    signed_unsigned = 2'b00;
                 end
            end
            else if (inst14==`F3_SLTU_MULHU) begin // sltiu 
                aluSel = `ALU_SLTU;
                signed_unsigned = 2'b00;
            end
            else if(inst14==`F3_OR_REM) begin//ori
                aluSel = `ALU_OR;
                signed_unsigned = 2'b00;
            end
            else if(inst14==`F3_AND_REMU) begin
                aluSel = `ALU_AND;
                signed_unsigned = 2'b00;
            end
        end
        
        2'b01: begin
            aluSel = `ALU_SUB;
            signed_unsigned = 2'b00;
        end
        
        2'b10: begin
            if(inst14 == `F3_ADD_MUL) begin // add
                if ( inst25 == 1'b1) begin 
                    aluSel = `ALU_MUL;
                    signed_unsigned = 2'b00;
                end
                else if(inst30 == 1'b0 && inst25 != 1'b1) begin
                    aluSel = `ALU_ADD;
                    signed_unsigned = 2'b00;
                end
                else if(inst30 == 1'b1 && inst25 != 1'b1) begin
                    aluSel = `ALU_SUB;
                    signed_unsigned = 2'b00;
                end
            end
            else if (inst14 == `F3_SLL_MULH) begin // sll
                if ( inst25 == 1'b1) begin 
                    aluSel = `ALU_MULHX;
                    signed_unsigned = 2'b00;
                end 
                else if ( inst25 != 1'b1)begin
                    aluSel = `ALU_SLL; 
                    signed_unsigned = 2'b00;
                end
            end
            else if (inst14 == `F3_SLT_MULHSU) begin // slt
               if ( inst25 == 1'b1) begin 
                aluSel = `ALU_MULHX;
                signed_unsigned = 2'b10;
               end 
               else if ( inst25 != 1'b1) begin
                aluSel = `ALU_SLT; end
                signed_unsigned = 2'b00;
            end
            else if (inst14 == `F3_XOR_DIV) begin// xor
            if ( inst25 == 1'b1) begin 
                aluSel = `ALU_DIVX;
                signed_unsigned = 2'b00;
            end 
            if ( inst25 != 1'b1) begin
                aluSel = `ALU_XOR; end
                signed_unsigned = 2'b00;
            end
            else if (inst14 == `F3_SRL_DIVU) begin // sra
                if ( inst25 == 1'b1) begin 
                    aluSel = `ALU_DIVX;
                    signed_unsigned = 2'b01;
                end             
                else if(inst30 == 1'b1  && inst25 != 1'b1) begin
                    aluSel = `ALU_SRA;
                    signed_unsigned = 2'b00;
                end
                else if(inst30 == 1'b0  && inst25 != 1'b1) begin
                    aluSel = `ALU_SRL;
                    signed_unsigned = 2'b00;
                end
            end
            else if (inst14 == `F3_SLTU_MULHU) begin // sltu
                if ( inst25 == 1'b1) begin 
                    aluSel = `ALU_MULHX;
                    signed_unsigned = 2'b01;
                end            
                if ( inst25 != 1'b1) begin
                     aluSel = `ALU_SLTU; end
                     signed_unsigned = 2'b00;
                end
            else if (inst14 == `F3_OR_REM) begin // or
                if ( inst25 == 1'b1) begin 
                   aluSel = `ALU_REMX;
                   signed_unsigned = 2'b00;
                end
                if ( inst25 != 1'b1) begin
                    aluSel = `ALU_OR; end
                    signed_unsigned = 2'b00;
                end
            else if (inst14 == `F3_AND_REMU) begin // and
            if ( inst25 == 1'b1) begin 
                aluSel = `ALU_REMX;
                signed_unsigned = 2'b01;
            end
            if ( inst25 != 1'b1) begin  
                aluSel = `ALU_AND; end
            end                                            
        end
        
        2'b11: begin
            aluSel=`ALU_PASS;
            signed_unsigned = 2'b00;
        end
        default: begin
            aluSel=`ALU_AND;
            signed_unsigned = 2'b00;
        end
    endcase
end

endmodule
