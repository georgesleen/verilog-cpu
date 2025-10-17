module adder #(
  parameter WIDTH
)(
  input logic [WIDTH-1:0] a, b,
  output logic [WIDTH-1:0] result
);

  assign result = a + b;

endmodule
