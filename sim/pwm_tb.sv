`timescale 1ns / 1ps

module pwm_tb();

logic clk;
logic reset;
logic [2:0] rgb;

parameter CP = 8;

pwm_sine pwm_uut (.clk(clk),.reset(reset),.rgb(rgb));

  // Process made to toggle the clock every 5ns.
always
begin
  clk <= 1'b1;
  #(CP/2);
  clk <= 1'b0;
  #(CP/2);
end

// Simulation Inputs.
initial begin
    reset = 1'b1;
    #CP
    reset = 1'b0;
end

endmodule
