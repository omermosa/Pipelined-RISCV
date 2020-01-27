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

module DFF(
    input clk, 
    input rst, 
    input D, 
    output reg Q);

always @ (posedge clk or posedge rst) begin // Asynchronous Reset
    if (rst)
        Q <= 1'b0;
    else
        Q <= D;
end

endmodule
