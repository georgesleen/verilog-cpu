/**
* riscv_pkg.sv
*
* @brief Simple package to hold architectural specifications
*/
package riscv_pkg;

  // ISA specification
  localparam int BYTE_WIDTH = 8;
  localparam int INSTRUCTION_WIDTH = 32;
  localparam int INSTRUCTION_BYTES = INSTRUCTION_WIDTH / BYTE_WIDTH;
  localparam int REGISTER_COUNT = 32;

endpackage
