`default_nettype none
module tb_program_counter ();

  /// Constant definition
  int WIDTH = 32;

  /// Inputs and outputs
  logic clk, n_rst, jump;
  logic [WIDTH - 1:0] in_address, out_address;

  /// Module under test
  program_counter #(
    .WIDTH(WIDTH)
  ) u_dut (
    .i_clk(clk),
    .i_n_rst(n_rst),
    .i_jump(jump),
    .i_address(in_address),
    .o_address(out_address)
  );

  /// Test suite
  initial begin
    $dumpfile(tb_program_counter);
    $dumpvars(0, tb_program_counter);

    #1;
  end

  always begin
    #10 clk = ~clk;
  end

endmodule
