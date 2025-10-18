/**
*  Finite state machine RISC-V program counter
*
*  @param WIDTH How wide registers in the architecture are
*/
module program_counter #(
    parameter int WIDTH
) (
    input logic clk,
    input logic n_rst,
    input logic [WIDTH-1:0] in_address,
    output logic [WIDTH-1:0] out_address
);

  /**
  *  op-code definitions
  */
  localparam int [7:0] JUMP = 8'h00;

  // register to track if a jump should be performed
  logic r_jump;

  /**
  *  FSM to update the output address of out_address
  */
  always_ff @(posedge clk) begin
    if (r_jump == 1'b1) begin
      out_address <= 32'hffff;
    end else begin
      out_address <= out_address + 1;
    end
  end

  /**
  *  Operation decoding
  */
  always_comb begin
    if (in_bus[7:0] == JUMP) begin
      r_jump = 1'b1;
    end else begin
      r_jump = 1'b0;
    end
  end

  /**
  *  Async reset
  */
  always_ff @(negedge n_rst) begin
    if (~n_rst) begin
      out_address <= 0;
    end else begin
      out_address <= out_address;
    end
  end

endmodule
