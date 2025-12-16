/**
* top.sv
* @brief Top-level definition for a simple RISC-V SoC.
*
* @param XLEN the SoC address bit width (32 or 64).
* @param clk the provided clock for the SoC.
* @param n_rst active low reset signal for the SoC.
*/
module top #(
    parameter int XLEN = 32
) (
    input logic clk,
    input logic n_rst
);
  import riscv_pkg::*;

  logic [XLEN-1:0] program_counter;
  logic [INSTRUCTION_WIDTH-1:0] instruction_register;

  logic memory_write_enable;
  logic [XLEN-1:0] memory_address;
  logic [XLEN-1:0] memory_write_data;
  logic [XLEN-1:0] memory_read_data;


endmodule
