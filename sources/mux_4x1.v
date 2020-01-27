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

module mux_4x1(
    input [31:0] in1, 
    input [31:0] in2, 
    input [31:0] in3, 
    input [31:0] in4, 
    input [1:0] sel, 
    output reg [31:0] out);

always @ (*) begin
    case (sel)
    2'b00: begin out = in1; end
    2'b01: begin out = in2; end
    2'b10: begin out = in3; end
    2'b11: begin out = in4; end
    endcase
end 

endmodule
