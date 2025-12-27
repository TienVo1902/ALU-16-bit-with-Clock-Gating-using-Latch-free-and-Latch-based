# Low-Power 16-Bit ALU Design Using Clock Gating Techniques

## 📖 Introduction
This project presents the design and implementation of a **16-bit Arithmetic Logic Unit (ALU)** optimized for low power consumption using **Clock Gating** techniques. The design supports **14 distinct operations**, including advanced arithmetic like Booth Multiplication and Restoring Division.

The project evaluates and compares two clock gating strategies to minimize dynamic power dissipation:
1.  [cite_start]**AND-based Clock Gating (Latch-free):** Simple structure, suitable for low hardware overhead[cite: 384].
2.  [cite_start]**Latch-based Clock Gating (Integrated Clock Gating - ICG):** Glitch-free and robust, suitable for high-reliability applications[cite: 387].

[cite_start]**Project Status:** Completed (July 2025) [cite: 9]
[cite_start]**University:** Ho Chi Minh City University of Technology and Education (HCMUTE) [cite: 1]

## ⚡ Key Features
-   **Bit-width:** 16-bit signed integer operations.
-   [cite_start]**Operations:** 14 operations controlled by a 4-bit Opcode[cite: 429]:
    -   *Arithmetic:* Addition (CLA), Subtraction, Multiplication (Booth Radix-4), Division (Restoring Algorithm).
    -   *Logic:* AND, OR, XOR, NAND, NOR.
    -   *Shift/Rotate:* Logical Shift Left/Right, Rotate Left/Right.
    -   *Comparison:* Signed comparison (Greater, Equal, Less).
-   [cite_start]**Power Optimization:** Implements selective clock disabling for inactive modules to reduce switching activity[cite: 105].

## 📂 Repository Structure
-   `ALU_16bit_CGating/`: Source code for the ALU with Latch-based Clock Gating (ICG).
-   `ALU_AND_based/`: Source code for the ALU with AND-based Clock Gating.
-   `Testbench/`: (Optional) Simulation files and waveforms.

## 🛠 System Architecture
[cite_start]The ALU is partitioned into distinct functional blocks to facilitate clock gating[cite: 122]:
1.  [cite_start]**Adder/Subtractor:** 16-bit Carry Lookahead Adder (CLA)[cite: 156].
2.  [cite_start]**Multiplier:** Booth Radix-4 Algorithm (8 cycles latency)[cite: 169].
3.  [cite_start]**Divider:** Restoring Division Algorithm (16 cycles latency)[cite: 214].
4.  [cite_start]**Shifter/Rotator:** Barrel shifter design for single-cycle operations[cite: 280].
5.  **Clock Gating Logic:** Control unit to generate Enable signals for specific blocks based on the Opcode.

## 📊 Results & Performance
[cite_start]Performance was evaluated using SAIF-based power analysis at varying frequencies (50MHz, 100MHz, 150MHz)[cite: 568].

| Metric | Original ALU | AND-based CG | Latch-based CG | Improvement (AND-based) |
| :--- | :--- | :--- | :--- | :--- |
| **Power @ 50MHz** | 5.883 mW | 4.770 mW | 4.961 mW | [cite_start]**~18.9% Reduction** [cite: 583] |
| **Power @ 100MHz** | 7.302 mW | 6.197 mW | 6.607 mW | [cite_start]**~15.2% Reduction** [cite: 588] |
| **Power @ 150MHz** | 8.708 mW | 7.617 mW | 8.245 mW | [cite_start]**~12.5% Reduction** [cite: 592] |

[cite_start]*Key finding:* The AND-based technique offers the highest power savings but requires careful timing to avoid glitches, whereas the Latch-based technique provides a balanced trade-off between power and reliability[cite: 602].


## 📜 References
1.  D. M. Harris and S. L. Harris, *Digital Design and Computer Architecture*.
2.  Measurements performed using Xilinx Vivado / Power Analysis Tools.
