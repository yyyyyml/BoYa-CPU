`timescale 1ns / 1ps

// 顶层cpu模块
module top(
    input wire clk,
    input wire rstn,
    
    output wire hs,
    output wire vs,
    output wire[3:0] red,
    output wire[3:0] green,
    output wire[3:0] blue
);
wire[23:0] set_data;
reg [31:0] cnt;
always@(posedge clk or negedge rstn ) 
begin
   if(!rstn)
       cnt <= 32'd0;
   else if (cnt <= 32'd5000000)
       cnt <= cnt +1'b1;
   else
       cnt <= 32'd0;
end

// 放慢时钟周期，便于观察排序结果
reg clk1;
always@(posedge clk or negedge rstn ) 
begin
   if(!rstn)
       clk1 <= 1'b0;
   else if (cnt < 32'd2500000) 
       clk1 <= 1'b0;
   else
       clk1 <= 1'b1;
end

// vga模块
vga_top Vga_top(
    .clk (clk),
    .rstn (rstn),
    .show_dataTemp (set_data),
    .hs (hs),
    .vs (vs),
    .red (red),
    .green (green),
    .blue (blue)
);

//dig8_4 Dig8_4(
//           .clk (clk1),
//           .rstn (rstn),
//           .set_data (set_data),
//           .dig (dig),
//           .dict (dict),
//           .dict2 (dict2)
//       );

// ################################# IFID周期开始 #################################

wire[31:0] pc;
wire[31:0] next_pc;
wire[31:0] instruction;
wire[1:0] stall_Ctl; // 过一次寄存器输出的stall信号

pcControl PcControl(
    .clk (clk),
    .rstn (rstn),
    .next_pc (next_pc),
    .stall_Ctl (stall_Ctl),
    .pc (pc)
);

instructionMemory InstructionMemory(
    .instruction_addr (pc[11:2] ),
    .instruction (instruction )
);


wire[5:0] opcode;
wire[5:0] func;
wire[4:0] rs;
wire[4:0] rt;
wire[4:0] rd;
wire[4:0] sa;
wire[15:0] imm16;
wire[25:0] imm26;

assign opcode = instruction[31:26];
assign func = instruction[5:0];
assign rs = instruction[25:21];
assign rt = instruction[20:16];
assign rd = instruction[15:11];
assign sa = instruction[10:6];
assign imm16 = instruction[15:0];
assign imm26 = instruction[25:0];

wire[4:0] reg_write_addr;
wire[31:0] write_data;
wire[31:0] reg1_data;
wire[31:0] reg2_data;

wire zero;
wire regfile_zero;
wire RegWrite;
wire[1:0] ExtOp;
wire ALUSrc;
wire[3:0] ALUOp;
wire MemWrite;
wire[2:0] RegSrc;
wire[1:0] RegDst;
wire[2:0] NPCOp;
wire lw;
wire equal; // 判断beq或bne是否相等
wire slt_cur; // 当前是不是slt
wire single_jump; // 当前是不是bne/beq

instructionDecode InstructionDecode(
    .rstn (rstn),
    .opcode (opcode),
    .sa (sa),
    .func (func),
    .equal (equal),
    .RegWrite (RegWrite),
    .ExtOp (ExtOp),
    .ALUSrc (ALUSrc),
    .ALUOp (ALUOp),
    .MemWrite (MemWrite),
    .RegSrc (RegSrc),
    .RegDst (RegDst),
    .NPCOp (NPCOp),
    .lw (lw),
    .slt_cur (slt_cur),
    .single_jump (single_jump)
);

wire[4:0] dst_reg_wb;
wire RegWrite_wb;
wire[4:0] dst_reg;
wire[4:0] dst_reg_out;
wire RegWrite_out;
wire mem_RegWrite;
wire idex_lw_out;
wire exmem_lw_out;
wire[31:0] alu_res_out;
wire[31:0] alu_res;
wire slt_out;

regsFile RegsFile(
    .clk (clk), // 只是用来写入的，读是组合逻辑
    .rs (rs),
    .rt (rt),
    .reg_write_addr (dst_reg_wb ),
    .write_data (write_data),
    .ex_reg_dst (dst_reg),
    .mem_reg_dst (dst_reg_out),
    .single_jump (single_jump),
    .slt_before (slt_out),
    .RegWrite (RegWrite_wb),
    .ex_RegWrite(RegWrite_out),
    .mem_RegWrite(mem_RegWrite),
    .ex_lw (idex_lw_out),
    .mem_lw (exmem_lw_out),
    .alu_res (alu_res),
    .alu_res_out (alu_res_out),
    .reg1_data (reg1_data),
    .reg2_data (reg2_data),
    .stall_signal (stall_Ctl)
);

wire[31:0] save_dst;

pcChoose PcChoose(
    .pc (pc),
    .imm16 (imm16),
    .imm26 (imm26),
    .rs_data (reg1_data),
    .NPCOp (NPCOp),
    .next_pc (next_pc),
    .save_dst (save_dst)
);

wire[31:0] forward_mux_out_1;
wire[31:0] forward_mux_out_2;
wire zero2;

jumpConditionCalculate JumpConditionCalculate(
    .reg1_data (reg1_data),
    .reg2_data (reg2_data),
//  .single_jump (single_jump),
    .zero (zero2)
);

wire[31:0] reg1_data_out;
wire[31:0] reg2_data_out;
wire[31:0] save_dst_out;
wire[4:0] rs_out;
wire[4:0] rt_out;
wire[4:0] rd_out;
wire[4:0] sa_out;
wire[15:0] imm16_out;
wire[1:0] ExtOp_out;
wire  ALUSrc_out;
wire[3:0] ALUOp_out;
wire MemWrite_out;
wire[2:0] RegSrc_out;
wire[1:0] RegDst_out;
wire[31:0] mem_read_data;
wire[31:0] mem_read_data_out;

// ################################# IFID周期结束 #################################

regIdEx RegIdEx(
    .clk (clk),
    .rstn (rstn),
    .reg1_data_in (reg1_data),
    .reg2_data_in (reg2_data),
    .save_dst_in (save_dst),
    .rs_in (rs),
    .rt_in (rt),
    .rd_in (rd),
    .sa_in (sa),
    .imm16_in (imm16),
    .RegWrite_in (RegWrite),
    .idex_lw_in (lw),
    .ExtOp_in (ExtOp),
    .ALUSrc_in (ALUSrc),
    .ALUOp_in (ALUOp),
    .MemWrite_in (MemWrite),
    .RegSrc_in (RegSrc),
    .RegDst_in (RegDst),
    .slt_in (slt_cur),
    .stall_Ctl (stall_Ctl),
    .lw_stall_data (mem_read_data),
    .lw_mem_addr (dst_reg_out),
    .reg1_data_out (reg1_data_out),
    .reg2_data_out (reg2_data_out),
    .save_dst_out (save_dst_out),
    .rs_out (rs_out),
    .rt_out (rt_out),
    .rd_out (rd_out),
    .sa_out (sa_out),
    .imm16_out (imm16_out),
    .RegWrite_out (RegWrite_out),
    .idex_lw_out (idex_lw_out),
    .ExtOp_out (ExtOp_out),
    .ALUSrc_out (ALUSrc_out),
    .ALUOp_out (ALUOp_out),
    .MemWrite_out (MemWrite_out),
    .RegSrc_out (RegSrc_out),
    .RegDst_out (RegDst_out),
    .slt_out (slt_out)
);

// ################################# EX周期开始 #################################

wire[31:0] ext_imm;

immExt ImmExt(
    .imm16 (imm16_out),
    .ExtOp (ExtOp_out ),
    .ext_imm (ext_imm)
);


reg_dst_mux Reg_dst_mux(
    .reg_dst (RegDst_out),
    .rt(rt_out),
    .rd (rd_out),
    .mux_out (dst_reg)
);

wire[31:0] alu_src_mux_out;

// wire[31:0] forward_mux_out_1;
// wire[31:0] forward_mux_out_2;

alu_src_mux Alu_src_mux(
    .alu_src (ALUSrc_out),
    .rt (forward_mux_out_2 ),
    .imm (ext_imm),
    .mux_out (alu_src_mux_out)
);


alu ALU(
    .alu_op1 (forward_mux_out_1 ),
    .alu_op2 (alu_src_mux_out),
    .sa (sa_out),
    .ALUOp (ALUOp_out),
    .alu_res (alu_res),
    .zero (zero)
);

equal_mux Equal_mux(
    .zero (zero),
    .zero2 (zero2),
    .slt_before (slt_out),

    .equal (equal)
);

wire[1:0] forward_A;
wire[1:0] forward_B;

wire  MemWrite_mem;
wire[2:0] RegSrc_mem;


wire[31:0] reg2_data_mem;
wire[31:0] ext_imm_out;

forwardUnit ForwardUnit(
    .exmem_RegWrite (mem_RegWrite),
    .exmem_RegDst (dst_reg_out ),
    .idex_rs (rs_out),
    .idex_rt (rt_out),
    .memwb_RegWrite (RegWrite_wb),
    .memwb_RegDst (dst_reg_wb),
    .forward_A (forward_A),
    .forward_B (forward_B)
);

forward_mux Forward_mux1(
    .forward_C (forward_A),
    .rsrt_imm (reg1_data_out),
    .write_data (write_data ),
    .alu_res (alu_res_out),
    .mux_out (forward_mux_out_1)
);

forward_mux Forward_mux2(
    .forward_C (forward_B),
    .rsrt_imm (reg2_data_out),
    .write_data (write_data),
    .alu_res (alu_res_out),
    .mux_out (forward_mux_out_2)
);

wire[31:0] save_dst_mem;

// ################################# EX周期结束 #################################

regExMem RegExMem(
    .clk (clk),
    .rstn (rstn),
    .alu_res_in (alu_res),
    .reg2_data_in (reg2_data_out),
    .save_dst_in (save_dst_out),
    .ext_imm_in (ext_imm),
    .dst_reg_in (dst_reg),
    .MemWrite_in (MemWrite_out),
    .RegSrc_in(RegSrc_out),
    .RegWrite_in (RegWrite_out),
    .exmem_lw_in (idex_lw_out),
    .alu_res_out (alu_res_out),
    .reg2_data_out (reg2_data_mem),
    .save_dst_out (save_dst_mem),
    .ext_imm_out (ext_imm_out),
    .dst_reg_out (dst_reg_out),
    .MemWrite_out (MemWrite_mem),
    .RegSrc_out (RegSrc_mem),
    .RegWrite_out (mem_RegWrite),
    .exmem_lw_out (exmem_lw_out)
);

// ################################# MEM周期开始 #################################

dataMemory DataMemory(
    .clk (clk), // 只是用来写，读是组合逻辑
    .MemWrite (MemWrite_mem),
    .mem_addr (alu_res_out[11:2]),
    .mem_write_data (reg2_data_mem),
    .mem_read_data (mem_read_data),
    .set_data (set_data)
);

wire[31:0] alu_res_wb;
wire[31:0] ext_imm_wb;
wire[2:0] RegSrc_wb;

wire[31:0] save_dst_wb;
wire memwb_lw_out;

// ################################# MEM周期结束 #################################

regMemWb RegMemWb(
    .clk (clk),
    .rstn (rstn),
    .alu_res_in (alu_res_out),
    .mem_read_data_in (mem_read_data),
    .save_dst_in (save_dst_mem),
    .ext_imm_in  (ext_imm_out),
    .dst_reg_in (dst_reg_out ),
    .memwb_lw_in (exmem_lw_out),
    .RegSrc_in (RegSrc_mem),
    .RegWrite_in (mem_RegWrite),
    .alu_res_out (alu_res_wb),
    .mem_read_data_out (mem_read_data_out),
    .save_dst_out (save_dst_wb),
    .ext_imm_out (ext_imm_wb),
    .dst_reg_out (dst_reg_wb  ),
    .RegSrc_out (RegSrc_wb),
    .RegWrite_out (RegWrite_wb),
    .memwb_lw_out (memwb_lw_out)
);

// ################################# WB周期开始 #################################


// 得到了write_data，真正写入要再等一个周期
reg_src_mux Reg_src_mux(
    .reg_src (RegSrc_wb),
    .alu_res (alu_res_wb),
    .mem_read_data (mem_read_data_out ),
    .ext_imm (ext_imm_wb),
    .save_dst (save_dst_wb),
    .mux_out (write_data)
);

// ################################# WB周期结束 #################################

endmodule