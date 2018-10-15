`timescale 1ns/1ns
module tb_matrix_memory();

parameter MATRIX_WIDTH = 64; //Number of columns in pixels
parameter MATRIX_HEIGHT = 32; //Number of rows in pixels
parameter ADDR_WIDTH = 8; //Length of processor interface addresses
parameter DATA_WIDTH = 8; //log2 of Resolution of PWM signal

parameter ROW_LENGTH = 7; //log2 of MATRIX_WIDTH
parameter COLUMN_LENGTH = 6; //log2 of MATRIX_HEIGHT
parameter INTERFACE_WIDTH = 3*DATA_WIDTH; //R;G,B logicister length. Should be 3*DATA_WIDTH
parameter SCAN_VAL_LENGTH = 5; //Log2 of the LED panel scan sizelogic [4:0]testNo;

logic clk;
logic n_rst;
integer test_no;
integer i;


logic [ROW_LENGTH-1:0] proc_ctrl_row; //Processor row access interface
logic [COLUMN_LENGTH-1:0] proc_ctrl_col; //Processor column access interface
logic proc_ctrl_we; //Writes value in proc_ctrl_data_i to current accessed pixel
logic [INTERFACE_WIDTH-1:0] proc_ctrl_data_i; //Input logicister
logic [INTERFACE_WIDTH-1:0] proc_ctrl_data_o; //output logicister

logic [SCAN_VAL_LENGTH-1:0] scan_val; //Current row to be shifted in
logic [DATA_WIDTH-1:0] current_bcm_bit; //Current bit requested for bcm
	
logic [MATRIX_WIDTH-1:0] pwm_data_ra; //Bits to be shifted into LEDs
logic [MATRIX_WIDTH-1:0] pwm_data_rb; //Each SR corresponds to a row
logic [MATRIX_WIDTH-1:0] pwm_data_ba;
logic [MATRIX_WIDTH-1:0] pwm_data_bb;
logic [MATRIX_WIDTH-1:0] pwm_data_ga;
logic [MATRIX_WIDTH-1:0] pwm_data_gb;


matrix_memory #(.MATRIX_WIDTH(MATRIX_WIDTH), //Number of columns in pixels
.MATRIX_HEIGHT(MATRIX_HEIGHT), //Number of rows in pixels
.ADDR_WIDTH(ADDR_WIDTH), //Length of processor interface addresses
.DATA_WIDTH(ADDR_WIDTH), //log2 of Resolution of PWM signal
.ROW_LENGTH(ROW_LENGTH), //log2 of MATRIX_WIDTH
.COLUMN_LENGTH(COLUMN_LENGTH), //log2 of MATRIX_HEIGHT
.INTERFACE_WIDTH(INTERFACE_WIDTH), //R,G,B register length. Should be 3*DATA_WIDTH
.SCAN_VAL_LENGTH(SCAN_VAL_LENGTH) //Log2 of the LED panel scan size
) mem_module
(
	.clk(clk),
	.n_rst(n_rst),
	
	.proc_ctrl_row(proc_ctrl_row), //Processor row access interface
	.proc_ctrl_col(proc_ctrl_col), //Processor column access interface
	.proc_ctrl_data_i(proc_ctrl_data_i), //Input register
	.proc_ctrl_data_o(proc_ctrl_data_o), //output register
	.proc_ctrl_we(proc_ctrl_we),
	.scan_val(scan_val), //Current row to be shifted in
	.current_bcm_bit(current_bcm_bit), //Current bit requested for bcm
	
	.pwm_data_ra(pwm_data_ra), //Bits to be shifted into LEDs
	.pwm_data_rb(pwm_data_rb), //Each SR corresponds to a row
	.pwm_data_ba(pwm_data_ba),
	.pwm_data_bb(pwm_data_bb),
	.pwm_data_ga(pwm_data_ga),
	.pwm_data_gb(pwm_data_gb)
);

always #20 clk = ~clk;

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

proc_ctrl_row = 'b0;
proc_ctrl_col = 'b0;
proc_ctrl_data_i = 'b0;
proc_ctrl_we =  'b0;
scan_val = 'b0;
current_bcm_bit = 'b0;

#5
//Data store test
test_no = 1;
proc_ctrl_row = 5;
proc_ctrl_col = 2;
proc_ctrl_data_i = 24'h010204;

#5
proc_ctrl_we =1'b1;
#10
proc_ctrl_we =1'b0;

//Data retrieve test
test_no = 2;
scan_val = 5;
current_bcm_bit = 'd0;
for(i = 0; i < DATA_WIDTH; i++)
begin
	#10
	current_bcm_bit = i;
end
end

endmodule 