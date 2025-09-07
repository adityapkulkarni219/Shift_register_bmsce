/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_shift (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    
    shift_register_design mydesign(
        .clk (clk),
        .reset (rst_n),
        .load (ui_in[0]),
        .serial_input (ui_in[1]),
        .direction (ui_in[2]),
        .parallel_load (ui_in[6:3]),
        .parallel_out (uo_out[3:0])
    );
      
    assign uo_out[7:4] = 4'b0;
    assign uio_out[7:0] = 8'b0;
    assign uio_oe [7:0] = 8'b0;
    
  // List all unused inputs to prevent warnings
    wire _unused = &{ena,1'b0,  uio_in[7:0], uio_out[7:0], uio_oe[7:0], ui_in[7]};

endmodule

module shift_register_design(
    input clk,
    input serial_input,
    input load,
    input direction,   // 0 = shift right, 1 = shift left
    input reset,
    input [3:0] parallel_load,
    output reg [3:0] parallel_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        parallel_out <= 4'b0;
    end 
    else if (load) begin
        // Load all 4 bits directly
        parallel_out <= parallel_load;
    end 
    else begin
        case (direction)
            1'b0: parallel_out <= {serial_input, parallel_out[3:1]}; // Shift right
            1'b1: parallel_out <= {parallel_out[2:0], serial_input}; // Shift left
            default: parallel_out <= 4'b0;
        endcase
    end
end

endmodule
