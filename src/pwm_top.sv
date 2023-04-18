module pwm_top(
    input logic clk,
    input logic reset,
    input logic [3:0] sw,
    output logic [2:0] rgb,
    output logic servo
  );

  logic [2:0] linear_out;
  logic [2:0] sine_out;
  logic [2:0] rainbow_out;
  logic [2:0] rgb_reg;
  logic servo_out;
  //logic servo_reg;

  linear_pwm pwm_prt0 (.clk(clk),.reset(reset),.rgb(linear_out));
  pwm_sine pwm_prt1 (.clk(clk),.reset(reset),.rgb(sine_out));
  pwm_servo pwm_prt2 (.clk(clk),.reset(reset),.servo(servo_out));
  pwm_rainbow pwm_prt3 (.clk(clk),.reset(reset),.rgb(rainbow_out));

  always_ff @ (posedge clk, posedge reset)
  begin
    if (reset) begin
        rgb_reg = 3'b0;
    end
    else begin
        if (sw == 4'b0001) begin
            rgb_reg = linear_out;
        end
        else if (sw == 4'b0010) begin
            rgb_reg = sine_out;
        end
        // else if (sw == 4'b0100) begin
        //     servo_reg = servo_out;
        // end
        else if (sw == 4'b1000) begin
            rgb_reg = rainbow_out;
        end
        else begin
            rgb_reg = 3'b0;

        end
    end
  end

assign rgb = rgb_reg;
assign servo = (sw == 4'b0100) ? servo_out : 0;

endmodule