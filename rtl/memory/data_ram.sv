import riscv_pkg::*;

module data_ram #(
    parameter int XLEN        = 32,
    parameter int DEPTH_WORDS = 1024
) (
    input logic clk,
    input logic write_enable,
    input logic [XLEN-1:0] address,
    input logic [XLEN-1:0] write_data,
    output logic [XLEN-1:0] read_data
);

    logic [XLEN-1:0] memory[DEPTH_WORDS];
    logic [$clog2(DEPTH_WORDS)-1:0] word_address;

    assign word_address = address / INSTRUCTION_BYTES;

    /*
    * Asynchronous read
    */
    assign read_data    = memory[word_address];

    /*
    * Synchronous write
    */
    always_ff @(posedge clk) begin
        if (write_enable) begin
            memory[word_address] <= write_data;
        end else begin
            memory[word_address] <= memory[word_address];
        end
    end

endmodule
