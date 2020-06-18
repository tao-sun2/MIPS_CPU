`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module Idecode32(read_data_1,read_data_2,Instruction,read_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset, opcplus4);
output[31:0] read_data_1; // the first output data while read
output[31:0] read_data_2; // the second output data while read
output[31:0] Sign_extend; // the output of decode unit which the extended 32bit-width instance data
input[31:0] Instruction; // the instrution from fetch instruction unit
input[31:0] read_data; // the data read from DATA RAM or I/O port
input[31:0] ALU_result; // the alu result from excutation unit,need to extend to 32 bit-width
input Jal; // from control unit, 1 mean current instruction is JAL
input RegWrite; // from control unit
input MemtoReg; // from control unit
input RegDst; // from control unit
input clock,reset; // clock and reset
input[31:0] opcplus4; // from fetch unit, used in JAL
wire[31:0] read_data_1;
wire[31:0] read_data_2;
reg[31:0] register[0:31]; //there are 32 registers with 32 bit-width
reg[4:0] write_register_address; // the index/address of the register which is tobe write
reg[31:0] write_data; // the data which is tobe write into register
wire[4:0] read_register_1_address; // the index/address of first register tobe read£¨rs£©
wire[4:0] read_register_2_address; // the index/address of first register tobe read£¨rt£©
wire[4:0] write_register_address_1; // r-form instruction, the index/address of register tobe write£¨rd£©
wire[4:0] write_register_address_0; // i-form instruction, the index/address of register tobe write(rt)
wire[15:0] Instruction_immediate_value; // the instance data in instruction
wire[5:0] opcode; // the instruction code
    
    assign opcode = Instruction[31:26];	
    assign read_register_1_address = Instruction[25:21];
    assign read_register_2_address = Instruction[20:16];
    assign write_register_address_1 = Instruction[15:11];
    assign write_register_address_0 = Instruction[20:16];
    assign Instruction_immediate_value = Instruction[15:0];
	
	assign read_data_1 = register[read_register_1_address];
    assign read_data_2 = register[read_register_2_address];
    wire sign;                                            

    assign sign = Instruction_immediate_value[15];
    assign Sign_extend[31:0] = (opcode==6'b001100||opcode==6'b001101||opcode==6'b001110)?{16'h0000,Instruction_immediate_value}:
		(sign?{16'hffff,Instruction_immediate_value}:{16'h0000,Instruction_immediate_value});
    
    
    
    always @* begin                                          
        if(Jal)write_register_address = 5'd31;
        else begin
            if(RegDst)write_register_address = write_register_address_1;
            else write_register_address = write_register_address_0;
        end
    end
    
    always @* begin  
        if(Jal)write_data = opcplus4;
        else begin
            if(MemtoReg)write_data = read_data;
            else write_data = ALU_result;
        end
    end
    
    integer i;
    always @(posedge clock) begin       
        if(reset==1) begin              
            for(i=0;i<32;i=i+1) register[i] <= i;
        end else if(RegWrite==1) begin  
            if(write_register_address!=0)begin
                register[write_register_address] = write_data;
            end
           
        end
       
    end
endmodule