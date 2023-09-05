`timescale 1ns / 1ps

// 中间寄存器
module regMemWb(
    input wire clk,
    input wire rstn,
    input wire[31:0] alu_res_in,
    input wire[31:0] mem_read_data_in,
    input wire[31:0] save_dst_in,
    input wire[31:0] ext_imm_in,
    input wire[4:0] dst_reg_in,

    input wire[2:0] RegSrc_in,
    input wire RegWrite_in,
    input wire memwb_lw_in,

    output reg[31:0] alu_res_out,
    output reg[31:0] mem_read_data_out,
    output reg[31:0] save_dst_out,
    output reg[31:0] ext_imm_out,
    output reg[4:0] dst_reg_out,

    output reg[2:0] RegSrc_out,
    output reg RegWrite_out,
    output reg memwb_lw_out
);



wire zeroize;
assign zeroize = !rstn;

always @ (posedge clk) begin
    if (zeroize) begin // 初始化清零
        alu_res_out <= 32'h00000000;
        mem_read_data_out <= 32'h00000000;
        save_dst_out <= 32'h00000000;
        ext_imm_out <= 32'h00000000;
        dst_reg_out <= 32'h00000000;
        RegSrc_out <= 3'b000;
        RegWrite_out <= 1'b0;
        memwb_lw_out <= 1'b0;
    end
    else begin // 直接传
        alu_res_out <= alu_res_in;
        mem_read_data_out <= mem_read_data_in;
        save_dst_out <= save_dst_in;
        ext_imm_out <= ext_imm_in;
        dst_reg_out <= dst_reg_in;
        RegSrc_out <= RegSrc_in;
        RegWrite_out <= RegWrite_in;
        memwb_lw_out <= memwb_lw_in;
    end
end
endmodule
