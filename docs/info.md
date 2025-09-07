<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
The shift register has:
•	Inputs:
  o	clk → Clock signal
  o	reset → Clears the register to 0
  o	load → If 1, loads data directly from parallel_load
  o	direction → Shift direction (0 = right, 1 = left)
  o	serial_input → Bit shifted in during shift operations
  o	parallel_load[3:0] → 4-bit data to load in parallel
•	Output:
  o	parallel_out[3:0] → Current value of the shift register

How It Works (Step by Step)
1. Reset
   When reset=1, no matter what else is happening, the register is cleared to 0000.
2. Parallel Load
   When load=1, the register ignores shifting and directly loads the 4-bit input parallel_load.
   Example: if parallel_load = 1011, then parallel_out = 1011 on next clock.
3. Shift Operations
   1. Shift Right (direction = 0)
      •	Shifts everything to the right.
      •	parallel_out[3] gets the new serial_input.
      •	Bits [3:1] shift into [2:0].
      •	The old parallel_out[0] is dropped.
      Example:
        -> parallel_out = 1011, serial_input=1
        -> After clock → parallel_out = 1101.
   2.Shift Left (direction = 1)
      •	Shifts everything to the left.
      •	parallel_out[0] gets the new serial_input.
      •	Bits [2:0] shift into [3:1].
      •	The old parallel_out[3] is dropped.
      Example:
        -> parallel_out = 1011, serial_input=0
        -> After clock → parallel_out = 0110  
4. Default
   If somehow direction is invalid (shouldn’t happen since it’s 1 bit), output clears to 0000.
## How to test

At time 0–10 ns → reset=1, so parallel_out=0000.

At time 20 ns → load=1, register loads 1011.

Next few cycles with direction=0 → register shifts right, new bits enter from serial_input.

Later with direction=1 → register shifts left.

Another load happens → register becomes 1100.

Final cycles → more shifts happen.

## External hardware

No external hardware is required besides  TT demo board.
