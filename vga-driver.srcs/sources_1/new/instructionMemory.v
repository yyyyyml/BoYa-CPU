`timescale 1ns / 1ps

// IM
module instructionMemory(
	input  wire[11:2] instruction_addr, 

	output wire[31:0] instruction
);

reg[31:0] instMem[31:0];
assign instruction = instMem[instruction_addr];
// 冒泡排序程序
initial begin
	instMem[0] <= 32'h20040000;
	instMem[1] <= 32'h24050006;
	instMem[2] <= 32'h24080000;
	instMem[3] <= 32'h24090001;
	instMem[4] <= 32'h1125000b;
	instMem[5] <= 32'h00095880;
	instMem[6] <= 32'h008b5820;
	instMem[7] <= 32'h8d6cfffc;
	instMem[8] <= 32'h8d6d0000;
	instMem[9] <= 32'h018d082a;
	instMem[10] <= 32'h14200003;
	instMem[11] <= 32'h24080001;
	instMem[12] <= 32'had6c0000;
	instMem[13] <= 32'had6dfffc;
	instMem[14] <= 32'h21290001;
	instMem[15] <= 32'h0c000c04;
	instMem[16] <= 32'h150ffff1;
end

endmodule
