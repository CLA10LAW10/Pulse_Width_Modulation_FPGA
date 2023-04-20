`timescale 1ns / 1ps

module pwm_tb();

  logic clk;
  logic reset;
  logic [3:0] sw;
  logic [2:0] rgb;
  logic servo;

  parameter CP = 8;

  pwm_top pwm_uut (.clk(clk),.reset(reset),.sw(sw),.rgb(rgb),.servo(servo));
  //pwm_rainbow pwm_uut (.clk(clk),.reset(reset),.rgb(rgb));
  //pwm_servo pwm_uut (.clk(clk),.reset(reset),.servo(servo));
  //pwm_sine pwm_uut (.clk(clk),.reset(reset),.rgb(rgb));
  //linear_pwm pwm_uut (.clk(clk),.reset(reset),.rgb(rgb));



  // Process made to toggle the clock every 5ns.
  always
  begin
    clk <= 1'b1;
    #(CP/2);
    clk <= 1'b0;
    #(CP/2);
  end

  // Simulation Inputs.
  initial
  begin
    sw = 4'b0000;
    reset = 1'b1;
    #(CP*10);
    reset = 1'b0;
    #CP;

    //#(CP*10)

    // reset = 1'b1;
    // #(CP*10)
    //  reset = 1'b0;
    // #CP

    // sw = 4'b0001;
    // #(CP*1_250_000);

    // sw = 4'b0010;
    // #(CP*200_000_000);

    //  sw = 4'b0100;
    //#(CP*1_250_000)

     sw = 4'b1000;
    #(CP*1_250_000);

    //$finish;
  end

endmodule
