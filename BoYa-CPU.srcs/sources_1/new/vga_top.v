`timescale 1ns / 1ps
`include "params.vh"

module vga_top #(
           parameter H_DISPLAY      = 11'd1024,
           parameter H_FRONT_PORCH  = 11'd24,
           parameter H_SYNC_PULSE   = 11'd136,
           parameter H_BACK_PORCH   = 11'd160,
           parameter H_TOTAL        = 11'd1344,

           parameter V_DISPLAY      = 10'd768,
           parameter V_FRONT_PORCH  = 10'd3,
           parameter V_SYNC_PULSE   = 10'd6,
           parameter V_BACK_PORCH   = 10'd29,
           parameter V_TOTAL        = 10'd806

       )(
           input  wire      clk,
           input  wire      rstn,
           input  wire[23:0] show_dataTemp,
//           input wire       wen,
//           input wire[31:0] wdata,
//           input wire[3:0]  addr,
//           input wire       rdata,

           output wire      hs,
           output wire      vs,
           output wire[3:0] red,
           output wire[3:0] green,
           output wire[3:0] blue
       );


//top CPUTop (
//        .clk1 (clk),
//        .rst (rstn),
//        .set_data (show_dataTemp)
//);

wire[3:0] show_data[5:0];

assign show_data[0] = show_dataTemp[23:20];
assign show_data[1] = show_dataTemp[19:16];
assign show_data[2] = show_dataTemp[15:12];
assign show_data[3] = show_dataTemp[11:8];
assign show_data[4] = show_dataTemp[7:4];
assign show_data[5] = show_dataTemp[3:0];


/* --- VGA Driver --- */

// 65 MHz clock signal

//initial begin
//    show_data[0] <= 4'b0000;
//    show_data[1] <= 4'b0001;
//    show_data[2] <= 4'b0010;
//    show_data[3] <= 4'b0011;
//    show_data[4] <= 4'b0100;
//    show_data[5] <= 4'b0101;
//end

reg[12:0] digital[9:0];
initial begin
    digital[0]<=13'b1111110111111;
    digital[1]<=13'b0010100101001;
    digital[2]<=13'b1110111110111;
    digital[3]<=13'b1110111101111;
    digital[4]<=13'b1011111101001;
    digital[5]<=13'b1111011101111;
    digital[6]<=13'b1111011111111;
    digital[7]<=13'b1110100101001;
    digital[8]<=13'b1111111111111;
    digital[9]<=13'b1111111101111;
end

wire clk_vga;

clk_wiz u_clk_wiz (
            // Clock out ports
            .clk_out1(clk_vga),     // output clk_out1
            // Status and control signals
            .reset(~rstn), // input reset
            // Clock in ports
            .clk_in1(clk));      // input clk_in1

/* RGB signals */
reg[3:0] reg_red;
reg[3:0] reg_green;
reg[3:0] reg_blue;

assign red = reg_red;
assign green = reg_green;
assign blue = reg_blue;

/* Horizonal & Vertical refresh pulses */

reg h_reg;
reg v_reg;

assign hs = h_reg;
assign vs = v_reg;

reg[10:0] h_Location;
reg[10:0] v_Location;

/* horizontal scan and vertical scan */

always @ (posedge clk_vga) begin
    if (rstn == `RST_EN) begin
        h_Location <= 11'b0;
        v_Location <= 11'b0;
    end
    else begin
        if (h_Location == H_TOTAL - 1) begin
            h_Location <= 11'b0;
            if (v_Location == V_TOTAL - 1) begin
                v_Location <= 11'b0;
            end
            else begin
                v_Location <= v_Location + 1'b1;
            end
        end
        else begin
            h_Location <= h_Location + 1'b1;
        end
    end
end

always @ (posedge clk_vga) begin
    if (h_Location < H_SYNC_PULSE) begin
        h_reg <= 1'b0;
    end
    else begin
        h_reg <= 1'b1;
    end
end

always @ (posedge clk_vga) begin
    if (v_Location < V_SYNC_PULSE) begin
        v_reg <= 1'b0;
    end
    else begin
        v_reg <= 1'b1;
    end
end



reg[1:0] debug;
reg[3:0] iter; 
parameter basic_h_Location = 500;

always @ (posedge clk_vga) begin
    if(v_Location<350)begin
        reg_red   <= 4'b0000;
        reg_green <= 4'b0000;
        reg_blue  <= 4'b0000;
    end
    
        if(v_Location>349 && v_Location<501)begin
            //0
        if(h_Location> basic_h_Location  && h_Location < basic_h_Location + 100)begin
            if(v_Location<360&&v_Location>349)begin
                if(digital[show_data[0]][12] && h_Location > basic_h_Location + 9 && h_Location < basic_h_Location +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[0]][11] && h_Location > basic_h_Location + 19 && h_Location < basic_h_Location +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[0]][10] && h_Location > basic_h_Location + 79 && h_Location < basic_h_Location +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            else if(v_Location<420&&v_Location>359)begin
                if(digital[show_data[0]][9] && h_Location > basic_h_Location + 9 && h_Location < basic_h_Location +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[0]][8] && h_Location > basic_h_Location + 79 && h_Location < basic_h_Location +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            
            else if(v_Location<430&&v_Location>419)begin
                if(digital[show_data[0]][7] && h_Location > basic_h_Location + 9 && h_Location < basic_h_Location +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[0]][6] && h_Location > basic_h_Location + 19 && h_Location < basic_h_Location +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[0]][5] && h_Location > basic_h_Location + 79 && h_Location < basic_h_Location +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<490&&v_Location>429)begin
                if(digital[show_data[0]][4] && h_Location > basic_h_Location + 9 && h_Location < basic_h_Location +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[0]][3] && h_Location > basic_h_Location + 79 && h_Location < basic_h_Location +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<500&&v_Location>489)begin
                if(digital[show_data[0]][2] && h_Location > basic_h_Location + 9 && h_Location < basic_h_Location +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[0]][1] && h_Location > basic_h_Location+ 19 && h_Location < basic_h_Location +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[0]][0] && h_Location > basic_h_Location + 79 && h_Location < basic_h_Location +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
        end
        if(h_Location> basic_h_Location + 100 && h_Location < basic_h_Location + 200)begin
        //1
            if(v_Location<360&&v_Location>349)begin
                if(digital[show_data[1]][12] && h_Location > basic_h_Location + 100 + 9 && h_Location < basic_h_Location +100 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[1]][11] && h_Location > basic_h_Location + 100 + 19 && h_Location < basic_h_Location + 100 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[1]][10] && h_Location > basic_h_Location + 100 + 79 && h_Location < basic_h_Location + 100 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            else if(v_Location<420&&v_Location>359)begin
                if(digital[show_data[1]][9] && h_Location > basic_h_Location + 100 + 9 && h_Location < basic_h_Location + 100 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[1]][8] && h_Location > basic_h_Location + 100 + 79 && h_Location < basic_h_Location + 100 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            
            else if(v_Location<430&&v_Location>419)begin
                if(digital[show_data[1]][7] && h_Location > basic_h_Location + 100 + 9 && h_Location < basic_h_Location + 100 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[1]][6] && h_Location > basic_h_Location + 100 + 19 && h_Location < basic_h_Location + 100 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[1]][5] && h_Location > basic_h_Location + 100 + 79 && h_Location < basic_h_Location + 100 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<490&&v_Location>429)begin
                if(digital[show_data[1]][4] && h_Location > basic_h_Location + 100 + 9 && h_Location < basic_h_Location + 100 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[1]][3] && h_Location > basic_h_Location + 100 + 79 && h_Location < basic_h_Location + 100 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<500&&v_Location>489)begin
                if(digital[show_data[1]][2] && h_Location > basic_h_Location + 100 + 9 && h_Location < basic_h_Location + 100 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[1]][1] && h_Location > basic_h_Location + 100 + 19 && h_Location < basic_h_Location + 100 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[1]][0] && h_Location > basic_h_Location + 100 + 79 && h_Location < basic_h_Location + 100 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
        end
        
        if(h_Location> basic_h_Location + 200 && h_Location < basic_h_Location + 300)begin
            if(v_Location<360&&v_Location>349)begin
                if(digital[show_data[2]][12] && h_Location > basic_h_Location + 200 + 9 && h_Location < basic_h_Location + 200 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[2]][11] && h_Location > basic_h_Location + 200 + 19 && h_Location < basic_h_Location + 200 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[2]][10] && h_Location > basic_h_Location + 200 + 79 && h_Location < basic_h_Location + 200 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            else if(v_Location<420&&v_Location>359)begin
                if(digital[show_data[2]][9] && h_Location > basic_h_Location + 200 + 9 && h_Location < basic_h_Location + 200 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[2]][8] && h_Location > basic_h_Location + 200 + 79 && h_Location < basic_h_Location + 200 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            
            else if(v_Location<430&&v_Location>419)begin
                if(digital[show_data[2]][7] && h_Location > basic_h_Location + 200 + 9 && h_Location < basic_h_Location + 200 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[2]][6] && h_Location > basic_h_Location + 200 + 19 && h_Location < basic_h_Location + 200 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[2]][5] && h_Location > basic_h_Location + 200 + 79 && h_Location < basic_h_Location + 200 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<490&&v_Location>429)begin
                if(digital[show_data[2]][4] && h_Location > basic_h_Location + 200 + 9 && h_Location < basic_h_Location + 200 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[2]][3] && h_Location > basic_h_Location + 200 + 79 && h_Location < basic_h_Location + 200 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<500&&v_Location>489)begin
                if(digital[show_data[2]][2] && h_Location > basic_h_Location + 200 + 9 && h_Location < basic_h_Location + 200 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[2]][1] && h_Location > basic_h_Location + 200 + 19 && h_Location < basic_h_Location + 200 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[2]][0] && h_Location > basic_h_Location + 200 + 79 && h_Location < basic_h_Location + 200 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
        end
        
        
        if(h_Location> basic_h_Location + 300 && h_Location < basic_h_Location + 400)begin
            if(v_Location<360&&v_Location>349)begin
                if(digital[show_data[3]][12] && h_Location > basic_h_Location + 300 + 9 && h_Location < basic_h_Location + 300 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[3]][11] && h_Location > basic_h_Location + 300 + 19 && h_Location < basic_h_Location + 300 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[3]][10] && h_Location > basic_h_Location + 300 + 79 && h_Location < basic_h_Location + 300 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            else if(v_Location<420&&v_Location>359)begin
                if(digital[show_data[3]][9] && h_Location > basic_h_Location + 300 + 9 && h_Location < basic_h_Location + 300 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[3]][8] && h_Location > basic_h_Location + 300 + 79 && h_Location < basic_h_Location + 300 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            
            else if(v_Location<430&&v_Location>419)begin
                if(digital[show_data[3]][7] && h_Location > basic_h_Location + 300 + 9 && h_Location < basic_h_Location + 300 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[3]][6] && h_Location > basic_h_Location + 300 + 19 && h_Location < basic_h_Location + 300 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[3]][5] && h_Location > basic_h_Location + 300 + 79 && h_Location < basic_h_Location + 300 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<490&&v_Location>429)begin
                if(digital[show_data[3]][4] && h_Location > basic_h_Location + 300 + 9 && h_Location < basic_h_Location + 300 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[3]][3] && h_Location > basic_h_Location + 300 + 79 && h_Location < basic_h_Location + 300 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<500&&v_Location>489)begin
                if(digital[show_data[3]][2] && h_Location > basic_h_Location + 300 + 9 && h_Location < basic_h_Location + 300 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[3]][1] && h_Location > basic_h_Location + 300 + 19 && h_Location < basic_h_Location + 300 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[3]][0] && h_Location > basic_h_Location + 300 + 79 && h_Location < basic_h_Location + 300 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
        end
            
        if(h_Location> basic_h_Location + 400 && h_Location < basic_h_Location + 500)begin
            if(v_Location<360&&v_Location>349)begin
                if(digital[show_data[4]][12] && h_Location > basic_h_Location + 400 + 9 && h_Location < basic_h_Location + 400 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[4]][11] && h_Location > basic_h_Location + 400 + 19 && h_Location < basic_h_Location + 400 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[4]][10] && h_Location > basic_h_Location + 400 + 79 && h_Location < basic_h_Location + 400 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            else if(v_Location<420&&v_Location>359)begin
                if(digital[show_data[4]][9] && h_Location > basic_h_Location + 400 + 9 && h_Location < basic_h_Location + 400 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[4]][8] && h_Location > basic_h_Location + 400 + 79 && h_Location < basic_h_Location +400 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            
            else if(v_Location<430&&v_Location>419)begin
                if(digital[show_data[4]][7] && h_Location > basic_h_Location + 400 + 9 && h_Location < basic_h_Location + 400 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[4]][6] && h_Location > basic_h_Location + 400 + 19 && h_Location < basic_h_Location + 400 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[4]][5] && h_Location > basic_h_Location + 400 + 79 && h_Location < basic_h_Location + 400 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<490&&v_Location>429)begin
                if(digital[show_data[4]][4] && h_Location > basic_h_Location + 400 + 9 && h_Location < basic_h_Location + 400 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[4]][3] && h_Location > basic_h_Location + 400 + 79 && h_Location < basic_h_Location + 400 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<500&&v_Location>489)begin
                if(digital[show_data[4]][2] && h_Location > basic_h_Location + 400 + 9 && h_Location < basic_h_Location + 400 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[4]][1] && h_Location > basic_h_Location + 400 + 19 && h_Location < basic_h_Location + 400 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[4]][0] && h_Location > basic_h_Location + 400 + 79 && h_Location < basic_h_Location + 400 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
        end
            
        if(h_Location> basic_h_Location + 500 && h_Location < basic_h_Location + 600)begin
            if(v_Location<360&&v_Location>349)begin
                if(digital[show_data[5]][12] && h_Location > basic_h_Location + 500 + 9 && h_Location < basic_h_Location + 500 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[5]][11] && h_Location > basic_h_Location + 500 + 19 && h_Location < basic_h_Location + 500 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[5]][10] && h_Location > basic_h_Location + 500 + 79 && h_Location < basic_h_Location + 500 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            else if(v_Location<420&&v_Location>359)begin
                if(digital[show_data[5]][9] && h_Location > basic_h_Location + 500 + 9 && h_Location < basic_h_Location + 500 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[5]][8] && h_Location > basic_h_Location + 500 + 79 && h_Location < basic_h_Location + 500 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
            
            else if(v_Location<430&&v_Location>419)begin
                if(digital[show_data[5]][7] && h_Location > basic_h_Location + 500 + 9 && h_Location < basic_h_Location + 500 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[5]][6] && h_Location > basic_h_Location + 500 + 19 && h_Location < basic_h_Location + 500 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[5]][5] && h_Location > basic_h_Location + 500 + 79 && h_Location < basic_h_Location + 500 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<490&&v_Location>429)begin
                if(digital[show_data[5]][4] && h_Location > basic_h_Location + 500 + 9 && h_Location < basic_h_Location + 500 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[5]][3] && h_Location > basic_h_Location + 500 + 79 && h_Location < basic_h_Location + 500 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end

            else if(v_Location<500&&v_Location>489)begin
                if(digital[show_data[5]][2] && h_Location > basic_h_Location + 500 + 9 && h_Location < basic_h_Location + 500 +20)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[5]][1] && h_Location > basic_h_Location + 500 + 19 && h_Location < basic_h_Location + 500 +80)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else if(digital[show_data[5]][0] && h_Location > basic_h_Location + 500 + 79 && h_Location < basic_h_Location + 500 +90)begin
                    reg_red   <= 4'b1111;
                    reg_green <= 4'b1111;
                    reg_blue  <= 4'b1111;
                end
                else begin
                    reg_red   <= 4'b0000;
                    reg_green <= 4'b0000;
                    reg_blue  <= 4'b0000;
                end
            end
        end
            
        
    end

    else begin
        reg_red   <= 4'b0000;
        reg_green <= 4'b0000;
        reg_blue  <= 4'b0000;
    end
end
endmodule
