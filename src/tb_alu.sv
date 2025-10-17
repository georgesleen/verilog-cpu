module tb_adder ();

  // Constants definition
  localparam WIDTH = 8;

  // Inputs
  logic [WIDTH-1:0] a, b;

  // Outputs
  logic [WIDTH-1:0] result;

  // Device under test
  adder #(
    .WIDTH(WIDTH)
  ) dut (
    .a(a),
    .b(b),
    .result(result)
  );

  // File dump
  initial begin
    $dumpfile("tb_adder.vcd");
    $dumpvars(0, tb_adder);
  end

  // Test sequence
  initial begin
    a = 0;
    b = 0;
  
    for (int i = 0; i < 2**WIDTH; i++) begin
      for (int j = 0; j < 2**WIDTH; j++) begin
        #1 b = j;
        if (result !== a + b) begin
          $error("Adder error at: a = %h, b = %h", a, b);
        end
      end
      #1 a = i;
    end

    $finish;  
  end

endmodule
