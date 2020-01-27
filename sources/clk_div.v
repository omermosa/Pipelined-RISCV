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

module Clock_divider(
    input clock_in,
    output clock_out);
/*clock_in --> input clock on FPGA
    output clock_out --> output clock after dividing the input clock by divisor*/
reg[27:0] counter=28'd0;
parameter DIVISOR = 28'd2;
/*The frequency of the output clk_out  = The frequency of the input clk_in divided by DIVISOR
    For example: Fclk_in = 50Mhz, if you want to get 1Hz signal to blink LEDs
    You will modify the DIVISOR parameter value to 28'd50.000.000
    Then the frequency of the output clk_out = 50Mhz/50.000.000 = 1Hz*/
always @(posedge clock_in) begin
    counter <= counter + 28'd1;
    if(counter>=(DIVISOR-1)) begin
        counter <= 28'd0;
    end
end 
assign clock_out = (counter<DIVISOR/2)?1'b0:1'b1;
endmodule