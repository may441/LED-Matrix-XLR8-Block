// $Id: $
// File name:   flex_pts_sr.sv
// Created:     1/26/2017
// Author:      Patrick May
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Serial to parallel converter
module flex_pts_sr
#(
parameter NUM_BITS = 64,
parameter SHIFT_MSB = 0,
parameter IDLE_BIT = 0
)
(
	input clk,
	input n_rst,
	input shift_enable,
	input load_enable,
	input [NUM_BITS-1:0]parallel_in,
	output reg serial_out
);

	reg [NUM_BITS-1:0]currentReg; //State register
	reg [NUM_BITS-1:0]futureReg; //Next state register


//Combinatorial circuit
always_comb
begin
	if(SHIFT_MSB == 1'b0)
		serial_out = currentReg[0];
	else
		serial_out = currentReg[NUM_BITS-1];

	if(load_enable)
		futureReg = parallel_in;
	else
	begin
		if(shift_enable == 1'b1)
		begin
			if(SHIFT_MSB == 1'b1)
			futureReg = {currentReg[NUM_BITS-2:0],IDLE_BIT};
			else
			futureReg = {IDLE_BIT, currentReg[NUM_BITS-1:1]};
		end
		else
		futureReg = currentReg;
	end
end

//Flip flop
always_ff @ (posedge clk, negedge n_rst)
begin
	if(n_rst == 0)
	currentReg <= IDLE_BIT;
	else
	currentReg <= futureReg;
end

endmodule 