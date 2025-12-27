`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:35:53 06/09/2025 
// Design Name: 
// Module Name:    CLA 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module CLA_4bit(
    input  signed [3:0] A,
    input  signed [3:0] B,
    input        Cin,
    output signed [3:0] Sum,
    output       Cout
);
    wire [3:0] G, P;  
    wire [4:1] C;     

    assign G = A & B;
    assign P = A ^ B;
	
	 // Ci+1 = Gi+(Pi�Ci)
	 
    assign C[1] = G[0] | (P[0] & Cin);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Cin);
    assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & Cin);

    assign Sum = P ^ {C[3:1], Cin};
endmodule


module CLA_16bit(
    input  signed [15:0] A,
    input  signed [15:0] B,
    input         Cin,
    output  signed [15:0] Sum,
    output        Cout
);
    wire [3:0] C_block; 
	 
    CLA_4bit CLA0 (.A(A[3:0]),   .B(B[3:0]),   .Cin(Cin),      .Sum(Sum[3:0]),   .Cout(C_block[0]));
    CLA_4bit CLA1 (.A(A[7:4]),   .B(B[7:4]),   .Cin(C_block[0]),.Sum(Sum[7:4]),   .Cout(C_block[1]));
    CLA_4bit CLA2 (.A(A[11:8]),  .B(B[11:8]),  .Cin(C_block[1]),.Sum(Sum[11:8]),  .Cout(C_block[2]));
    CLA_4bit CLA3 (.A(A[15:12]), .B(B[15:12]), .Cin(C_block[2]),.Sum(Sum[15:12]), .Cout(C_block[3]));

    assign Cout = C_block[3];
endmodule
