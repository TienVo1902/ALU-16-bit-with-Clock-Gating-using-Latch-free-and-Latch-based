`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:41:06 06/09/2025 
// Design Name: 
// Module Name:    ALU_16bit 
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
module ALU_16bit (
    input              clk,
    input              rst,
    input              start,
    input       [3:0]  op,        // 0000: Add, 0001: Sub, 0010: Mul, 0011: Div, 0100: Cmp
                                  // 0101: NAND, 0110: AND, 0111: NOR, 1000: OR, 1001: XOR
                                  // 1010: SHL, 1011: SHR, 1100: ROL, 1101: ROR
    input  signed [15:0] A,
    input  signed [15:0] B,
    output reg signed [15:0] Z_low,
    output reg signed [15:0] Z_high,
    output reg         valid
);

    // Start signals for multiplier/divider
    wire start_mul = (op == 4'b0010) && start;
    wire start_div = (op == 4'b0011) && start;

    // ==== ADDER ====
    wire signed [15:0] sum;
    wire               cout;
    Adder_16bit adder (
        .A   (A),
        .B   (B),
        .Cin (1'b0),
        .Sum (sum),
        .Cout(cout)
    );

    // ==== SUBTRACTOR ====
    wire signed [15:0] diff;
    wire               bout;
    Subtractor_16bit subtractor (
        .A   (A),
        .B   (B),
        .Bin (1'b0),
        .Diff(diff),
        .Bout(bout)
    );

    // ==== MULTIPLIER ====
    wire signed [31:0] mul_z;
    wire               mul_valid;
    Multiplier_16bit multiplier (
        .clk   (clk),
        .rst   (rst),
        .start (start_mul),
        .X     (A),
        .Y     (B),
        .Z     (mul_z),
        .valid (mul_valid)
    );

    // ==== DIVIDER ====
    wire signed [15:0] quot;
    wire signed [15:0] rem;
    wire               div_valid;
    Divider_16bit divider (
        .clk   (clk),
        .rst   (rst),
        .start (start_div),
        .A     (A),
        .B     (B),
        .quot  (quot),
        .rem   (rem),
        .valid (div_valid)
    );

    // ==== COMPARATOR ====
    wire signed [1:0] comp_result;
    Comparator_16bit comparator (
        .A(A),
        .B(B),
        .comp_out(comp_result)
    );

    // ==== SHIFTERS ====
    wire [15:0] shl_out;
    wire [15:0] shr_out;
    Shifter16_Left  shl (
        .in   (A),           // shift A left by B[3:0]
        .ctrl (B[3:0]),
        .out  (shl_out)
    );
    Shifter16_Right shr (
        .in   (A),           // shift A right by B[3:0]
        .ctrl (B[3:0]),
        .out  (shr_out)
    );

    // ==== ROTATORS ====
    wire [15:0] rol_out;
    wire [15:0] ror_out;
    Rotate16_Left  rol (
        .in   (A),          // rotate A left by B[3:0]
        .ctrl (B[3:0]),
        .out  (rol_out)
    );
    Rotate16_Right ror (
        .in   (A),          // rotate A right by B[3:0]
        .ctrl (B[3:0]),
        .out  (ror_out)
    );

    // ==== OUTPUT LOGIC ====
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            Z_low  <= 16'sd0;
            Z_high <= 16'sd0;
            valid  <= 1'b0;
        end else begin
            case (op)
                4'b0000: begin // ADD
                    Z_low  <= sum;
                    Z_high <= {{16{sum[15]}}};
                    valid  <= start;
                end
                4'b0001: begin // SUB
                    Z_low  <= diff;
                    Z_high <= {{16{diff[15]}}};
                    valid  <= start;
                end
                4'b0010: begin // MUL
                    if (mul_valid) begin
                        Z_low  <= mul_z[15:0];
                        Z_high <= mul_z[31:16];
                        valid  <= 1'b1;
                    end else begin
                        valid <= 1'b0;
                    end
                end
                4'b0011: begin // DIV
                    if (start_div && B == 16'sd0) begin
                        // Division by zero
                        Z_low  <= 16'sdX;
                        Z_high <= 16'sdX;
                        valid  <= 1'b1;
                    end else if (div_valid) begin
                        Z_low  <= quot;
                        Z_high <= rem;
                        valid  <= 1'b1;
                    end else begin
                        valid <= 1'b0;
                    end
                end
                4'b0100: begin // CMP
                    Z_low  <= {{14{comp_result[1]}}, comp_result};
                    Z_high <= 16'sd0;
                    valid  <= start;
                end
                4'b0101: begin // NAND
                    Z_low  <= ~(A & B);
                    Z_high <= 16'sd0;
                    valid  <= start;
                end
                4'b0110: begin // AND
                    Z_low  <= A & B;
                    Z_high <= 16'sd0;
                    valid  <= start;
                end
                4'b0111: begin // NOR
                    Z_low  <= ~(A | B);
                    Z_high <= 16'sd0;
                    valid  <= start;
                end
                4'b1000: begin // OR
                    Z_low  <= A | B;
                    Z_high <= 16'sd0;
                    valid  <= start;
                end
                4'b1001: begin // XOR
                    Z_low  <= A ^ B;
                    Z_high <= 16'sd0;
                    valid  <= start;
                end
                4'b1010: begin // SHL
                    Z_low  <= shl_out;
                    Z_high <= 16'sd0;
                    valid  <= start;
                end
                4'b1011: begin // SHR
                    Z_low  <= shr_out;
                    Z_high <= 16'sd0;
                    valid  <= start;
                end
                4'b1100: begin // ROL
                    Z_low  <= rol_out;
                    Z_high <= 16'sd0;
                    valid  <= start;
                end
                4'b1101: begin // ROR
                    Z_low  <= ror_out;
                    Z_high <= 16'sd0;
                    valid  <= start;
                end
                default: begin
                    Z_low  <= 16'sd0;
                    Z_high <= 16'sd0;
                    valid  <= 1'b0;
                end
            endcase
        end
    end

endmodule



