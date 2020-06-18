`timescale 1ns / 1ps


module minisys_sim(
    );
    
    reg clk = 0;
    reg rst = 1;
	reg [23:0]switch2N4=24'b101011000000000000000000;
	wire [23:0]led2N4;
    minisys_sc u (.clk(clk),.rst(rst),.led(led2N4),.switch(switch2N4));
    initial begin
        #7000 rst = 0;
    end
    always #10 clk=~clk;
        
endmodule
