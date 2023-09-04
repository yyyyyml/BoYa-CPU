`timescale 1ns / 1ps

module regIdEx(
    input  wire clk,
    input  wire rstn,
    input  wire[31:0] reg1_data_in,
    input  wire[31:0] reg2_data_in,
    input  wire[31:0] save_dst_in,
    input  wire[4:0] rs_in,
    input  wire[4:0] rt_in,
    input  wire[4:0] rd_in,
    input  wire[4:0] sa_in,
    input  wire[15:0] imm16_in,

    input wire RegWrite_in,
    input wire idex_lw_in,
    input wire[2 - 1:0] ExtOp_in,
    input wire ALUSrc_in,
    input wire[4 - 1:0] ALUOp_in,
    input wire MemWrite_in,
    input wire[3 - 1:0] RegSrc_in,
    input wire[2 - 1:0] RegDst_in,
    input wire slt_in,
    input wire[1:0] stall_Ctl,
    input wire[31:0] lw_stall_data, 
    input wire[4:0] lw_mem_addr,

    output reg[31:0] reg1_data_out,
    output reg[31:0] reg2_data_out,
    output reg[31:0] save_dst_out,
    output reg[4:0] rs_out,
    output reg[4:0] rt_out,
    output reg[4:0] rd_out,
    output reg[4:0] sa_out,
    output reg[15:0] imm16_out,

    output reg RegWrite_out,
    output reg idex_lw_out,
    output reg[2  - 1:0] ExtOp_out,
    output reg ALUSrc_out,
    output reg[4 - 1:0] ALUOp_out,
    output reg MemWrite_out,
    output reg[3 - 1:0] RegSrc_out,
    output reg[2 - 1:0] RegDst_out,
    output reg[1:0] stall_out,
    output reg slt_out
);

wire zeroize;
assign zeroize = !rstn;

always @ (posedge clk) begin

    if (zeroize) begin // 初始化清零
        reg1_data_out <= 32'h00000000;
        reg2_data_out <= 32'h00000000;
        save_dst_out <= 32'h00000000;
        rs_out <= 5'b00000;
        rt_out <= 5'b00000;
        rd_out <= 5'b00000;
        sa_out <= 5'b00000;
        imm16_out <= 16'h0000;

        RegWrite_out <= 1'b0 ;
        idex_lw_out <= 1'b0;
        ExtOp_out <= 2'b00;
        ALUSrc_out <= 1'b0;
        ALUOp_out <= 4'b0000;
        MemWrite_out <= 1'b0;
        RegSrc_out <= 3'b000;
        RegDst_out <= 'b00 ;
        stall_out <= 2'b00;
        slt_out <= 1'b0;
    end
    else if(stall_Ctl == 2'b00) begin // 没stall的情况，基本正常传
        reg1_data_out <= reg1_data_in;
        reg2_data_out <= reg2_data_in;
        save_dst_out <= save_dst_in;
        rs_out <= rs_in;
        rt_out <= rt_in;
        rd_out <= rd_in;
        sa_out <= sa_in;
        imm16_out <= imm16_in;

        RegWrite_out <= RegWrite_in;
        idex_lw_out  <= idex_lw_in;
        ExtOp_out <= ExtOp_in;
        ALUSrc_out <= ALUSrc_in;
        ALUOp_out    <= ALUOp_in;
        MemWrite_out <= MemWrite_in;
        RegSrc_out   <= RegSrc_in;
        RegDst_out   <= RegDst_in;
        stall_out <= 2'b00;
        slt_out <= slt_in;
    end
    else if(stall_Ctl == 2'b01) begin // 有stall，这个寄存器要清零，为了不让这条stall的指令传下去
        reg1_data_out <= 32'h00000000;
        reg2_data_out <= 32'h00000000;
        save_dst_out <= 32'h00000000;
        rs_out <= 5'b00000;
        rt_out <= 5'b00000;
        rd_out <= 5'b00000;
        sa_out <= 5'b00000;
        imm16_out <= 16'h0000;

        RegWrite_out <= 1'b0 ;
        idex_lw_out <= 1'b0;
        ExtOp_out <= 2'b00;
        ALUSrc_out <= 1'b0;
        ALUOp_out <= 4'b0000;
        MemWrite_out <= 1'b0;
        RegSrc_out <= 3'b000;
        RegDst_out <= 'b00 ;
        stall_out <= 2'b00;
        slt_out <= 1'b0;
    end
    else begin // 

    end
end

endmodule
