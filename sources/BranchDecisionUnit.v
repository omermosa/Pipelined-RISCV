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

module BranchDecisionUnit(
    input[2:0] func3,
    input[1:0] jump_decision, 
    input bf, 
    input zf, 
    input cf,
    input vf,
    input sf,
    output reg[1:0] branch);
 
 // based on func3 decide based on (nonzero & b), zero&b, greater&b, smaller&b.  
always @ (*)begin
    case(jump_decision)
        2'b0: begin
            case (func3)
                 `BR_BEQ: begin 
                    branch = bf & zf;   
                  end // beq
                 `BR_BNE: begin 
                    branch = bf & ~zf; 
                  end // bnq
                 `BR_BLT: begin 
                    branch = bf&(sf!=vf);  
                  end // blt
                 `BR_BGE: begin 
                    branch = bf&(sf== vf); 
                  end // bge
                 `BR_BLTU: begin 
                    branch=bf&~cf; 
                  end
                 `BR_BGEU: begin 
                    branch=bf&cf; 
                  end // 
                 default: 
                    branch=0;
            endcase
        end
        2'b01:
            branch=2'b1;
        2'b10:
            branch=2'd2;
        default:
            branch=2'b0;
    endcase
 end
 
endmodule