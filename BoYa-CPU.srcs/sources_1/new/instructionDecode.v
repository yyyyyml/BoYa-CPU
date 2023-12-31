`timescale 1ns / 1ps

module instructionDecode(
    input wire rstn,
    input wire[5:0] opcode, 
    input wire[4:0] sa,     
    input wire[5:0] func,   
    input wire equal,

    output wire RegWrite,
    output wire[1:0] ExtOp,
    output wire ALUSrc,
    output wire[3:0] ALUOp,
    output wire MemWrite,
    output wire[2:0] RegSrc,
    output wire[1:0] RegDst,
    output wire[2:0] NPCOp,
    output wire lw,
    output wire slt_cur,
    output wire single_jump
);

// Init instruction signals
wire type_r, inst_add, inst_addu, inst_sub, inst_subu, inst_and, inst_or, inst_slt, inst_sll, 
    inst_srl, inst_sllv, inst_srlv, inst_addi, inst_addiu, 
    inst_andi, inst_ori, inst_lw, inst_sw, inst_beq, inst_bne, inst_j, inst_jal;

assign type_r = (opcode == 6'b000000 ) ? 1 : 0;

// R
assign inst_add = (type_r && func == 6'b100000) ? 1 : 0;
assign inst_addu = (type_r && func == 6'b100001) ? 1 : 0;
assign inst_sub = (type_r && func == 6'b100010) ? 1 : 0;
assign inst_subu = (type_r && func == 6'b100011) ? 1 : 0;
assign inst_and = (type_r && func == 6'b100100) ? 1 : 0;
assign inst_or = (type_r && func == 6'b100101) ? 1 : 0;
assign inst_slt = (type_r && func == 6'b101010) ? 1 : 0;
assign inst_sll = (type_r && func == 6'b000000) ? 1 : 0;
assign inst_srl = (type_r && func == 6'b000010) ? 1 : 0;
assign inst_sllv= (type_r && func == 6'b000100) ? 1 : 0;
assign inst_srlv = (type_r && func == 6'b000110) ? 1 : 0;

// I
assign inst_addi = (opcode == 6'b001000) ? 1 : 0;
assign inst_andi = (opcode == 6'b001100) ? 1 : 0;
assign inst_ori = (opcode == 6'b001101) ? 1 : 0;
assign inst_addiu = (opcode == 6'b001001) ? 1 : 0;
assign inst_lw = (opcode == 6'b100011) ? 1 : 0;
assign inst_sw = (opcode == 6'b101011) ? 1 : 0;
assign inst_beq = (opcode == 6'b000100) ? 1 : 0;
assign inst_bne = (opcode == 6'b000101) ? 1 : 0;

// J
assign inst_j = (opcode == 6'b000010) ? 1 : 0;
assign inst_jal = (opcode == 6'b000011) ? 1 : 0;

// 设置需要的输出信号

// LW
assign lw = inst_lw ? 1 : 0;

// ALUOp
assign ALUOp =
    (inst_addi || inst_addiu || inst_add || inst_addu || inst_lw || inst_sw) ? 4'b0001 : // ADD
    (inst_sub || inst_subu || inst_beq) ? 4'b0010 : // SUB
    (inst_slt) ? 4'b0011 : // SLT
    (inst_and || inst_andi) ? 4'b0100 : // AND
    (inst_or || inst_ori) ? 4'b0101 : // OR
    (inst_sll) ? 4'b1000 : // SLL
    (inst_srl) ? 4'b1001 : // SRL
    (inst_sllv) ? 4'b1011 : // SLLV
    (inst_srlv) ? 4'b1100 : // SRLV
    4'b0000;

assign RegDst =
    (inst_add || inst_addu || inst_sub || inst_subu || inst_and || inst_or ||
    inst_slt || inst_sll || inst_srl || inst_sllv || inst_srlv) ? 
    2'b10 :
    (inst_addi || inst_addiu|| inst_andi || inst_ori || inst_lw) ? 
    2'b01 :
    (inst_jal) ? 
    2'b11 : 2'b00 ;

assign ALUSrc =
    (inst_addi || inst_addiu || inst_andi || inst_ori || inst_lw || inst_sw) ? 1 : 0;

assign RegWrite =
    (type_r || inst_addi || inst_addiu || inst_andi || inst_ori ||
    inst_add || inst_addu || inst_sub || inst_subu || inst_and || inst_or || inst_slt ||
    inst_sll || inst_srl || inst_sllv || inst_srlv || inst_lw || inst_jal) ? 1 : 0;

assign MemWrite = (inst_sw) ? 1 : 0;

assign RegSrc =
    (inst_addi || inst_addiu || inst_andi || inst_ori || inst_add || inst_addu || inst_sub || inst_subu || 
    inst_and || inst_or || inst_slt || inst_sll || inst_srl || inst_sllv || inst_srlv) ? 
    3'b001 :
    (inst_lw) ? 3'b010 : 
    (inst_jal) ? 3'b100 : 
    3'b000;

// ExtOp
assign ExtOp =
    (inst_add || inst_addiu) ? 2'b10 : // 有符号
    (inst_andi || inst_ori || inst_lw || inst_sw) ? 2'b11 : // 无符号
    2'b00;

// NPCOp
assign NPCOp =
    // 不跳的
    (inst_lw || inst_sw || inst_addi || inst_addiu || inst_andi || inst_ori ||
    inst_add || inst_addu || inst_sub || inst_subu || inst_and || inst_or || 
    inst_slt || inst_sll || inst_srl || inst_sllv || inst_srlv) ? 
    3'b001 :
    // BEQ
    (inst_beq && !equal) ? 3'b001 : // 不跳
    (inst_beq && equal) ? 3'b011 : // 跳
    // BNE
    (inst_bne && equal) ? 3'b001 : // 不跳
    (inst_bne && !equal) ? 3'b011 : // 跳
    // J
    (inst_j || inst_jal) ? 3'b010 :
    (inst_j) ? 3'b010 :
     3'b000;
    // 有用的输出信号
    assign slt_cur = inst_slt;
    assign single_jump = (inst_beq || inst_bne) ? 1 : 0;

endmodule
