import riscv_pkg::*;

module instruction_rom #(
    parameter int XLEN        = 32,
    parameter int DEPTH_WORDS = 1024
) (
    input logic [XLEN-1:0] address,
    output logic [INSTRUCTION_WIDTH-1:0] instruction
);
    /*
    * ROM storage
    */
    logic [INSTRUCTION_WIDTH-1:0] memory[DEPTH_WORDS];
    logic [$clog2(DEPTH_WORDS)-1:0] word_address;

    assign word_address = address / INSTRUCTION_BYTES;

    /*
    * Asynchronous read
    */
    assign instruction  = memory[word_address];

    /*
    * Load program at sim time
    */
    initial begin
        readmemh("program.hex", memory);
    end

endmodule
