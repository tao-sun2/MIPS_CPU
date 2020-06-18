`timescale 1ns / 1ps


module Ifetc32(Instruction,PC_plus_4_out,Add_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jrn,Zero,clock,reset,
opcplus4,PC);
output[31:0] Instruction; // the instruction fetched from this module
output[31:0] PC_plus_4_out; // (pc+4) to ALU which is used by branch type instruction
input[31:0] Add_result; // from ALU module��the calculated address
input[31:0] Read_data_1; // from decoder��the address of instruction used by jr instruction
input Branch; // from controller, while Branch is 1,it means current instruction is beq
input nBranch; // from controller, while nBranch is 1,it means current instruction is bnq
input Jmp; // from controller, while Jmp 1,it means current instruction is jump
input Jal; // from controller, while Jal is 1,it means current instruction is jal
input Jrn; // from controller, while jrn is 1,it means current instruction is jr
input Zero; // from ALU, while Zero is 1, it means the ALUresult is zero
input clock,reset; // Clock and reset
output[31:0] opcplus4; // (pc+4) to decoder which is used by jal instruction


wire[31:0] PC_plus_4;
output reg [31:0] PC;
reg[31:0] next_PC;
reg[31:0] opcplus4;

prgrom instmem(
.clka(clock), // input wire clka
.addra(PC[15:2]), // input wire [13 : 0] addra
.douta(Instruction) // output wire [31 : 0] douta
);

assign PC_plus_4[31:2]=PC[31:2]+1;
assign PC_plus_4[1:0]=PC[1:0];
assign PC_plus_4_out=PC_plus_4;

always@* begin
if(((Branch==1'b1)&&(Zero==1'b1))||((nBranch==1'b1)&&(Zero==1'b0)))
next_PC= Add_result;
else if(Jrn==1'b1)
next_PC=Read_data_1;
else
next_PC=(PC_plus_4>>2);
end

always@(negedge clock)begin
if(reset==1)
PC<=0;
else if(Jal==1'b1||(Jmp==1'b1))
begin
PC={PC_plus_4[31:28],Instruction[25:0],2'b00};
opcplus4<=(PC_plus_4_out>>2);
end
else
PC<=(next_PC<<2);
end
endmodule
