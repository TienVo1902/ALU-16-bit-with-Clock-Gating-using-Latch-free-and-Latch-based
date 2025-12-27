`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:37:30 06/09/2025 
// Design Name: 
// Module Name:    Subtractor 
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
module Subtractor_16bit (
    input  signed [15:0] A,
    input  signed [15:0] B,
    input         Bin,   
    output signed [15:0] Diff,
    output        Bout    
);
    wire signed [15:0] B_inverted;
    wire        Cout;     
    wire        Cin;  

    assign B_inverted = ~B;
	 
    // Neu Bin = 0 (khong co muon truoc) => thuc hien A - B = A + (~B) + 1 => Cin = 1
    // Neu Bin = 1 (da muon truoc) => thuc hien (A - B) - 1 = A + (~B) => Cin = 0
    assign Cin = ~Bin;

    // A + (~B) + Cin
    CLA_16bit cla_sub (
        .A   (A),
        .B   (B_inverted),
        .Cin (Cin),
        .Sum (Diff),
        .Cout(Cout)
    );

    assign Bout = ~Cout;
endmodule
