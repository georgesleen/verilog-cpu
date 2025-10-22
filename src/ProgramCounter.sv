module ProgramCounter #(
    parameter int unsigned WIDTH = 32,
    parameter logic [WIDTH-1:0] RESET_VECTOR = '0,
    parameter logic [WIDTH-1:0] STRIDE = 'h1
) (
    input logic clk_i,
    input logic rst_ni,
    input logic enable_i,
    input logic jump_i,
    input logic [WIDTH-1:0] jump_address_i,
    output logic [WIDTH-1:0] pc_current_o
);

  // Internal state register
  logic [WIDTH-1:0] pc_next;

  // Next state logic
  always_comb begin
    if (jump_i) begin
      pc_next = jump_address_i;
    end else if (enable_i) begin
      pc_next = pc_next + STRIDE;
    end else begin
      pc_next = pc_current_o;
    end
  end

  // Sequential register with async reset
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      pc_current_o <= RESET_VECTOR;
    end
    else begin
      pc_current_o <= pc_next;
    end
  end

endmodule
