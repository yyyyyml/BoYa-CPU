`timescale 1ns / 1ps

// 处理立即数扩展
module immExt(
    input  wire[15:0] imm16,
    input  wire[1:0] ExtOp,

    output wire[31:0] ext_imm
);

assign ext_imm = 
    (ExtOp == 2'b10) ? {{16{imm16[15]}}, imm16} : // ADDIU 有符号
    {16'b0, imm16}; // LW, SW 无符号
endmodule
