# Pipelined-RISCV
### This Project was a part of the Computer Architecture Course at the American University in Cairo (AUC).

This Project is a Full Pipelined implementation of a RISCV processor. It was implemented using Verilog HDL and tested on Nexys A7 Board.

The Processor Supports all instructions except the Exception Handlers. It also supports Multplication and division operations. 

Instructions can be Full word (32 bits) or Half word (16 bits) instructions or a mix of both. 

The Processor Operates on a single ported memory for both data memory and instruction memory.

Hazard detection, Forwarding, and Branch prediction are all implemented and tested.

The Processor was simulated using a propper testbench.

To run it, it is recommended to add all sources to one Project on Vivado Xilinx and Run it.
