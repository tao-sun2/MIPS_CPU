`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module control32(Opcode,Jrn, Function_opcode,Alu_resultHigh,RegDST,ALUSrc,MemorIOtoReg,RegWrite,MemRead,MemWrite,IORead,IOWrite,Branch,nBranch,Jmp,Jal,I_format,Sftmd,ALUOp);
    input[5:0]   Opcode;            // instruction[31..26]
    input[5:0]   Function_opcode;  	// instructions[5..0]
    input[21:0]  Alu_resultHigh;    // From the execution unit Alu_Result[31..10]
    output       Jrn;         	 // 1 indicates the instruction is "jr", otherwise it's not "jr"
    output       RegDST;          // 1 indicate destination register is "rd",otherwise it's "rt"
    output       ALUSrc;          // 1 indicate the 2nd data is immidiate (except "beq","bne")
    output       MemorIOtoReg;   	//  1 indicates that data needs to be read from memory or I/O to the register
    output       RegWrite;   	//  1 indicate write register, otherwise it's not
    output       MemWrite;   	//  1 indicate write register, otherwise it's not
    output       MemRead;       //  1 indicates that the instruction needs to read from the memory
    output       Branch;    	//  1 indicate the instruction is "beq" , otherwise it's not
    output       nBranch;   	//  1 indicate the instruction is "bne", otherwise it's not
    output       Jmp;        	//  1 indicate the instruction is "j", otherwise it's not
    output       Jal;        	//  1 indicate the instruction is "jal", otherwise it's not
    output       I_format;  	//  1 indicate the instruction is I-type but isn't "beq","bne","LW" or "SW"
    output       Sftmd;     	//  1 indicate the instruction is shift instruction
    output[1:0]  ALUOp;	        //  if it's R-type or I_format=1,bit1 is 1, if it's "beq" or "bne",bit 0 is 1
    output       IORead;        //  1 indicates I/O read
    output       IOWrite;       //  1 indicates I/O write
    
   
    wire Jmp,I_format,Jal,Branch,nBranch;
    wire R_format;        
    wire Lw;              
    wire Sw;              
	assign  Lw=(Opcode==6'b100011)?1:0;
	assign  Sw=(Opcode==6'b101011)?1:0;  
    
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;    	
    assign RegDST = R_format;                               

    assign I_format = (Opcode!=6'b000000&&Opcode!=6'h2&&Opcode!=6'h3&&Opcode!=6'h4
	&&Opcode!=6'h5&&Opcode!=6'h23&&Opcode!=6'h2b)? 1'b1:1'b0;
    assign Jal = (Opcode==6'h3)? 1'b1:1'b0;
    assign Jrn = (R_format&&Function_opcode==6'h8)? 1'b1:1'b0;  
    assign RegWrite = (I_format||(R_format&&Function_opcode!=6'h8)||Lw||Jal)? 1'b1:1'b0;

    assign Sftmd = (R_format&&(Function_opcode==6'h0||Function_opcode==6'h2
	||Function_opcode==6'h4||Function_opcode==6'h6||Function_opcode==6'h3
	||Function_opcode==6'h7))? 1'b1:1'b0; 
    assign ALUOp = {(R_format || I_format),(Branch || nBranch)};  
    
    assign ALUSrc = (I_format||Opcode==6'h23||Opcode==6'h2b)? 1'b1:1'b0;
    assign Branch = (Opcode==6'h4)? 1'b1:1'b0;
    assign nBranch = (Opcode==6'h5)? 1'b1:1'b0;
    assign Jmp = (Opcode==6'h2)? 1'b1:1'b0;
    
    assign MemWrite = (Sw)&&(Alu_resultHigh[21:0]!=22'b1111111111111111111111)? 1'b1:1'b0; 
    assign MemRead = (Lw)&&(Alu_resultHigh[21:0]!=22'b1111111111111111111111)? 1'b1:1'b0;
    assign IOWrite = (Sw)&&(Alu_resultHigh[21:0]==22'b1111111111111111111111)? 1'b1:1'b0; 
    assign IORead = (Lw)&&(Alu_resultHigh[21:0]==22'b1111111111111111111111)? 1'b1:1'b0;
    assign MemorIOtoReg = IORead || MemRead;


endmodule