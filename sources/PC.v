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

module PC(
    input clk, 
    input rst, 
    input load, 
    input [31:0] in, 
    output  [31:0] out);

// Register32bit(input clk, load, reset, [31:0] D, output [31:0]regQ);
Register32bit PC_Reg(.clk(clk), .load(load), .reset(rst), .D(in), .regQ(out));

endmodule
