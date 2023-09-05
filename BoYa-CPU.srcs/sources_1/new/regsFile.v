`timescale 1ns / 1ps

// 寄存器堆
module regsFile(
	input  wire clk,
	input  wire[4:0] rs,
	input  wire[4:0] rt,
	input  wire[4:0] reg_write_addr, // 来自WB
	input  wire[31:0] write_data, 
	input  wire[4:0] ex_reg_dst,  // 来自EX
	input  wire[4:0] mem_reg_dst,  // 来自MEM
	input  wire single_jump,
	input  wire slt_before,
	input  wire RegWrite,   
	input  wire ex_RegWrite,
	input  wire mem_RegWrite,
	input  wire ex_lw,
	input  wire mem_lw,
	input wire[31:0] alu_res,
	input wire[31:0] alu_res_out,

	output wire[31:0] reg1_data,
	output wire[31:0] reg2_data,
	output wire[1:0]  stall_signal

);

reg[31:0] regs[31:0];

initial begin
	regs[0] <= 32'h00000000;
	regs[1] <= 32'h00000000;
	regs[2] <= 32'h00000000;
	regs[3] <= 32'h00000000;
	regs[4] <= 32'h00000000;
	regs[5] <= 32'h00000000;
	regs[6] <= 32'h00000000;
	regs[7] <= 32'h00000000;
	regs[8] <= 32'h00000000;
	regs[9] <= 32'h00000000;
	regs[10] <= 32'h00000000;
	regs[11] <= 32'h00000000;
	regs[12] <= 32'h00000000;
	regs[13] <= 32'h00000000;
	regs[14] <= 32'h00000000;
	regs[15] <= 32'h00000000;
	regs[16] <= 32'h00000000;
end
    

// 强化的读寄存器，能够处理hazard
assign reg1_data = 
	(ex_RegWrite == 1 && ex_reg_dst == rs) ? alu_res :
	(mem_RegWrite == 1 && mem_reg_dst == rs && (ex_reg_dst != rs || ex_RegWrite == 0)) ? alu_res_out :
	(rs == 5'b00000) ? 32'h00000000 : 
	(RegWrite && rs == reg_write_addr) ? write_data : 
	regs[rs];
assign reg2_data = 
	(ex_RegWrite == 1 && ex_reg_dst == rt) ? alu_res :
	(mem_RegWrite == 1 && mem_reg_dst == rt && (ex_reg_dst != rt || ex_RegWrite == 0)) ? alu_res_out :
	(rt == 5'b00000) ? 32'h00000000 : 
	(RegWrite && rt == reg_write_addr) ? write_data : 
	regs[rt];



// 写回，时序逻辑
always @ (posedge clk) begin
    if (RegWrite) begin
        regs[reg_write_addr] <= write_data;
    end
end

// 跳转不需要stall了
// 先判断上一条或上上一条是不是相关的lw
assign stall_signal = 
	((ex_RegWrite && ex_lw) && (ex_reg_dst == rs)) ? 2'b01 :
	((ex_RegWrite && ex_lw) && (ex_reg_dst == rt)) ? 2'b01 :
	((mem_RegWrite && mem_lw) && (mem_reg_dst == rs)) ? 2'b01 :
	((mem_RegWrite && mem_lw) && (mem_reg_dst == rt)) ? 2'b01 :
	2'b00;

endmodule
