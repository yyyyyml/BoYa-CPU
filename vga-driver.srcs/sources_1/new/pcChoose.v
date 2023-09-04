`timescale 1ns / 1ps

// 处理下一条取指的pc
module pcChoose(
           input  wire[31:0] pc,
           input  wire[15:0] imm16,
           input  wire[25:0] imm26,    
           input  wire[31:0] rs_data,
           input  wire[3 - 1:0] NPCOp,  // 控制nextPC

           output wire[31:0] next_pc,
           output wire[31:0] save_dst    // JAL
       );

wire[31:0] pc_com;

assign pc_com = pc + 32'h4;
assign save_dst = pc + 32'h8;

assign next_pc =
       (NPCOp == 3'b001) ? pc_com : // pc + 4
       (NPCOp == 3'b010) ? {pc[31:28], imm26, 2'b00} : // pc = target
       (NPCOp == 3'b011) ? {pc_com + {{14{imm16[15]}}, {imm16, 2'b00}}} : // pc + 4 + offset
       (NPCOp == 3'b100) ? rs_data : // pc = rs data
       pc_com;
endmodule
