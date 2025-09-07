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


    assign load = ui_in[0];
    assign serial_input = ui_in[1];
    assign direction = ui_in[2];
    assign parallel_load[0] = ui_in[3];
    assign parallel_load[1] = ui_in[4];
    assign parallel_load[2] = ui_in[5];
    assign parallel_load[3] = ui_in[6];

    assign parallel_out[0] = uo_out[0];
    assign parallel_out[1] = uo_out[1];
    assign parallel_out[2] = uo_out[2];
    assign parallel_out[3] = uo_out[3];
    assign uo_out[7:4] = 4'b0;
    
    always @(posedge clk or posedge rst_n) begin
      if (rst_n) begin
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

  // List all unused inputs to prevent warnings
  wire _unused = &{ena,1'b0};

endmodule
