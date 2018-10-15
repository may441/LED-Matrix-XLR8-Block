module tb_LEDDriver();

parameter MATRIX_WIDTH = 64; //Number of columns in pixels
parameter MATRIX_HEIGHT = 32; //Number of rows in pixels
parameter DATA_WIDTH = 8; //log2 of Resolution of PWM signal
parameter MUX_LENGTH = 4; //Length of mux
parameter WAIT_COUNT_LENGTH = 17; //log2 of 2^(current_BCM_Bit-1)*MATRIX_WIDTH*MATRIX_HEIGHT/2
parameter ROW_LENGTH = 7; //log2 of MATRIX_WIDTH
parameter SCAN_VAL_LENGTH = 5;

logic clk;
logic n_rst;
integer test_no;

logic enable;
logic [SCAN_VAL_LENGTH-1:0] scan_val;
logic [DATA_WIDTH-1:0] current_bcm_bit;
logic [MUX_LENGTH-1:0] mux_val;
logic clk_out;
logic latch_SR;
logic sr_enable;
logic latch_pts;

always #5 clk = ~clk;


LEDdriver driverController
(
	.clk(clk),
	.n_rst(n_rst),
	.enable(enable),
	
	.scan_val(scan_val),
	.current_bcm_bit(current_bcm_bit),
	.mux_val(mux_val),
	.clk_out(clk_out),
	.latch_SR(latch_SR),
	.sr_enable(sr_enable),
	.latch_pts(latch_pts)
);


initial 
begin
clk = 1'b0;
n_rst = 1'b1;
test_no = 0;
//Reset
#1
n_rst = 1'b0;
#1
n_rst = 1'b1;

//Enable, should automatically send outputs
enable = 1'b1;

//See what it does ??
end

endmodule
