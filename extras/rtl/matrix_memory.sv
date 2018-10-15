module matrix_memory
#(parameter MATRIX_WIDTH = 64, //Number of columns in pixels
parameter MATRIX_HEIGHT = 32, //Number of rows in pixels
parameter ADDR_WIDTH = 8, //Length of processor interface addresses
parameter DATA_WIDTH = 8, //log2 of Resolution of PWM signal

parameter ROW_LENGTH = 7, //log2 of MATRIX_WIDTH
parameter COLUMN_LENGTH = 6, //log2 of MATRIX_HEIGHT
parameter INTERFACE_WIDTH = 3*DATA_WIDTH, //R,G,B register length. Should be 3*DATA_WIDTH
parameter SCAN_VAL_LENGTH = 5 //Log2 of the LED panel scan size
)
(
	input clk,
	input n_rst,
	
	input reg [ROW_LENGTH-1:0] proc_ctrl_row, //Processor row access interface
	input reg [COLUMN_LENGTH-1:0] proc_ctrl_col, //Processor column access interface
	input wire proc_ctrl_we, //Writes value in proc_ctrl_data_i to current accessed pixel
	input reg [INTERFACE_WIDTH-1:0] proc_ctrl_data_i, //Input register
	output reg [INTERFACE_WIDTH-1:0] proc_ctrl_data_o, //output register
	output wire shift_reg_empty,
	input wire [SCAN_VAL_LENGTH-1:0] scan_val, //Current row to be shifted in
	input wire [DATA_WIDTH-1:0] current_bcm_bit, //Current bit requested for bcm
	input wire shift_en,
	
	output wire pwm_data_ra, //Bits to be shifted into LEDs
	output wire pwm_data_rb, //Each SR corresponds to a row
	output wire pwm_data_ba,
	output wire pwm_data_bb,
	output wire pwm_data_ga,
	output wire pwm_data_gb

);

//Define status registers
wire [9:0] read_address;
wire [9:0] write_address_upper;
wire [9:0] write_address_lower;
wire [INTERFACE_WIDTH-1:0] rd_data_upper;
wire [INTERFACE_WIDTH-1:0] rd_data_lower;
wire addr_valid_upper;
wire addr_valid_lower;
wire [ROW_LENGTH-1:0] current_count;
reg shift_en_last;
wire clear_counter;

assign write_address_upper = proc_ctrl_row * MATRIX_WIDTH + proc_ctrl_col;
assign write_address_lower = proc_ctrl_row * MATRIX_WIDTH + proc_ctrl_col - (MATRIX_WIDTH * MATRIX_HEIGHT/2);
assign addr_valid_upper = (proc_ctrl_row < MATRIX_HEIGHT/2) && (proc_ctrl_col < MATRIX_WIDTH);
assign addr_valid_lower = (proc_ctrl_row >= MATRIX_HEIGHT/2) && (proc_ctrl_col < MATRIX_WIDTH) && (proc_ctrl_row < MATRIX_HEIGHT);
assign wr_en_upper = proc_ctrl_we && addr_valid_upper;
assign wr_en_lower = proc_ctrl_we && addr_valid_lower;

assign read_address = scan_val * MATRIX_WIDTH + current_count; 
assign proc_ctrl_data_o = 'b0;

always_ff @(posedge clk or negedge n_rst) begin
	if(n_rst == 1'b0) begin
		shift_en_last <= 1'b1;
	end
	else begin
		shift_en_last <= shift_en;
	end
end


assign clear_counter = shift_en_last && !shift_en; //Clear val on falling edge

flex_counter #(.NUM_CNT_BITS(ROW_LENGTH)) shift_counter (
	.clk(clk),
	.n_rst(n_rst),
	.clear(clear_counter),
	.count_enable(shift_en),
	.rollover_val(MATRIX_WIDTH),
	.count_out(current_count),
	.rollover_flag(shift_reg_empty)
);

//Shift register vectors
assign	pwm_data_ra = rd_data_upper[current_bcm_bit];
assign	pwm_data_ga = rd_data_upper[current_bcm_bit+DATA_WIDTH];
assign	pwm_data_ba = rd_data_upper[current_bcm_bit+2*DATA_WIDTH];
assign	pwm_data_rb = rd_data_lower[current_bcm_bit];
assign	pwm_data_gb = rd_data_lower[current_bcm_bit+DATA_WIDTH];
assign	pwm_data_bb = rd_data_lower[current_bcm_bit+2*DATA_WIDTH];

colorRamConfig mem_array_upper (
	.clock(clk),
	.data(proc_ctrl_data_i),
	.rdaddress(read_address),
	.wraddress(write_address_upper),
	.wren(wr_en_upper),
	.q(rd_data_upper)
	);

colorRamConfig mem_array_lower (
	.clock(clk),
	.data(proc_ctrl_data_i),
	.rdaddress(read_address),
	.wraddress(write_address_lower),
	.wren(wr_en_lower),
	.q(rd_data_lower)
	);

	
endmodule

