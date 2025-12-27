`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:38:31 06/09/2025 
// Design Name: 
// Module Name:    Multiplier 
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
module Multiplier_16bit(
    input             clk,
    input             rst,
    input             start,
    input  signed [15:0] X,    // So nhan
    input  signed [15:0] Y,    // So bi nhan
    output reg signed [31:0] Z, // Tich
    output reg        valid
);

    // State and counters
    reg pres_state, next_state;
    reg [3:0] count, next_count;

    // Combined register [A(16) | Q(16) | Q_-1(1)] = 33 bits
    reg signed [32:0] P, next_P;
    reg signed [32:0] P_temp;

    // Next-cycle outputs
    reg signed [31:0] next_Z;
    reg               next_valid;

    // Extended multiplicand aligned to P's MSBs
    wire signed [32:0] M_ext = {Y, 17'b0};

    // Triple for Radix-4 recoding: {Q[1], Q[0], Q_-1}
    wire [2:0] triple = {P[2], P[1], P[0]};

    // FSM states
    parameter IDLE  = 1'b0,
              START = 1'b1;

    // Sequential update
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            P          <= 33'd0;
            count      <= 4'd0;
            pres_state <= IDLE;
            Z          <= 32'd0;
            valid      <= 1'b0;
        end else begin
            P          <= next_P;
            count      <= next_count;
            pres_state <= next_state;
            Z          <= next_Z;
            valid      <= next_valid;
        end
    end

    // Combinational next-state logic
    always @(*) begin
        // Default assignments
        next_state = pres_state;
        next_P     = P;
        next_count = count;
        next_Z     = Z;
        next_valid = 1'b0;

        case (pres_state)
            IDLE: begin
                if (start) begin
                    next_state = START;
                    next_P     = {17'd0, X, 1'b0};  // Load A=0, Q=X, Q_-1=0
                    next_count = 4'd0;
                end else begin
                    next_Z = 32'd0;
                end
            end

            START: begin
                // Booth recoding and partial add/sub
                case (triple)
                    3'b001, 3'b010: P_temp = P + M_ext;         // +1·Y
                    3'b011:         P_temp = P + (M_ext <<< 1); // +2·Y
                    3'b100:         P_temp = P - (M_ext <<< 1); // -2·Y
                    3'b101, 3'b110: P_temp = P - M_ext;         // -1·Y
                    default:        P_temp = P;                 // 0·Y
                endcase

                // Shift right by 2 (arithmetic)
                next_P     = P_temp >>> 2;
                next_count = count + 4'd1;

                // Check termination (8 iterations covers 16 bits)
                if (count == 4'd7) begin
                    next_state = IDLE;
                    // Capture final product from P[32:1]
                    next_Z     = next_P[32:1];
                    next_valid = 1'b1;
                end
            end
        endcase
    end

endmodule
