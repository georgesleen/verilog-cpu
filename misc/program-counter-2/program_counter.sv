`default_nettype none
module program_counter #(
    parameter int WIDTH = 32
) (
    input var logic i_clk,
    input var logic i_n_rst,
    input var logic i_jump,
    input var logic [WIDTH - 1:0] i_address,
    output var logic [WIDTH - 1:0] o_address
);

  /// Clock counter increment
  always_ff @(posedge clk) begin
    if (i_jump) begin
      out_address <= in_address;
    end else begin
      out_address <= out_address + 1;
    end
  end

  /// Async reset
  always_ff @(negedge n_rst) begin
    if (!n_rst) begin
      out_address <= 0;
    end else begin
      out_address <= 0;
    end
  end

endmodule
