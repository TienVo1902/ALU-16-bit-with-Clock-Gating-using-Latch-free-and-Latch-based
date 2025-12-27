`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:44:17 06/09/2025
// Design Name:   ALU_16bit
// Module Name:   E:/ALU_16bit/ALU_16bit_tb.v
// Project Name:  ALU_16bit
// Target Device:  
// Tool versions:  
// Description: 
//
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ALU_16bit_tb;
    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [3:0] op;
    reg signed [15:0] A;
    reg signed [15:0] B;

    // Outputs
    wire signed [15:0] Z_low;
    wire signed [15:0] Z_high;
    wire valid;

    // Instantiate Unit Under Test
    ALU_16bit uut (
        .clk    (clk),
        .rst    (rst),
        .start  (start),
        .op     (op),
        .A      (A),
        .B      (B),
        .Z_low  (Z_low),
        .Z_high (Z_high),
        .valid  (valid)
    );

    // 50 MHz
    initial clk = 0;
    always #10 clk = ~clk;

    // Dump waveform
    initial begin
        $dumpfile("ALU_16bit_tb.vcd");
        $dumpvars(0, ALU_16bit_tb);
    end

    // Helper task to apply an operation in ALU
    task ALU;
        input [3:0] opcode;
        input signed [15:0] a_val;
        input signed [15:0] b_val;
        begin
            op    = opcode;
            A     = a_val;
            B     = b_val;
            start = 1;
            #20;
            start = 0;
            // For multi-cycle ops, wait until valid
            if (opcode == 4'b0010 || opcode == 4'b0011) begin
                wait (valid);
            end else begin
                #20;
            end
            #20;
        end
    endtask

    initial begin
        // Reset sequence
        rst   = 0;
        start = 0;
        op    = 4'b0000;
        A     = 0;
        B     = 0;
        #50;
        rst = 1;

        // ----- Arithmetic -----
        ALU(4'b0000,  16'sd100,    16'sd25);     // ADD 100 + 25
		ALU(4'b0000,  -16'sd100,    16'sd25);    // ADD -100 + 25
		ALU(4'b0000,  -16'sd100,    -16'sd25);    // ADD -100 + 2
		ALU(4'b0000,  16'sd32767,    16'sd1);    // ADD 32767 + 1
		  
        ALU(4'b0001,  16'sd250,  16'sd50);  // SUB 250 - 50
		ALU(4'b0001,  -16'sd250,  16'sd50);  // SUB -250 - 50
		ALU(4'b0001,  -16'sd250,  -16'sd50);  // SUB -250 - (-50)
		ALU(4'b0001,  -16'sd32768,  16'sd1);  // SUB -32768 - 1

        // ----- Multiplication -----
        ALU(4'b0010,  16'sd150,   16'sd120);   // MUL 150 * 120
		ALU(4'b0010,  -16'sd150,   16'sd120);   // MUL -150 * 120
		ALU(4'b0010,  -16'sd15000,   -16'sd12000);   // MUL -15000 * 12000

        // ----- Division -----
        ALU(4'b0011,  16'sd100,    16'sd2);     // DIV 100 / 3
        ALU(4'b0011,  16'sd100,    16'sd3);     // DIV 100 / 3
		ALU(4'b0011,  16'sd100,    -16'sd3);     // DIV 100 / 3
		ALU(4'b0011,  -16'sd100,    -16'sd3);     // DIV 100 / 3
        ALU(4'b0011,  16'sd15,     16'sd0);     // DIV by zero

        // ----- Comparison -----
        ALU(4'b0100,  16'sd12345, -16'sd10000); // CMP >
        ALU(4'b0100,  16'sd500,    16'sd500);  // CMP ==
        ALU(4'b0100, -16'sd12345,  16'sd10000); // CMP <

        // ----- Logic -----
        ALU(4'b0101, 16'b0000_1111_1111_1111, 16'b0000_1111_0000_1111); // NAND
        ALU(4'b0110, 16'b0000_1111_1111_1111, 16'b0000_1111_0000_1111); // AND
        ALU(4'b0111, 16'b0000_1111_1111_1111, 16'b0000_1111_0000_1111); // NOR
        ALU(4'b1000, 16'b0000_1111_1111_1111, 16'b0000_1111_0000_1111); // OR
        ALU(4'b1001, 16'b0000_1111_1111_1111, 16'b0000_1111_0000_1111); // XOR

        // ----- Shifts -----
        // SHL: shift A left by B[3:0]
        ALU(4'b1010, 16'b0000_1111_0000_1111, 4'd0);  // SHL by 0
        ALU(4'b1010, 16'b0000_1111_0000_1111, 4'd1);  // SHL by 1
        ALU(4'b1010, 16'b0000_1111_0000_1111, 4'd4);  // SHL by 4
        ALU(4'b1010, 16'b0000_1111_0000_1111, 4'd8);  // SHL by 8
        ALU(4'b1010, 16'b0000_1111_0000_1111, 4'd15); // SHL by 15
        // SHR: shift A right by B[3:0]
        ALU(4'b1011, 16'b0000_1111_0000_1111, 4'd0);  // SHR by 0
        ALU(4'b1011, 16'b0000_1111_0000_1111, 4'd1);  // SHR by 1
        ALU(4'b1011, 16'b0000_1111_0000_1111, 4'd4);  // SHR by 4
        ALU(4'b1011, 16'b0000_1111_0000_1111, 4'd8);  // SHR by 8
        ALU(4'b1011, 16'b0000_1111_0000_1111, 4'd15); // SHR by 15

        // ----- Rotations -----
        // ROL: rotate A left by B[3:0]
        ALU(4'b1100, 16'b0000_1111_0000_1111, 4'd0);  // ROL by 0
        ALU(4'b1100, 16'b0000_1111_0000_1111, 4'd1);  // ROL by 1
        ALU(4'b1100, 16'b0000_1111_0000_1111, 4'd4);  // ROL by 4
        ALU(4'b1100, 16'b0000_1111_0000_1111, 4'd8);  // ROL by 8
        ALU(4'b1100, 16'b0000_1111_0000_1111, 4'd15); // ROL by 15
        // ROR: rotate A right by B[3:0]
        ALU(4'b1101, 16'b0000_1111_0000_1111, 4'd0);  // ROR by 0
        ALU(4'b1101, 16'b0000_1111_0000_1111, 4'd1);  // ROR by 1
        ALU(4'b1101, 16'b0000_1111_0000_1111, 4'd4);  // ROR by 4
        ALU(4'b1101, 16'b0000_1111_0000_1111, 4'd8);  // ROR by 8
        ALU(4'b1101, 16'b0000_1111_0000_1111, 4'd15); // ROR by 15

        $finish;
    end

    // Monitor outputs
    initial begin
        $display("Time  op   A        B      Z_high    Z_low     valid");
        $monitor("%0t  %b  %0h  %0h  %0h     %0h      %b", $time, op, A, B, Z_high, Z_low, valid);
    end
endmodule






