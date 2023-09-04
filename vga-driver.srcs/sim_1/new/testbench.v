`timescale 1ns / 1ps

module testbench();
reg clk;
reg rst;

top Top(clk, rst);
initial begin
    clk = 0;
    rst = 0;

    #37 rst = 1;
end

always
    #20 clk = ~clk; // 每隔 20ns 时钟信号 clk 翻转一次

endmodule
