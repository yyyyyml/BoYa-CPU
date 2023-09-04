`timescale 1ns / 1ps

module alu(
           input  wire[31:0] alu_op1,
           input  wire[31:0] alu_op2,
           input  wire[4:0] sa,
           input  wire[4 - 1:0] ALUOp,

           output wire[31:0] alu_res,
           output wire overflow,

           output wire zero
       );

reg[32:0] alu_tempres;
assign alu_res = alu_tempres[31:0];

// 溢出
assign overflow = (alu_tempres[32] != alu_tempres[31]) ? 1'b1 : 1'b0;

wire[4:0] displacement;
assign displacement =
       (ALUOp == 4'b1000 ||
        ALUOp == 4'b1001  ||
        ALUOp == 4'b1010) ? sa : alu_op1[4:0];

// 比较大小，用来判断部分情况跳转
wire[31:0] comp;
assign comp = (alu_op1 < alu_op2) ? 32'h00000001 : 32'h00000000;

wire[32:0] comp2;

assign comp2 = {alu_op1[31], alu_op1} - {alu_op2[31], alu_op2};

assign zero = (comp2 == 0) ? 1'b1 : (alu_op1 > alu_op2) ? 1'b1 : 1'b0;

always @ (*) begin
    case (ALUOp)
        4'b0001:
            alu_tempres <= {alu_op1[31], alu_op1} + {alu_op2[31], alu_op2};
        4'b0010:
            alu_tempres <= {alu_op1[31], alu_op1} - {alu_op2[31], alu_op2};
        4'b0011:
            alu_tempres <= comp;
        4'b0100:
            alu_tempres <= {alu_op1[31], alu_op1} & {alu_op2[31], alu_op2};
        4'b0101:
            alu_tempres <= {alu_op1[31], alu_op1} | {alu_op2[31], alu_op2};
        4'b0110:
            alu_tempres <= (({alu_op1[31], alu_op1} & ~{alu_op2[31], alu_op2}) |
                                (~{alu_op1[31], alu_op1} & {alu_op2[31], alu_op2}));
        4'b0111:
            alu_tempres <= {alu_op1[31], alu_op1} ^ {alu_op2[31], alu_op2};
        4'b1000:
            alu_tempres <= {alu_op2[31], alu_op2} << displacement;
        4'b1011:
            alu_tempres <= {alu_op2[31], alu_op2} << displacement;
        4'b1001:
            alu_tempres <= {alu_op2[31], alu_op2} >> displacement;
        4'b1100:
            alu_tempres <= {alu_op2[31], alu_op2} >> displacement;
        4'b1010:
            alu_tempres <= ({{31{alu_op2[31]}}, 1'b0} << (~displacement)) | (alu_op2 >> displacement);
        4'b1101:
            alu_tempres <= ({{31{alu_op2[31]}}, 1'b0} << (~displacement)) | (alu_op2 >> displacement);
        4'b0000:
            alu_tempres <= {alu_op2[31], alu_op2};
    endcase
end
endmodule

