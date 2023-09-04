`timescale 1ns / 1ps

module dataMemory(
           input wire clk,
           input wire MemWrite,   // 写使能
           input wire[11:2] mem_addr,       
           input wire[31:0] mem_write_data, 
           
           output wire[31:0] mem_read_data, 
           output wire[23:0] set_data
       );    


reg[31:0] dataMem[31:0];
assign mem_read_data = dataMem[mem_addr];
assign set_data[3:0] = dataMem[5][3:0];
assign set_data[7:4] = dataMem[4][3:0];
assign set_data[11:8] = dataMem[3][3:0];
assign set_data[15:12] = dataMem[2][3:0];
assign set_data[19:16] = dataMem[1][3:0];
assign set_data[23:20] = dataMem[0][3:0];

initial begin
    dataMem[0] <= 32'h00000003;
    dataMem[1] <= 32'h00000007;
    dataMem[2] <= 32'h00000002;
    dataMem[3] <= 32'h00000005;
    dataMem[4] <= 32'h00000009;
    dataMem[5] <= 32'h00000001;
end

always @ (posedge clk) begin
    if (MemWrite) begin
        dataMem[mem_addr] <= mem_write_data;
    end
end
endmodule
