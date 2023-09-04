`timescale 1ns / 1ps

// 单独的beq/bne条件判断用
module singleJumpPredict(
           input wire[31:0] reg1_data,
           input wire[31:0] reg2_data,
           input wire[31:0] reg1_data_forward,
           input wire[31:0] reg2_data_forward,
        //    input wire single_jump,
           input wire[1:0]  stall_pre,
           output wire zero //判断跳转结果
           
       );

wire[32:0] comp;

assign comp = 
        (stall_pre == 2'b11) ? // 说明上一条是被stall的beq/bne
        {reg1_data_forward[31], reg1_data_forward} - {reg2_data_forward[31], reg2_data_forward} : 
        {reg1_data[31], reg1_data} - {reg2_data[31], reg2_data};
        
assign zero = (comp == 0) ? 1'b1 : 1'b0;
endmodule

