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

module RegFile(
    input clk, 
    input rst, 
    input [4:0] readreg1, 
    input [4:0] readreg2, 
    input [4:0] writereg, 
    input [31:0] writedata, 
    input regwrite, 
    output [31:0] readdata1, 
    output [31:0] readdata2 );

wire [31:0] in[0:31], out[0:31];
reg [31:0] load;

genvar i;
generate 
    for (i=0;i<32;i=i+1) begin
        Register32bit register(.clk(clk), .load(load[i]), .reset(rst), .D(writedata), .regQ(out[i]));
        //module Register32bit(input clk, load, reset, [31:0] D, output [31:0]regQ);
    end
endgenerate

always @(negedge clk) begin 
    load=32'b0;
    if(regwrite)  begin 
          if(writereg!=0)
            load[writereg]=1'b1;
    end
end

assign readdata1=out[readreg1];
assign readdata2=out[readreg2];

endmodule
