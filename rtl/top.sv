import riscv_pkg::*;

/**
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
    logic [XLEN-1:0] program_counter;
    logic [INSTRUCTION_WIDTH-1:0] instruction;

    logic memory_write_enable;
    logic [XLEN-1:0] memory_address;
    logic [XLEN-1:0] memory_write_data;
    logic [XLEN-1:0] memory_read_data;

    /*
    * CPU
    */
    core cpu (
        .clk  (clk),
        .n_rst(n_rst),

        .program_counter(program_counter),
        .instruction    (instruction),

        .memory_write_enable(memory_write_enable),
        .memory_address     (memory_address),
        .memory_write_data  (memory_write_data),
        .memory_read_data   (memory_read_data)
    );

    /*
    * Memory
    */
    instruction_rom rom (
        .address    (program_counter),
        .instruction(instruction)
    );

    data_ram ram (
        .clk         (clk),
        .write_enable(memory_write_enable),
        .address     (memory_address),
        .write_data  (memory_write_data),
        .read_data   (memory_read_data)
    );

endmodule
