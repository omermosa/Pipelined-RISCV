`timescale 1ns / 1ps

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

module RCA(
    input cin, 
    input [31:0] x, 
    input [31:0] y, 
    output cout, 
    output [31:0] sum);
    
wire [32:0]carry;

assign carry[0] = cin;

generate genvar i;
    for (i = 0; i < 32; i = i + 1) begin : gen1
        fullAdder fa(.a(x[i]), .b(y[i]), .cin(carry[i]), .sum(sum[i]), .cout(carry[i+1]));
    end
endgenerate

assign cout = carry[32]; 

endmodule
