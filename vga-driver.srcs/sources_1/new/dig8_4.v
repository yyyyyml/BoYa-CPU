`timescale 1ns / 1ps
module dig8_4(
    input clk,
    input rstn,
    input [23:0] set_data,
    output reg[5:0] dig,
    output reg[7:0] dict,
    output reg[7:0] dict2
);
    
reg [15:0] cnt1;
    always@(posedge clk or negedge rstn ) 
    begin
       if(!rstn)
           cnt1 <= 16'd0;
       else if (cnt1 <= 16'd50000)
           cnt1 <= cnt1 +1'b1;
       else
           cnt1 <= 16'd0;
    end
    
    reg clk_low1;
    always@(posedge clk or negedge rstn ) 
    begin
       if(!rstn)
           clk_low1 <= 1'b0;
       else if (cnt1 < 16'd25000) 
           clk_low1 <= 1'b0;
       else
           clk_low1 <= 1'b1;
    end
    
    reg [3:0] data;
    always@(posedge clk or negedge rstn) 
    begin
       if(!rstn)
           dict <= 8'd0;
       else 
           begin
              case (data)
                    4'd0:dict <= 8'b11111100;
                    4'd1:dict <= 8'b01100000;
                    4'd2:dict <= 8'b11011010;
                    4'd3:dict <= 8'b11110010;
                    4'd4:dict <= 8'b01100110;
                    4'd5:dict <= 8'b10110110;
                    4'd6:dict <= 8'b10111110;
                    4'd7:dict <= 8'b11100000;
                    4'd8:dict <= 8'b11111110;
                    4'd9:dict <= 8'b11110110;
           endcase
        end
    end
    
    always@(posedge clk or negedge rstn) 
    begin
       if(!rstn)
           dict2 <= 8'd0;
       else 
           begin
              case (data)
                    4'd0:dict2 <= 8'b11111100;
                    4'd1:dict2 <= 8'b01100000;
                    4'd2:dict2 <= 8'b11011010;
                    4'd3:dict2 <= 8'b11110010;
                    4'd4:dict2 <= 8'b01100110;
                    4'd5:dict2 <= 8'b10110110;
                    4'd6:dict2 <= 8'b10111110;
                    4'd7:dict2 <= 8'b11100000;
                    4'd8:dict2 <= 8'b11111110;
                    4'd9:dict2 <= 8'b11110110;
           endcase
        end
    end

//轮流切换数码管
    reg[2:0] cnt2;
    always@(posedge clk_low1 or negedge rstn ) 
    begin
       if(!rstn)
           cnt2 <= 3'd0;
       else if (cnt2 < 3'd6)
           cnt2 <= cnt2 + 1'd1;
       else
           cnt2 <= 3'd0;
    end

    always@(posedge clk or negedge rstn) 
    begin
       if(!rstn)
           dig <= 6'b000000;
       else 
           begin
              case (cnt2)
                 3'd0:dig <= 6'b000001;
                 3'd1:dig <= 6'b000010;
                 3'd2:dig <= 6'b000100;
                 3'd3:dig <= 6'b001000;
                 3'd4:dig <= 6'b010000;
                 3'd5:dig <= 6'b100000;
              endcase
           end
       end

//在切换数码管的同时，赋予位选数据
    always@(posedge clk or negedge rstn) 
    begin
       if(!rstn)
           data <= 4'd0;
       else 
           begin
              case (dig)
                 6'b000001:data <= set_data[3:0];
                 6'b000010:data <= set_data[7:4];
                 6'b000100:data <= set_data[11:8];
                 6'b001000:data <= set_data[15:12];
                 6'b010000:data <= set_data[19:16];
                 6'b100000:data <= set_data[23:20];
              endcase
           end
     end
endmodule
