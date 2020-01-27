`timescale 1ns / 1ps

module RiscV_tb();
reg clk;
reg rst;
reg [1:0] ledSel;
reg [3:0] ssdSel;
wire[15:0] LEDs;
wire [12:0] SSD;

Datapath RiscV_instance(clk, rst, ledSel, ssdSel, LEDs, SSD);

 initial begin
       
        clk=0;
        rst=0;
        #10
        rst=1;
        #10
        rst =0;
    end
   
    always  begin
        #10 clk = ~clk;
    end

endmodule
