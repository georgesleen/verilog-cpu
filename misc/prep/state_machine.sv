module traffic_light (
  input logic clk,
  input logic rst_n,
  input logic timer_done,
  output logic [2:0] ns_light,
  output logic [2:0] ew_light
);

  // Traffic light encoding
  localparam RED    = 3'b001;
  localparam YELLOW = 3'b010;
  localparam GREEN  = 3'b100;

  // State definition
  typedef enum logic [2:0] {
    S_NS_GREEN,
    S_NS_YELLOW,
    S_ALL_RED_1,
    S_EW_GREEN,
    S_EW_YELLOW,
    S_ALL_RED_2
  } state_t;

  state_t current_state, next_state;

  // State register
  always_ff @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
      current_state  <= S_ALL_RED_1;
    end
    else begin
      current_state <= next_state;
    end
  end

  // State transition logic
  always_comb begin
    case (current_state)
      S_NS_GREEN: begin
          if (timer_done) begin
            next_state = S_NS_YELLOW;
          end
          else begin
            next_state = S_NS_GREEN;
          end
        end
      S_NS_YELLOW: begin
          if (timer_done) begin
            next_state = S_ALL_RED_1;
          end
          else begin
            next_state = S_NS_YELLOW;
          end
        end
      S_ALL_RED_1: begin
          if (timer_done) begin
            next_state = S_EW_GREEN;
          end
          else begin
            next_state = S_ALL_RED_1;
          end
        end
      S_EW_GREEN: begin
          if (timer_done) begin
            next_state = S_EW_YELLOW;
          end
          else begin
            next_state = S_EW_GREEN;
          end
        end
      S_EW_YELLOW: begin
          if (timer_done) begin
            next_state = S_ALL_RED_2;
          end
          else begin
            next_state = S_EW_YELLOW;
          end
        end
      S_ALL_RED_2: begin
          if (timer_done) begin
            next_state = S_NS_GREEN;
          end
          else begin
            next_state = S_ALL_RED_2;
          end
        end
      default: next_state = S_ALL_RED_1;
    endcase
  end

  // Output logic
  always_comb begin
    case (current_state)
      S_NS_GREEN: begin
        ns_light = GREEN;
        ew_light = RED;
      end
      S_NS_YELLOW: begin
        ns_light = YELLOW;
        ew_light = RED;
      end
      S_ALL_RED_1: begin
        ns_light = RED;
        ew_light = RED;
      end
      S_EW_GREEN: begin
        ns_light = RED;
        ew_light = GREEN;
      end
      S_EW_YELLOW: begin
        ns_light = RED;
        ew_light = YELLOW;
      end
      S_ALL_RED_2: begin
        ns_light = RED;
        ew_light = RED;
      end
      default: begin
        ns_light = RED;
        ew_light = RED;
      end
    endcase
  end

endmodule
