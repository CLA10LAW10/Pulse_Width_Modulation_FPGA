`timescale 1ns / 1ns

module pwm_enhanced #(parameter int R = 10) (
    input logic clk,
    input logic reset,
    input logic [31:0] dvsr,
    input logic [R:0] duty,
    output logic pwm_out
  );

  // Counting the ticks for pwm switching freq
  logic [31:0] q_reg;
  logic [31:0] q_next;
  logic tick;

  // Counting the duty cycle
  logic [R-1:0] d_reg;
  logic [R-1:0] d_next;

  // Duty cycle count value
  logic [R:0] d_ext;

  // PWM out
  logic pwm_reg;
  logic pwm_next;
  
// Updating PWM module registers
  always_ff @(posedge clk or posedge reset)
  begin
    if (reset)
    begin
      q_reg <= 'b0;
      d_reg <= 'b0;
      pwm_reg <= 'b0;
    end
    else
    begin
      q_reg <= q_next;
      d_reg <= d_next;
      pwm_reg <= pwm_next;
    end
  end

  assign q_next = (q_reg == dvsr) ? 'b0 : q_reg + 1;
  assign tick = (q_reg == 'b0) ? 1'b1 : 1'b0;
  assign d_next = (tick == 1'b1) ? d_reg + 1 : d_reg;
  assign d_ext = {1'b0, d_reg};

  // comparison circuit
  assign pwm_next = (d_ext < duty) ? 1'b1 : 1'b0;

  // PWM out
  assign pwm_out = pwm_reg ;
endmodule