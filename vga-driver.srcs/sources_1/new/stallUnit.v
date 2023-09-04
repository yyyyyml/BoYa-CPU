`timescale 1ns / 1ps

// 处理stall
module stallUnit(
	input wire[1:0] stall_in,
	output wire[3:0] stall_Ctl
);

assign stall_Ctl =
	(stall_in == 2'b01) ? 4'b0111 :
	(stall_in == 2'b11) ? 4'b0001 :
	(stall_in == 2'b10) ? 4'b1111 : 4'b0000;

endmodule
