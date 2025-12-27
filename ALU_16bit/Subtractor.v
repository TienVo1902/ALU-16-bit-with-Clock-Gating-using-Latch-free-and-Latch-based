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
