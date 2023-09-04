`timescale 1ns / 1ps

// 处理本次取指的pc
module pcControl(
    input  wire clk,
    input  wire rstn,
    input  wire[31:0] next_pc,
    input  wire[3:0] stall_Ctl,

    output reg[31:0] pc
);

always @ (posedge clk or posedge rstn) begin
    if (!rstn) begin
        pc <= 32'h00000000;
    end
    else if(stall_Ctl[0] == 0) begin
        // 说明不用stall
        pc <= next_pc;
    end
    else begin

    end
end
endmodule
