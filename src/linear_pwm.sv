`timescale 1ns / 1ns

module linear_pwm (
    input logic clk,
    input logic reset,
    output logic [2:0] rgb
  );

  parameter resolution = 8;
  parameter grad_thresh = 2_499_999;
  logic [12:0] dvsr = 'd4882; // sysclk / (pwm_freq* 2**8)
  logic [resolution:0] duty; // Use to assign a single dim value = 'd25;
  logic pwm_out1;

  integer counter;
  logic gradient_pulse;
  logic [resolution:0] duty_reg;

  pwm_enhanced #(.R(resolution)) p_i0 (.clk(clk),.reset(reset),.dvsr(dvsr),.duty(duty),.pwm_out(pwm_out1));

  always_ff @ (posedge clk, posedge reset)
  begin
    if (reset)
    begin
      counter <= 0;
      duty_reg <= 0;
    end
    else
    begin
      if (counter < grad_thresh)
      begin
        counter <= counter + 1;
        gradient_pulse <= 0;
      end
      else
      begin
        counter <= 0;
        gradient_pulse <= 1;
      end
      if (gradient_pulse == 1)
      begin
        duty_reg <= duty_reg + 1;
      end

      if (duty_reg == 256)
      begin
        duty_reg <= 0;
      end
    end
  end

  assign duty = duty_reg;

  assign rgb[0] = pwm_out1;
  assign rgb[1] = 1'b0;
  assign rgb[2] = 1'b0;


endmodule
