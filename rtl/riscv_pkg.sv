/**
* riscv_pkg.sv
*
* @brief Simple package to hold architectural specifications
*/
package riscv_pkg;

  // ISA specification
  localparam int BYTE_WIDTH        = 8;
  localparam int INSTRUCTION_WIDTH = 32;
  localparam int INSTRUCTION_BYTES = INSTRUCTION_WIDTH / BYTE_WIDTH;
  localparam int REGISTER_COUNT    = 32;

  // Instruction field widths
  localparam int OPCODE_FIELD_WIDTH = 7;

  // Opcodes
  localparam logic [OPCODE_FIELD_WIDTH-1:0] CLASS_OP_IMM  = 7'b0010011;
  localparam logic [OPCODE_FIELD_WIDTH-1:0] CLASS_OP      = 7'b0110011;
  localparam logic [OPCODE_FIELD_WIDTH-1:0] CLASS_LOAD    = 7'b0000011;
  localparam logic [OPCODE_FIELD_WIDTH-1:0] CLASS_STORE   = 7'b0100011;
  localparam logic [OPCODE_FIELD_WIDTH-1:0] CLASS_BRANCH  = 7'b1100011;
  localparam logic [OPCODE_FIELD_WIDTH-1:0] CLASS_JAL     = 7'b0100011;
  localparam logic [OPCODE_FIELD_WIDTH-1:0] CLASS_JALR    = 7'b0100011;

  // Registers
  localparam int X0 = 0;
  localparam int RA = 1;
  localparam int SP = 2;

endpackage
