`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Replace tt_um_example with your module name:
  tt_um_example user_project (
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );
initial begin
        // Initialize signals
      
        clk = 0;
        rst_n = 1;
        load = 0;
        direction = 0;
        serial_input = 0;
        parallel_load = 4'b0000;

        // Apply reset
        #10 reset = 0;

        // Parallel load = 1011
        #10 load = 1; parallel_load = 4'b1011;
        #10 load = 0;  // disable load

        // Shift right with serial input = 1
        direction = 0;
        serial_input = 1;
        #40;

        // Shift left with serial input = 0
        direction = 1;
        serial_input = 0;
        #40;

        // Parallel load again = 1100
        load = 1; parallel_load = 4'b1100;
        #10 load = 0;

        // More right shifts with serial input = 1
        direction = 0;
        serial_input = 1;
        #40;
      	
      	$finish;
    end
endmodule
