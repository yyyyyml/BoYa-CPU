`timescale 1ns / 1ps

module controlUnit(
           input wire rst,
           input wire[5:0] opcode, 
           input wire[4:0] sa,     
           input wire[5:0] func,   
           input wire equal,

           output wire RegWrite,
           output wire[2 - 1:0] ExtOp,
           output wire ALUSrc,
           output wire[4 - 1:0] ALUOp,
           output wire MemWrite,
           output wire[3 - 1:0] RegSrc,
           output wire[2 - 1:0] RegDst,
           output wire[3 - 1:0] NPCOp,
           output wire lw,
           output wire slt_cur,
           output wire single_jump
       );

// Init instruction signals
wire type_r, inst_add, inst_addu, inst_sub, inst_subu, inst_slt, 
inst_sltu, inst_and, inst_or, inst_nor, inst_xor, inst_sll, 
inst_srl, inst_sra, inst_sllv, inst_srlv, inst_srav, inst_jr, 
inst_addi, inst_addiu, inst_sltiu, 
inst_andi, inst_ori, inst_xori, inst_lui, inst_lw, inst_sw, 
inst_beq, inst_bne, inst_j, inst_jal;

/* --- Decode instructions --- */

// Whether instruction is R-Type
assign type_r = (opcode == 6'b000000 ) ? 1 : 0;
// R
assign inst_add = (type_r && func == 6'b100000 ) ? 1 : 0;
assign inst_addu = (type_r && func == 6'b100001 ) ? 1 : 0;
assign inst_sub = (type_r && func == 6'b100010 ) ? 1 : 0;
assign inst_subu = (type_r && func == 6'b100011 ) ? 1 : 0;
assign inst_slt = (type_r && func == 6'b101010  ) ? 1 : 0;
assign inst_sltu = (type_r && func == 6'b101011 ) ? 1 : 0;
assign inst_and = (type_r && func == 6'b100100  ) ? 1 : 0;
assign inst_or = (type_r && func == 6'b100101   ) ? 1 : 0;
assign inst_nor = (type_r && func == 6'b100111  ) ? 1 : 0;
assign inst_xor = (type_r && func == 6'b100110  ) ? 1 : 0;
assign inst_sll = (type_r && func == 6'b000000  ) ? 1 : 0;
assign inst_srl = (type_r && func == 6'b000010  ) ? 1 : 0;
assign inst_sra = (type_r && func == 6'b000011  ) ? 1 : 0;
assign inst_sllv= (type_r && func == 6'b000100 ) ? 1 : 0;
assign inst_srlv = (type_r && func == 6'b000110 ) ? 1 : 0;
assign inst_srav = (type_r && func == 6'b000111 ) ? 1 : 0;
assign inst_jr = (type_r && func == 6'b001000   ) ? 1 : 0;

// I
assign inst_addi = (opcode == 6'b001000  ) ? 1 : 0;
assign inst_addiu = (opcode == 6'b001001 ) ? 1 : 0;
assign inst_sltiu = (opcode == 6'b001011 ) ? 1 : 0;
assign inst_andi = (opcode == 6'b001100  ) ? 1 : 0;
assign inst_ori = (opcode == 6'b001101   ) ? 1 : 0;
assign inst_xori = (opcode == 6'b001110  ) ? 1 : 0;
assign inst_lui = (opcode == 6'b001111  ) ? 1 : 0;
assign inst_lw = (opcode == 6'b100011  ) ? 1 : 0;
assign inst_sw = (opcode == 6'b101011 ) ? 1 : 0;
assign inst_beq = (opcode == 6'b000100 ) ? 1 : 0;
assign inst_bne = (opcode == 6'b000101 ) ? 1 : 0;

// J
assign inst_j         = (opcode == 6'b000010   ) ? 1 : 0;
assign inst_jal       = (opcode == 6'b000011   ) ? 1 : 0;

// 设置需要的输出信号

// LW
assign lw = inst_lw ? 1 : 0;

// ALUOp
assign ALUOp =
       (inst_addi || inst_addiu || inst_add ||
        inst_addu || inst_lw  || inst_sw) ? 4'b0001  : // ADD
       (inst_sub || inst_subu  || inst_beq) ? 4'b0010  : // SUB
       (inst_slt || inst_sltu  || inst_sltiu) ? 4'b0011  : // SLT
       (inst_and || inst_andi) ? 4'b0100  : // AND
       (inst_or || inst_ori) ? 4'b0101   : // OR
       (inst_xor || inst_xori) ? 4'b0110  : // XOR
       (inst_nor) ? 4'b0111  : // NOR
       (inst_sll) ? 4'b1000  : // SLL
       (inst_srl) ? 4'b1001  : // SRL
       (inst_sra) ? 4'b1010  : // SRA
       (inst_sllv) ? 4'b1011 : // SLLV
       (inst_srlv) ? 4'b1100 : // SRLV
       (inst_srav) ? 4'b1101 : // SRAV
       4'b0000;

assign RegDst =
       (inst_add || inst_addu  || inst_sub   || inst_subu  ||
        inst_slt   || inst_sltu  || inst_and   || inst_or    ||
        inst_nor   || inst_xor   || inst_sll   || inst_srl   ||
        inst_sra   || inst_sllv  || inst_srlv  || inst_srav) ? 2'b10 :
       (inst_lui   || inst_addi  || inst_addiu || inst_sltiu ||
        inst_andi  || inst_ori   || inst_xori  || inst_lw) ? 2'b01 :
        (inst_jal) ? 2'b11 : 2'b00 ;

assign ALUSrc =
       (inst_addi  || inst_addiu || inst_sltiu || inst_andi ||
        inst_ori   || inst_xori  || inst_lw    || inst_sw) ? 1 : 0;

assign RegWrite =
       (inst_lui   || type_r     || inst_addi  || inst_addiu ||
        inst_sltiu || inst_andi  || inst_ori   || inst_xori  ||
        inst_add   || inst_addu  || inst_sub   || inst_subu  ||
        inst_slt   || inst_sltu  || inst_and   || inst_or    ||
        inst_nor   || inst_xor   || inst_sll   || inst_srl   ||
        inst_sra   || inst_sllv  || inst_srlv  || inst_srav  ||
        inst_lw || inst_jal) ? 1 : 0;

assign MemWrite = (inst_sw) ? 1 : 0;

assign RegSrc =
       (inst_lui) ? 3'b011 :
       (inst_addi || inst_addiu || inst_sltiu || inst_andi ||
        inst_ori || inst_xori || inst_add || inst_addu ||
        inst_sub || inst_subu || inst_slt || inst_sltu ||
        inst_and || inst_or || inst_nor || inst_xor ||
        inst_sll || inst_srl || inst_sra || inst_sllv ||
        inst_srlv || inst_srav) ? 3'b001 :
       (inst_lw) ? 3'b010 : 
       (inst_jal) ? 3'b100 : 3'b000;

// ExtOp
assign ExtOp =
       // shift left 16
       (inst_lui) ? 2'b01 :
       // signed extend
       (inst_add || inst_addiu || inst_sltiu) ? 2'b10 :
       // unsigned extend
       (inst_andi || inst_ori || inst_xori  ||
        inst_lw || inst_sw) ? 2'b11 : 2'b00;

// NPCOp
assign NPCOp =
       // normal: next instruction
       (inst_lui   || inst_lw    || inst_sw    || inst_addi  ||
        inst_addiu || inst_sltiu || inst_andi  || inst_ori   ||
        inst_xori  || inst_add   || inst_addu  || inst_sub   ||
        inst_subu  || inst_slt   || inst_sltu  || inst_and   ||
        inst_or    || inst_nor   || inst_xor   || inst_sll   ||
        inst_srl   || inst_sra   || inst_sllv  || inst_srlv  ||
        inst_srav) ? 3'b001 :

       // BEQ
       // normal: next instruction
       (inst_beq && !equal) ? 3'b001 :
       // jump to target
       (inst_beq &&  equal) ? 3'b011 :

       // BNE
       // normal: next instruction
       (inst_bne &&  equal) ? 3'b001 :
       // jump to target
       (inst_bne && !equal) ? 3'b011 :
       (inst_j   || inst_jal)  ? 3'b010 :
       (inst_j)  ? 3'b010 : (inst_jr) ? 3'b100 : 3'b000;

       assign slt_cur = inst_slt;
       assign single_jump = (inst_beq   || inst_bne) ? 1 : 0;

endmodule
