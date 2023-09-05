`timescale 1ns / 1ps

// 单独的beq/bne条件判断用
// 其实可能只需要reg1_data和reg2_data就可以计算了，但是不改了
module jumpConditionCalculate(
	input wire[31:0] reg1_data,
	input wire[31:0] reg2_data,
	//    input wire single_jump,
	output wire zero //判断跳转结果

);

wire[32:0] comp;

assign comp = {reg1_data[31], reg1_data} - {reg2_data[31], reg2_data};
        
assign zero = (comp == 0) ? 1'b1 : 1'b0;
endmodule

