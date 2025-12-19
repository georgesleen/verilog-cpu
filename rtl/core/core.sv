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

    // Registers
    logic [XLEN-1:0] program_counter_next;

    logic [REGISTER_INDEX_WIDTH-1:0] rs1_addr, rs2_addr;
    logic [XLEN-1:0] rs1_data, rs2_data;

    logic rd_wen;
    logic [REGISTER_INDEX_WIDTH-1:0] rd_addr;
    logic [XLEN-1:0] rd_data;

    regfile #(
        .XLEN(XLEN)
    ) regs (
        .clk  (clk),
        .n_rst(n_rst),

        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr (rd_addr),

        .rd_wen  (rd_wen),
        .rd_wdata(rd_data),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    /*
    * Decode
    */
    logic [OPCODE_FIELD_WIDTH-1:0] instruction_class;

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
    assign rd_addr = instruction[DEST_REG_MSB:DEST_REG_LSB];
    assign rs1_addr = instruction[SRC_REG1_MSB:SRC_REG1_LSB];
    assign rs2_addr = instruction[SRC_REG2_MSB:SRC_REG2_LSB];

    assign immediate_i = {{(XLEN - 12) {instruction[31]}}, instruction[31:20]};
    assign immediate_s = {{(XLEN - 12) {instruction[31]}}, instruction[31:25], instruction[11:7]};
    assign immediate_j = {
        {(XLEN - 12) {instruction[31]}},
        instruction[19:12],
        instruction[20],
        instruction[30:21],
        1'b0
    };

    /*
    * Execute
    */
    always_comb begin
        // Default behavior
        program_counter_next = program_counter + INSTRUCTION_BYTES;

        // RAM default behavior
        memory_write_enable  = 1'b0;
        memory_address       = '0;
        memory_write_data    = '0;

        // Register default behavior
        rd_wen               = 1'b0;
        rd_data              = '0;

        // Instruction specific
        unique case (instruction_class)
            // Integer arithmetic with immediate
            CLASS_OP_IMM: begin
                rd_wen  = 1'b1;
                rd_data = rs1_data + immediate_i;
            end

            // Jump and link
            CLASS_JAL: begin
                program_counter_next = program_counter + immediate_j;

                rd_wen               = 1'b1;
                rd_data              = program_counter + INSTRUCTION_BYTES;
            end

            // Store to memory
            CLASS_STORE: begin
                memory_write_enable = 1'b1;
                memory_address      = rs1_data + immediate_s;
                memory_write_data   = rs2_data;
            end

            default: begin
                // nop
            end
        endcase
    end

    /*
    * Commit
    */
    always_ff @(posedge clk) begin
        if (~n_rst) begin
            program_counter <= '0;
        end else begin
            program_counter <= program_counter_next;
        end
    end

endmodule
