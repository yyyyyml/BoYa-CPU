`timescale 1ns / 1ps

// 寄存器堆
module regFile(
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

reg[31:0] genReg[31:0];

initial begin
        genReg[0] <= 32'h00000000;
        genReg[1] <= 32'h00000000;
        genReg[2] <= 32'h00000000;
        genReg[3] <= 32'h00000000;
        genReg[4] <= 32'h00000000;
        genReg[5] <= 32'h00000000;
        genReg[6] <= 32'h00000000;
        genReg[7] <= 32'h00000000;
        genReg[8] <= 32'h00000000;
        genReg[9] <= 32'h00000000;
        genReg[10] <= 32'h00000000;
        genReg[11] <= 32'h00000000;
        genReg[12] <= 32'h00000000;
        genReg[13] <= 32'h00000000;
        genReg[14] <= 32'h00000000;
        genReg[15] <= 32'h00000000;
        genReg[16] <= 32'h00000000;
end
    

// 强化的读寄存器，能够处理hazard
assign reg1_data = 
        (ex_RegWrite == 1 && ex_reg_dst == rs) ? alu_res :
        (mem_RegWrite == 1 && mem_reg_dst == rs &&
        (ex_reg_dst != rs || ex_RegWrite == 0)) ? alu_res_out :
        (rs == 5'b00000) ? 32'h00000000 : 
        (RegWrite && rs == reg_write_addr) ? write_data : 
        genReg[rs];
assign reg2_data = 
        (ex_RegWrite == 1 && ex_reg_dst == rt) ? alu_res :
        (mem_RegWrite == 1 && mem_reg_dst == rt &&
        (ex_reg_dst != rt || ex_RegWrite == 0)) ? alu_res_out :
        (rt == 5'b00000) ? 32'h00000000 : 
        (RegWrite && rt == reg_write_addr) ? write_data : 
        genReg[rt];



// 写回，时序逻辑
always @ (posedge clk) begin
    if (RegWrite) begin
        genReg[reg_write_addr] <= write_data;
    end
end

// 跳转不需要stall了
assign stall_signal = ((mem_RegWrite && mem_lw) && (mem_reg_dst == rs)) ? 2'b10 :
       ((mem_RegWrite && mem_lw) && (mem_reg_dst == rt)) ? 2'b10 :
       ((ex_RegWrite && ex_lw) && (ex_reg_dst == rs)) ? 2'b01 :
       ((ex_RegWrite && ex_lw) && (ex_reg_dst == rt)) ? 2'b01 :
//        (ex_RegWrite && (ex_reg_dst == rs) && single_jump && !slt_before) ? 2'b11 :
//        (ex_RegWrite && (ex_reg_dst == rt) && single_jump && !slt_before) ? 2'b11 :
       2'b00;



endmodule
