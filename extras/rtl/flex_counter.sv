// $Id: $
// File name:   flex_counter.sv
// Created:     1/28/2017
// Author:      Patrick May
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: Flexible counter
module flex_counter 
#(
NUM_CNT_BITS = 4
)
(
input clk,
input n_rst,
input clear,
input count_enable,
input [NUM_CNT_BITS-1:0]rollover_val,
output reg [NUM_CNT_BITS-1:0]count_out,
output reg rollover_flag 
);
//Counter from comb to ff
reg [NUM_CNT_BITS-1:0]count_in;
reg rollover_in;

always_ff @ (posedge clk, negedge n_rst)
begin
	if (n_rst == 1'b0)
	begin
		count_out <= '0;
		rollover_flag <= 1'b0;	
	end
	else
	begin
		count_out <= count_in;
		rollover_flag <= rollover_in;
	end

end
 
always_comb
begin
	if (clear == 1'b1)
	begin
		count_in = '0;
		rollover_in = '0;
	end
	else
	begin
		if(count_enable)
		begin
			//Check if we need to reset counter
			if(count_out == rollover_val)
			begin
				count_in = '0;
				count_in[0] = 1'b1;
			end
			else
			count_in = count_out + 1;

			//Check if we need to set rollover
			if (count_in == rollover_val)
			rollover_in = 1;
			else
			rollover_in = 0;
			
		end
		else
		begin
			count_in = count_out;
			rollover_in = rollover_flag;
		end
	end
end

endmodule
