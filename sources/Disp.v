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

module Disp (input clk,
input [12:0] num,
output reg [3:0] Anode,
output reg [6:0] LED_out);

reg [3:0] thousands;
reg [3:0] Hundreds;
reg [3:0] Tens;
reg [3:0] Ones;

integer i;

always @(num) begin
//initialization
    thousands=4'd0;
    Hundreds = 4'd0;
    Tens = 4'd0;
    Ones = 4'd0;
    for (i = 12; i >= 0 ; i = i-1 ) begin
        if(thousands>=5)
            thousands=thousands+3;
        if(Hundreds >= 5 )
            Hundreds = Hundreds + 3 ;
        if (Tens >= 5 )
            Tens = Tens + 3;
        if (Ones >= 5)
            Ones = Ones +3;
        //shift left one
        thousands=thousands<<1;
        thousands[0]=Hundreds[3];
        Hundreds = Hundreds << 1;
        Hundreds [0] = Tens [3];
        Tens = Tens << 1;
        Tens [0] = Ones[3];
        Ones = Ones << 1;
        Ones[0] = num[i];
    end
end

reg [3:0] LED_BCD;
reg [19:0] refresh_counter = 0; // 20-bit counter
wire [1:0] LED_activating_counter;

always @(posedge clk) begin
    refresh_counter <= refresh_counter + 1;
end

assign LED_activating_counter = refresh_counter[19:18];

always @(*) begin
    case(LED_activating_counter)
        2'b00: begin
            Anode = `ALU_SRA;
            LED_BCD = thousands;
        end
        2'b01: begin
            Anode = 4'b1011;
            LED_BCD = Hundreds;
        end
        2'b10: begin
            Anode = 4'b1101;
            LED_BCD = Tens;
        end
        2'b11: begin
            Anode = 4'b1110;
            LED_BCD = Ones;
        end
        default:begin
            Anode = `ALU_SRA;
            LED_BCD =thousands;
        end
    endcase
end

always @(*) begin
    case(LED_BCD)
        `ALU_AND: LED_out = 7'b0000001; // "0"
        `ALU_ADD: LED_out = 7'b1001111; // "1"
        `ALU_OR: LED_out = 7'b0010010; // "2"
        `ALU_XOR: LED_out = 7'b0000110; // "3"
        `ALU_SLL: LED_out = 7'b1001100; // "4"
        `ALU_SRL: LED_out = 7'b0100100; // "5"
        `ALU_SUB: LED_out = 7'b0100000; // "6"
        `ALU_SRA: LED_out = 7'b0001111; // "7"
        `ALU_SLT: LED_out = 7'b0000000; // "8"
        `ALU_PASS: LED_out = 7'b0000100; // "9"
        default: LED_out = 7'b0000001; // "0"
    endcase
end

endmodule
