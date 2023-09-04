`timescale 1ns / 1ps

// 使用的全部选择器
module reg_dst_mux(
           input  wire[2 - 1:0] reg_dst,
           input  wire[4:0] rt,
           input  wire[4:0] rd,
                  
           output wire[4:0] mux_out
       );
wire[4:0] reg_31;
assign reg_31 = 5'b11111;

assign mux_out = 
       (reg_dst == 2'b01) ? rt :
       (reg_dst == 2'b10) ? rd :
       (reg_dst == 2'b11) ? reg_31 :
       rt;
endmodule

module alu_src_mux(
           input  wire  alu_src,
           input  wire[31:0] rt,
           input  wire[31:0] imm,

           output wire[31:0] mux_out
    );

assign mux_out = (alu_src == 1'b0) ? rt : imm;
endmodule

module reg_src_mux(
           input  wire[3 - 1:0] reg_src,
           input  wire[31:0] alu_res,
           input  wire[31:0] mem_read_data,
           input  wire[31:0] ext_imm,
           input  wire[31:0] save_dst,

           output wire[31:0] mux_out
    );

assign mux_out = 
       (reg_src == 3'b001 ) ? alu_res :
       (reg_src == 3'b010) ? mem_read_data :
       (reg_src == 3'b011) ? ext_imm :
       (reg_src == 3'b100) ? save_dst :
       alu_res;
endmodule

module forward_mux(
           input  wire[1:0] forward_C,
           input  wire[31:0] rsrt_imm,
           input  wire[31:0] write_data,
           input  wire[31:0] alu_res,

           output wire[31:0] mux_out
);

assign mux_out = 
        (forward_C == 2'b10) ? alu_res :
        (forward_C == 2'b01) ? write_data :
        rsrt_imm;
endmodule

module equal_mux(
           input  wire zero,
           input  wire zero2,
           input  wire slt_before,

           output wire equal
    );

assign equal = (slt_before == 1'b1 ) ? zero : zero2;

endmodule
