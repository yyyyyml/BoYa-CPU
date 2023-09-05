`timescale 1ns / 1ps

module testbench();
reg clk;
reg rstn;

top Top(clk, rstn);
initial begin
    clk = 0;
    rstn = 0;

    #37 rstn = 1;
end

always
    #20 clk = ~clk; // 每隔 20ns 时钟信号 clk 翻转一次

endmodule
