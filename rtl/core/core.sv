import riscv_pkg::*;

module core #(
    parameter int XLEN = 32
) (
    input logic clk,
    input logic n_rst,

    output logic [XLEN-1:0] program_counter,
    input logic [INSTRUCTION_WIDTH-1:0] instruction,

    output logic memory_write_enable,
    output logic [XLEN-1:0] memory_address,
    output logic [XLEN-1:0] memory_write_data,
    input logic [XLEN-1:0] memory_read_data
);

  /*
  * Architectural state
  */
  logic [XLEN-1:0] pc_reg, pc_next;
  logic [XLEN-1:0] registers[REGISTER_COUNT-1:0];
  logic [XLEN-1:0] registers_next[REGISTER_COUNT-1:0];

  assign program_counter = pc_reg;

    /*
    * Decode
    */

endmodule
