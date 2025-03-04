# Linear Feedback Shift Register (LFSR) in 16-bit Assembly

## Overview
This project implements a **Linear Feedback Shift Register (LFSR)** in **16-bit x86 Assembly (MASM)**. The LFSR generates a sequence of pseudo-random bits based on a 32-bit seed, and prints the generated bits on the screen. The seed is initialized using values from the BIOS data area, adding randomness from the system state.

## How It Works

### Seed Initialization
- The 32-bit initial seed is created by XOR-ing the following BIOS values:
  - **Equipment List** at memory address `0040h:0010h`
  - **Keyboard Extended Shift Status** at memory address `0040h:0018h`
- Both values are combined using `XOR`, and stored as two 16-bit values: `seed_low` and `seed_high`.

### Feedback Polynomial
The LFSR uses the feedback polynomial:

```
x^32 + x^22 + x^2 + x^1 + 1
```

### Printing Bits
- The program prints **100 bits** on the last row of the screen, using BIOS interrupts:
  - **Interrupt 10h (video services)** is used to set the cursor position and print characters.
  - The cursor position is tracked with the `bitsPrinted` counter.
  - When **80 bits** are printed, the cursor resets to the beginning of the row (simulating line wrapping).

