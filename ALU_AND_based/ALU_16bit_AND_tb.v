`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:44:17 06/09/2025
// Design Name:   ALU_16bit_icg
// Module Name:   ALU_16bit_icg_tb
// Project Name:  ALU_16bit
// Target Device:  
// Tool versions:  
// Description:    Testbench for ALU_16bit_icg with clock-gating enable (en)
//
// Dependencies:   ALU_16bit_icg.v
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

module ALU_16bit_and_gate_tb;

    // ---------- Inputs ----------
    reg clk;
    reg rst;
    reg en;               // enable clock (1 = running, 0 = gated)
    reg start;
    reg [3:0]  op;
    reg signed [15:0] A;
    reg signed [15:0] B;

    // ---------- Outputs ----------
    wire signed [15:0] Z_low;
    wire signed [15:0] Z_high;
    wire               valid;

    // ==================== UUT ====================
    ALU_16bit_and_gate uut (
        .clk   (clk),
        .rst   (rst),
        .en    (en),      
        .start (start),
        .op    (op),
        .A     (A),
        .B     (B),
        .Z_low (Z_low),
        .Z_high(Z_high),
        .valid (valid)
    );

    // ==================== Clock Generator ====================
    initial clk = 0;
    always #10 clk = ~clk;   

    // ==================== Waveform Dump ====================
    initial begin
        $dumpfile("ALU_16bit_and_gate_tb.vcd");
        $dumpvars(0, ALU_16bit_and_gate_tb);
    end

    // ==================== Helper Task ====================
    task automatic ALU;
        input [3:0]          opcode;
        input signed [15:0]  a_val;
        input signed [15:0]  b_val;
        begin
            op    = opcode;
            A     = a_val;
            B     = b_val;
            start = 1;
            #20;
            start = 0;

            if (opcode == 4'b0010 || opcode == 4'b0011)
                wait (valid);
            else
                #20;

            #20;  
        end
    endtask

    // ==================== Stimulus ====================
    initial begin
        // --- Reset ---
        rst   = 0;
        en    = 1;       // clock ON
        start = 0;
        op    = 0;
        A     = 0;
        B     = 0;
        #50   rst = 1;

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
        
        fork
            begin
                #40  en = 0;  
                #200 en = 1;   
            end
            ALU(4'b0010,  16'sd150,   16'sd120);   // MUL 150 * 120
        join

        ALU(4'b0010,  -16'sd150,   16'sd120);   // MUL -150 * 120
        
        fork
            begin
                #40  en = 0;  
                #250 en = 1;   
            end
            ALU(4'b0010,  -16'sd15000,   -16'sd12000);   // MUL -15000 * -12000
        join

        // ----- Division -----
        fork
            begin
                #30  en = 0;
                #150 en = 1;
            end
            ALU(4'b0011, 16'sd100,   16'sd2);   // DIV
        join
        
        fork
            begin
                #30  en = 0;
                #200 en = 1;
            end
            ALU(4'b0011, 16'sd100,   16'sd3);   // DIV
        join

        ALU(4'b0011,  16'sd100,    -16'sd3);     // DIV 100 / -3
		ALU(4'b0011,  -16'sd100,    -16'sd3);     // DIV -100 / -3
        ALU(4'b0011, 16'sd15,    16'sd0);       // DIV by zero

        // ----- Comparison -----
        ALU(4'b0100, 16'sd12345, -16'sd10000);
        ALU(4'b0100, 16'sd500,    16'sd500);
        ALU(4'b0100, -16'sd12345, 16'sd10000);

        // ----- Logic -----
        ALU(4'b0101, 16'h0F0F, 16'h0F0F);   // NAND
        ALU(4'b0110, 16'h0F0F, 16'h0F0F);   // AND
        ALU(4'b0111, 16'h0F0F, 16'h0F0F);   // NOR
        ALU(4'b1000, 16'h0F0F, 16'h0F0F);   // OR
        ALU(4'b1001, 16'h0F0F, 16'h0F0F);   // XOR

        // ----- Shifts -----
        ALU(4'b1010, 16'h0F0F, 4'd0);
        ALU(4'b1010, 16'h0F0F, 4'd8);
        ALU(4'b1011, 16'h0F0F, 4'd0);
        ALU(4'b1011, 16'h0F0F, 4'd8);
        ALU(4'b1011, 16'h0F0F, 4'd15);
        
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

    // ==================== Monitor ====================
    initial begin
        $display("time  en  op   A        B       Z_high    Z_low     valid");
        $monitor("%0t  %b  %b  %h  %h  %h  %h  %b",
                 $time, en, op, A, B, Z_high, Z_low, valid);
    end

endmodule