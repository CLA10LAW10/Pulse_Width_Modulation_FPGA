`timescale 1ns / 1ps

module pwm_rainbow(
    input logic clk,
    input logic reset,
    output logic [2:0] rgb
  );

  parameter resolution = 8;
  parameter grad_thresh = 1_000_000;//10_000_000;//2_499_999;
  logic [12:0] dvsr = 'd4882; // sysclk / (pwm_freq* 2**8)

  logic [resolution:0] red_duty; // Used to increase/decrease the duty cycle
  logic [resolution:0] red_duty_reg;

  logic [resolution:0] blue_duty; // Used to increase/decrease the duty cycle
  logic [resolution:0] blue_duty_reg;

  logic [resolution:0] green_duty; // Used to increase/decrease the duty cycle
  logic [resolution:0] green_duty_reg;

  logic pwm_out_red;
  logic pwm_out_blue;
  logic pwm_out_green;

  integer rainbow_counter; // Max 0-255 | 0-41 | 42-83 | 84-125 | 126-167 | 168-209 | 210-255

  integer counter;
  logic gradient_pulse;


  pwm_enhanced #(.R(resolution)) p_i0 (.clk(clk),.reset(reset),.dvsr(dvsr),.duty(red_duty),.pwm_out(pwm_out_red));
  pwm_enhanced #(.R(resolution)) p_i1 (.clk(clk),.reset(reset),.dvsr(dvsr),.duty(blue_duty),.pwm_out(pwm_out_blue));
  pwm_enhanced #(.R(resolution)) p_i2 (.clk(clk),.reset(reset),.dvsr(dvsr),.duty(green_duty),.pwm_out(pwm_out_green));

  always_ff @ (posedge clk, posedge reset)
  begin
    if (reset)
    begin
      counter <= 0;
      rainbow_counter <= 0;
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
        rainbow_counter <= rainbow_counter + 1;
      end

      if (rainbow_counter == 256)
      begin
        rainbow_counter <= 0;
      end
    end
  end

  always_ff @ (posedge clk, posedge reset)
  begin
    if (reset)
    begin
      red_duty_reg  = 8'd255;
      blue_duty_reg = 8'b0;
      green_duty_reg = 8'b0;
    end
    else
    begin
      if (gradient_pulse)
      begin
        // Max 0-255 | 0-41 | 42-83 | 84-125 | 126-167 | 168-209 | 210-255
        // Segment 1
        if (rainbow_counter < 42)
        begin
          red_duty_reg  = 8'd255;
          blue_duty_reg = 8'b0;
          green_duty_reg = green_duty_reg + 1;
        end
        // Segment 2
        else if (rainbow_counter >=42 && rainbow_counter < 84)
        begin
          red_duty_reg  = red_duty_reg - 1;
          blue_duty_reg = 8'd0;
          green_duty_reg = 8'd255;
        end
        // Segment 3
        else if (rainbow_counter >=84 && rainbow_counter < 126)
        begin
          red_duty_reg  = 8'd0;
          blue_duty_reg = blue_duty_reg + 1;
          green_duty_reg = 8'd255;
        end
        // Segment 4
        else if (rainbow_counter >=126 && rainbow_counter < 168)
        begin
          red_duty_reg  = 8'd0;
          blue_duty_reg = 8'd255;
          green_duty_reg = green_duty_reg - 1;
        end
        // Segment 5
        else if (rainbow_counter >=168 && rainbow_counter < 210)
        begin
          red_duty_reg  = red_duty_reg + 1;
          blue_duty_reg = 8'd255;
          green_duty_reg = 8'b0;
        end
        // Segment 6
        else if (rainbow_counter >=210 && rainbow_counter < 256)
        begin
          red_duty_reg  = 8'd255;
          blue_duty_reg = blue_duty_reg - 1;
          green_duty_reg = 8'b0;
        end
        // Else condition
        else
        begin
          red_duty_reg  = 8'd255;
          blue_duty_reg = 8'b0;
          green_duty_reg = 8'b0;
        end

      end
    end
  end

  assign red_duty = red_duty_reg;
  assign blue_duty = blue_duty_reg;
  assign green_duty = green_duty_reg;

  assign rgb[0] = pwm_out_red;
  assign rgb[1] = pwm_out_blue;
  assign rgb[2] = pwm_out_green;

endmodule
