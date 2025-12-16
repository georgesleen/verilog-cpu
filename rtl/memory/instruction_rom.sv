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
    * main.hex produced by objcopy is byte-addressed, so store bytes and
    * reassemble words on the fly.
    */
    localparam int DEPTH_BYTES = DEPTH_WORDS * INSTRUCTION_BYTES;

    logic [BYTE_WIDTH-1:0] memory[DEPTH_BYTES];
    logic [$clog2(DEPTH_WORDS)-1:0] word_address;

    assign word_address = address / INSTRUCTION_BYTES;

    /*
    * Asynchronous read (little-endian)
    */
    assign instruction = {
        memory[(word_address * INSTRUCTION_BYTES) + 3],
        memory[(word_address * INSTRUCTION_BYTES) + 2],
        memory[(word_address * INSTRUCTION_BYTES) + 1],
        memory[(word_address * INSTRUCTION_BYTES) + 0]
    };

    /*
    * Load program at sim time
    */
    initial begin
        $readmemh("main.hex", memory);
    end

endmodule
