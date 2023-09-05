`timescale 1ns / 1ps

// 处理数据hazard的前递单元
module forwardUnit(
	input  wire exmem_RegWrite,
	input  wire[4:0] exmem_RegDst,
	input  wire[4:0] idex_rs,
	input  wire[4:0] idex_rt,
	input  wire memwb_RegWrite,
	input  wire[4:0] memwb_RegDst,

	output wire[1:0] forward_A,
	output wire[1:0] forward_B
);

// 前递两种，在ex后递过去或在mem后递过去
assign forward_A = 
	(exmem_RegWrite == 1 && exmem_RegDst == idex_rs) ? 2'b10:
	(memwb_RegWrite == 1 && memwb_RegDst == idex_rs && (exmem_RegDst != idex_rs || exmem_RegWrite == 0)) ? 2'b01 : 
	2'b00;

assign forward_B = 
	(exmem_RegWrite == 1 && exmem_RegDst == idex_rt) ? 2'b10:	
	(memwb_RegWrite == 1 && memwb_RegDst == idex_rt && (exmem_RegDst != idex_rt || exmem_RegWrite == 0)) ? 2'b01 : 
	2'b00;

endmodule
