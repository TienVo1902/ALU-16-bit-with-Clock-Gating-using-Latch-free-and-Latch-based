`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:40:02 06/09/2025 
// Design Name: 
// Module Name:    Divider 
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
module Divider_16bit (
    input  wire        clk,   
    input  wire        rst,   
    input  wire        start, 
    input  wire signed [15:0] A,      // Dividend 
    input  wire signed [15:0] B,      // Divisor  
    output wire signed [15:0] quot,   // Signed quotient
    output wire signed [15:0] rem,    // Signed remainder
    output reg               valid   
);

    // Internal registers and wires
    reg [31:0] Z, next_Z;
    reg [31:0] Z_temp, Z_temp1;
    reg        pres_state, next_state;
    reg [3:0]  count, next_count;

    // Registered quotient/remainder
    reg signed [15:0] quot_reg, rem_reg;
    assign quot = quot_reg;
    assign rem  = rem_reg;

    // Signs and absolute values (registered)
    reg sign_A, sign_B, sign_q, sign_r;
    reg [15:0] A_abs, B_abs;

    // FSM states
    localparam IDLE  = 1'b0;
    localparam START = 1'b1;

    // 1) Sequential block: update registers
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            Z          <= 32'd0;
            pres_state <= IDLE;
            count      <= 4'd0;
            valid      <= 1'b0;
            quot_reg   <= 16'd0;
            rem_reg    <= 16'd0;
            sign_A     <= 1'b0;
            sign_B     <= 1'b0;
            sign_q     <= 1'b0;
            sign_r     <= 1'b0;
            A_abs      <= 16'd0;
            B_abs      <= 16'd0;
        end else begin
            // Sample signs and absolute values at start
            if (pres_state == IDLE && start) begin
                sign_A <= A[15];
                sign_B <= B[15];
                sign_q <= A[15] ^ B[15];
                sign_r <= A[15];
                // Compute absolute values directly from inputs
                A_abs  <= A[15] ? -A : A;
                B_abs  <= B[15] ? -B : B;
            end

            // Update state, counter, and shift-register Z
            Z          <= next_Z;
            pres_state <= next_state;
            count      <= next_count;
            valid      <= (pres_state == START) ? (&count) : 1'b0;

            // When division ends, adjust sign and store outputs
            if ((pres_state == START) && (&count)) begin
                // Unsigned parts: low half = quotient, high half = remainder
                if (sign_q)
                    quot_reg <= -$signed(next_Z[15:0]);
                else
                    quot_reg <=  $signed(next_Z[15:0]);

                if (sign_r)
                    rem_reg <= -$signed(next_Z[31:16]);
                else
                    rem_reg <=  $signed(next_Z[31:16]);
            end
        end
    end

    // 2) Combinational block: compute next state, next count, next_Z
    always @(*) begin
        // Default hold
        next_Z     = Z;
        next_state = pres_state;
        next_count = count;

        case (pres_state)
            IDLE: begin
                if (start) begin
                    next_state = START;
                    next_count = 4'd0;
                    // Initialize Z = { remainder=0, quotient=A_abs }
                    next_Z     = {16'd0, A_abs};
                end
            end

            START: begin
                next_count = count + 1'b1;
                // Shift left
                Z_temp  = Z << 1;
                // Try subtracting divisor from the top bits
                Z_temp1 = {Z_temp[31:16] - B_abs, Z_temp[15:0]};

                if (Z_temp1[31]) begin
                    // Negative => restore, quotient bit = 0
                    next_Z = { Z_temp[31:16], Z_temp[15:1], 1'b0 };
                end else begin
                    // Non-negative => accept, quotient bit = 1
                    next_Z = { Z_temp1[31:16], Z_temp[15:1], 1'b1 };
                end


                if (&count)
                    next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule