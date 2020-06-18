`timescale 1ns / 1ps

module minisys_sc(clk,rst, led,switch);
	input rst;           
    input clk;               
    input[23:0] switch;    
    output[23:0] led;      
    wire clock;              
	wire iowrite,ioread;     
    wire[31:0] write_data;   
    wire[31:0] rdata;        
    wire[15:0] ioread_data;  
    wire[31:0] pc_plus_4;    
    wire[31:0] read_data_1;  
    wire[31:0] read_data_2;  
    wire[31:0] sign_extend;  
    wire[31:0] add_result;   
    wire[31:0] alu_result;   
    wire[31:0] read_data;    
    wire[31:0] address;
	wire alusrc;
	wire branch;
	wire nbranch,jmp,jal,jrn,i_format;
	wire regdst;
	wire regwrite;
	wire zero;
	wire memwrite;
	wire memread;
	wire memoriotoreg;
	wire memreg;
	wire sftmd;
	wire[1:0] aluop;
	wire[31:0] instruction;
    wire[31:0] opcplus4;
    wire ledctrl,switchctrl;
    wire[15:0] ioread_data_switch;


    cpuclk cpuclk(
        .clk_in1(clk),   
        .clk_out1(clock)    
    );

    Ifetc32 ifetch(
        .Instruction(instruction),
        .PC_plus_4_out(pc_plus_4),
        .Add_result(add_result),
        .Read_data_1(read_data_1),
        .Branch(branch),
        .nBranch(nbranch),
        .Jmp(jmp),
        .Jal(jal),
        .Jrn(jrn),
        .Zero(zero),
        .clock(clock),
        .opcplus4(opcplus4),
        .reset(rst)
    );
    
    Idecode32 idecode(
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
		.Instruction(instruction),
        .read_data(rdata),
        .ALU_result(alu_result),
        .Jal(jal),
        .RegWrite(regwrite),
        .MemtoReg(memoriotoreg),
        .RegDst(regdst),
        .Sign_extend(sign_extend),
        .clock(clock),
        .reset(rst),
        .opcplus4(opcplus4)
    );

    
    control32 control(
        .Opcode(instruction[31:26]),
        .Function_opcode(instruction[5:0]),
        .Alu_resultHigh(alu_result[31:10]),
        .Jrn(jrn),
        .RegDST(regdst),
        .ALUSrc(alusrc),
        .MemorIOtoReg(memoriotoreg),
        .RegWrite(regwrite),
        .MemRead(memread),
        .MemWrite(memwrite),
        .IORead(ioread),
        .IOWrite(iowrite),
        .Branch(branch),
        .nBranch(nbranch),
        .Jmp(jmp),
        .Jal(jal),
        .I_format(i_format),
        .Sftmd(sftmd),
        .ALUOp(aluop)
    );
                      
    Executs32 execute(
        .Read_data_1(read_data_1),
        .Read_data_2(read_data_2),
        .Sign_extend(sign_extend),
        .Function_opcode(instruction[5:0]),
		.Exe_opcode(instruction[31:26]),
		.ALUOp(aluop),
		.Shamt(instruction[10:6]),
		.Sftmd(sftmd),
		.ALUSrc(alusrc),
		.I_format(i_format),
		.Zero(zero),
		.Jrn(jrn),
		.ALU_Result(alu_result),
		.Add_Result(add_result),
		.PC_plus_4(pc_plus_4)
     );
    
    dmemory32 memory(
        .read_data(read_data),
        .address(address),
        .write_data(write_data),
        .Memwrite(memwrite),
        .clock(clock)    
    );
	
    memorio memio(
        .caddress(alu_result),
        .address(address),
        .memread(memread),
        .memwrite(memwrite),
        .ioread(ioread),
        .iowrite(iowrite),
        .mread_data(read_data),
        .ioread_data(ioread_data),
        .wdata(read_data_2),
        .rdata(rdata),
        .write_data(write_data),
        .LEDCtrl(ledctrl),
        .SwitchCtrl(switchctrl)
    );
	
    ioread multiioread(
        .reset(rst),
        .ior(ioread),
        .switchctrl(switchctrl),
        .ioread_data(ioread_data),
        .ioread_data_switch(ioread_data_switch)
    );
    
    leds led24(
    .led_clk(clock),
    .ledrst(rst),
    .ledwrite(iowrite),
    .ledcs(ledctrl),
    .ledaddr(address[1:0]),
    .ledwdata(write_data[15:0]),
    .ledout(led)
    );
	
    switchs switch24(
    .switclk(clock),
    .switrst(rst),
    .switchread(ioread),
    .switchcs(switchctrl),
    .switchaddr(address[1:0]),
    .switchrdata(ioread_data_switch),
    .switch_i(switch)
    );
	
endmodule