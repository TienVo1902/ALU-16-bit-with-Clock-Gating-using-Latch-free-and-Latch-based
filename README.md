# Low-Power 16-Bit ALU Design Using Clock Gating Techniques

## 📖 Introduction
This project presents the design and implementation of a **16-bit Arithmetic Logic Unit (ALU)** optimized for low power consumption using **Clock Gating** techniques. The design supports **14 distinct operations**, including advanced arithmetic like Booth Multiplication and Restoring Division.

The project evaluates and compares three design variations to analyze power efficiency:
1.  **Original ALU:** Baseline design without clock gating.
2.  **AND-based Clock Gating (Latch-free):** Simple structure with low hardware overhead.
3.  **Latch-based Clock Gating (Integrated Clock Gating - ICG):** Glitch-free and robust, suitable for high-reliability applications.

## ⚡ Key Features
-   **Bit-width:** 16-bit signed integer operations.
-   **Operations:** 14 operations controlled by a 4-bit Opcode:
    -   *Arithmetic:* Addition (CLA), Subtraction, Multiplication (Booth Radix-4), Division (Restoring Algorithm).
    -   *Logic:* AND, OR, XOR, NAND, NOR.
    -   *Shift/Rotate:* Logical Shift Left/Right, Rotate Left/Right.
    -   *Comparison:* Signed comparison (Greater, Equal, Less).
-   **Power Optimization:** Implements selective clock disabling for inactive modules to reduce switching activity.

## 📂 Repository Structure
-   `ALU_16bit/`: Source code for the **Original ALU** (Baseline design, no Clock Gating).
-   `ALU_16bit_CGating/`: Source code for the ALU with **Latch-based Clock Gating (ICG)**.
-   `ALU_AND_based/`: Source code for the ALU with **AND-based Clock Gating**.
-   `Testbench/`: Simulation files and waveforms (if applicable).

## 🛠 System Architecture
The ALU is partitioned into distinct functional blocks to facilitate clock gating:
1.  **Adder/Subtractor:** 16-bit Carry Lookahead Adder (CLA).
2.  **Multiplier:** Booth Radix-4 Algorithm (8 cycles latency).
3.  **Divider:** Restoring Division Algorithm (16 cycles latency).
4.  **Shifter/Rotator:** Barrel shifter design for single-cycle operations.
5.  **Clock Gating Logic:** Control unit to generate Enable signals for specific blocks based on the Opcode.

## 📊 Results & Performance
Performance was evaluated using SAIF-based power analysis at varying frequencies (50MHz, 100MHz, 150MHz).

| Metric | Original ALU | AND-based CG | Latch-based CG | Improvement (AND-based) |
| :--- | :--- | :--- | :--- | :--- |
| **Power @ 50MHz** | 5.883 mW | 4.770 mW | 4.961 mW | **~18.9% Reduction** |
| **Power @ 100MHz** | 7.302 mW | 6.197 mW | 6.607 mW | **~15.2% Reduction** |
| **Power @ 150MHz** | 8.708 mW | 7.617 mW | 8.245 mW | **~12.5% Reduction** |

*Key finding:* The AND-based technique offers the highest power savings but requires careful timing to avoid glitches, whereas the Latch-based technique provides a balanced trade-off between power and reliability.

## 📜 References
1.  D. M. Harris and S. L. Harris, *Digital Design and Computer Architecture*.
2.  Measurements performed using Xilinx Vivado / Power Analysis Tools.
