# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

     # --- Test 1: Parallel Load ---
    dut.load.value = 1
    dut.parallel_load.value = 0b1011
    await RisingEdge(dut.clk)
    dut.load.value = 0
    assert dut.parallel_out.value == 0b1011, f"Parallel load failed! Got {dut.parallel_out.value}"

    # --- Test 2: Shift Right ---
    dut.direction.value = 0  # shift right
    dut.serial_input.value = 1
    for _ in range(3):
        await RisingEdge(dut.clk)
        cocotb.log.info(f"Shift Right -> {dut.parallel_out.value.binstr}")

    # --- Test 3: Shift Left ---
    dut.direction.value = 1  # shift left
    dut.serial_input.value = 0
    for _ in range(3):
        await RisingEdge(dut.clk)
        cocotb.log.info(f"Shift Left -> {dut.parallel_out.value.binstr}")

    # --- Test 4: Parallel Load again ---
    dut.load.value = 1
    dut.parallel_load.value = 0b1100
    await RisingEdge(dut.clk)
    dut.load.value = 0
    assert dut.parallel_out.value == 0b1100, f"Second parallel load failed! Got {dut.parallel_out.value}"

    # --- Final: Extra Right Shifts ---
    dut.direction.value = 0
    dut.serial_input.value = 1
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
