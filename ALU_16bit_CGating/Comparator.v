`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:06:37 06/25/2025 
// Design Name: 
// Module Name:    Comparator 
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
module Comparator_16bit (
    input  signed [15:0] A,
    input  signed [15:0] B,
    output wire signed [1:0] comp_out  // -1 khi A < B, 1 khi A > B, 0 khi A = B
);
    wire signed [15:0] Diff;
    wire        Bout;

    Subtractor_16bit sub (
        .A   (A),
        .B   (B),
        .Bin (1'b0),
        .Diff(Diff),
        .Bout(Bout)
    );

    wire sign     = Diff[15];
    wire zero     = (Diff == 16'sd0);
    wire overflow = (A[15] ^ B[15]) & (A[15] ^ Diff[15]);

    wire lt = (sign ^ overflow);
    wire gt = ~zero & ~lt;

    assign comp_out = (lt  == 1'b1) ? -2'sd1 :
							 (gt  == 1'b1) ?  2'sd1 : 2'sd0;

endmodule
