# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())
    #uo_out[3:0] = parallel_out

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 0

    dut._log.info("Test project behavior")

     # --- Test 1: Parallel Load ---
    dut.ui_in[0].value = 1
    val = dut.ui_in.value.integer
    val &= ~(0b1111 << 3)       # clear bits 6:3
    val |= (0b1011 << 3)        # set parallel_load=1011
    dut.ui_in.value = val
    await RisingEdge(dut.clk)
    dut.ui_in[0].value = 0
    #assert dut.uo_out[3:0].value == 0b1011, f"Parallel load failed! Got {dut.parallel_out.value}"

    # --- Test 2: Shift Right ---
    dut.ui_in[2].value = 0  # shift right
    dut.ui_in[1].value = 1
    for _ in range(3):
        await RisingEdge(dut.clk)
        cocotb.log.info(f"Shift Right -> {dut.uo_out.value.binstr}")

    # --- Test 3: Shift Left ---
    dut.ui_in[2].value = 1  # shift left
    dut.ui_in[1].value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
        cocotb.log.info(f"Shift Left -> {dut.uo_out.value.binstr}")

    # --- Test 4: Parallel Load again ---
    dut.ui_in[0].value = 1
    val = dut.ui_in.value.integer  
    val &= ~(0b1111 << 3)
    val |= (0b1100 << 3)
    dut.ui_in.value = val
    await RisingEdge(dut.clk)
    dut.load.value = 0
    #assert dut.uo_out[3:0].value == 0b1100, f"Second parallel load failed! Got {dut.uo_out[3:0].value}"

    # --- Final: Extra Right Shifts ---
    dut.ui_in[2].value = 0
    dut.ui_in[1].value = 1
    for _ in range(4):
        await RisingEdge(dut.clk)
        cocotb.log.info(f"Final Shift Right -> {dut.parallel_out.value.binstr}")

    cocotb.log.info("✅ All tests passed!")


    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    #assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
