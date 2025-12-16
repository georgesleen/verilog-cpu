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
    logic [XLEN-1:0] program_counter_next;
    logic [XLEN-1:0] registers[REGISTER_COUNT-1:0];
    logic [XLEN-1:0] registers_next[REGISTER_COUNT-1:0];

    /*
    * Decode
    */
    logic [OPCODE_FIELD_WIDTH-1:0] instruction_class;
    logic [REGISTER_INDEX_WIDTH-1:0] destination_register_index;
    logic [REGISTER_INDEX_WIDTH-1:0] source_register_1_index;
    logic [REGISTER_INDEX_WIDTH-1:0] source_register_2_index;

    /*
    * Immediate values
    */
    logic [XLEN-1:0] immediate_i;
    logic [XLEN-1:0] immediate_s;
    logic [XLEN-1:0] immediate_j;

    /*
    * Decode logic
    */
    assign instruction_class = instruction[OPCODE_MSB:OPCODE_LSB];
    assign destination_register_index = instruction[DEST_REG_MSB:DEST_REG_LSB];
    assign source_register_1_index = instruction[SRC_REG1_MSB:SRC_REG1_LSB];
    assign source_register_2_index = instruction[SRC_REG2_MSB:SRC_REG2_LSB];

    assign immediate_i = {{(XLEN - 12) {instruction[31]}}, instruction[31:20]};
    assign immediate_s = {{(XLEN - 12) {instruction[31]}}, instruction[31:25], instruction[11:7]};
    assign immediate_j = {
        {(XLEN - 12) {instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21]
    };

    /*
    * Execute
    */
    always_comb begin
        // Default behavior
        program_counter_next = program_counter + INSTRUCTION_BYTES;
        registers_next       = registers;
        memory_write_enable  = 1'b0;
        memory_address       = '0;
        memory_write_data    = '0;

        // Instruction specific
        case (instruction_class)
            // Integer arithmetic with immediate
            CLASS_OP_IMM: begin
                registers_next[destination_register_index] = registers[source_register_1_index] + immediate_i;
            end
            // Jump and link
            CLASS_JAL: begin
                registers_next[destination_register_index] = program_counter + INSTRUCTION_BYTES;
                program_counter_next                       = program_counter + immediate_j;
            end
            // Store to memory
            CLASS_STORE: begin
                memory_write_enable = 1'b1;
                memory_address      = registers[source_register_1_index] + immediate_s;
                memory_write_data   = register_file[source_register_2_index];
            end
            default: begin
                // nop
            end
        endcase

        // Enforce register X0 = 0
        registers_next[X0] = '0;
    end

    /*
    * Commit
    */
    always_ff @(posedge clk) begin
        if (~n_rst) begin
            program_counter <= '0;
            for (int i = 0; i < REGISTER_COUNT; i++) begin
                registers[i] <= '0;
            end
        end else begin
            program_counter <= program_counter_next;
            registers       <= registers_next;
        end
    end

endmodule
