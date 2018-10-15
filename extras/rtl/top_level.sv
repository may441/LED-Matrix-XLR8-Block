module top_level 
#(parameter BASE_ADDR = 0,

parameter MATRIX_WIDTH = 64, //Number of columns in pixels
parameter MATRIX_HEIGHT = 32, //Number of rows in pixels
parameter ADDR_WIDTH = 8, //Length of processor interface addresses
parameter DATA_WIDTH = 8, //log2 of Resolution of PWM signal

parameter ROW_LENGTH = 7, //log2 of MATRIX_WIDTH
parameter COLUMN_LENGTH = 6, //log2 of MATRIX_HEIGHT
parameter INTERFACE_WIDTH = 3*DATA_WIDTH, //R,G,B register length. Should be 3*DATA_WIDTH
parameter SCAN_VAL_LENGTH = 5, //Log2 of the LED panel scan size
parameter MUX_LENGTH = 4, //Length of mux
parameter WAIT_COUNT_LENGTH = 17 //log2 of 2^(current_PCM_Bit-1)*MATRIX_WIDTH*MATRIX_HEIGHT/2
)
(
	input clk,
	input n_rst,
	
   input [7:0]  dbus_in, //   Data Bus Input
   output [7:0] dbus_out, //  Data Bus Output
   output       io_out_en, // IO Output Enable
   // DM
   input [7:0]  ramadr, //    RAM Address
   input        ramre, //     RAM Read Enable
   input        ramwe, //     RAM Write Enable
   input        dm_sel, //    DM Select

   output wire clk_out, 
   output wire r1,      
   output wire r2,      
   output wire b1,      
   output wire b2,      
   output wire g1,      
   output wire g2,      
   output wire a,       
   output wire b,       
   output wire c,
	output wire d,
	output wire oe,
   output wire latch_SR        
);

wire [ROW_LENGTH-1:0] proc_ctrl_row; //Processor row access interface
wire [COLUMN_LENGTH-1:0] proc_ctrl_column; //Processor column access interface
wire proc_ctrl_we; //Writes value in proc_ctrl_data_i to current accessed pixel
wire [INTERFACE_WIDTH-1:0] proc_ctrl_data_i; //Input register
wire [INTERFACE_WIDTH-1:0] proc_ctrl_data_o; //output register
wire shift_reg_empty;
wire [SCAN_VAL_LENGTH-1:0] scan_val; //Current row to be shifted in
wire [DATA_WIDTH-1:0] current_bcm_bit; //Current bit requested for bcm

wire [MUX_LENGTH-1:0] mux_val;
wire sr_enable;
wire latch_pts;
wire enable;

wire[3:0] timer_count_out;
wire clk_div2;
wire clk_div4;
wire clk_div8;
wire clk_div16;

assign a = mux_val[0];
assign b = mux_val[1];
assign c = mux_val[2];
assign d = mux_val[3];
	 
	 
//flex_counter #(.NUM_CNT_BITS(4)) clk_div_ctr(.clk(clk),.n_rst(n_rst),.clear(1'b0),.count_enable(1'b1),.count_out(timer_count_out));

//assign clk_div2 = timer_count_out[0];
//assign clk_div4 = timer_count_out[1];
//assign clk_div8 = timer_count_out[2];
//assign clk_div16 = timer_count_out[3];

register_interface #(.CTRL_ADDR(BASE_ADDR)) reg_intf 
(
	.clk(clk),
	.n_rst(n_rst),
   .dbus_in(dbus_in), //   Data Bus Input
   .dbus_out(dbus_out), //  Data Bus Output
   .io_out_en(io_out_en), // IO Output Enable
   
   .ramadr(ramadr), //    RAM Address
   .ramre(ramre), //     RAM Read Enable
   .ramwe(ramwe), //     RAM Write Enable
   .dm_sel(dm_sel), //    DM Select

	.enable(enable),
	.proc_ctrl_row(proc_ctrl_row), //Processor row access interface
	.proc_ctrl_column(proc_ctrl_column), //Processor column access interface
	.proc_ctrl_we(proc_ctrl_we), //Writes value in proc_ctrl_data_i to current accessed pixel
	.proc_ctrl_data_i(proc_ctrl_data_i), //Input register
	.proc_ctrl_data_o(proc_ctrl_data_o) //output register

);
matrix_memory mem_module
(
	.clk(clk),
	.n_rst(n_rst),
	.shift_reg_empty(shift_reg_empty),
	.proc_ctrl_row(proc_ctrl_row), //Processor row access interface
	.proc_ctrl_col(proc_ctrl_column), //Processor column access interface
	.proc_ctrl_data_i(proc_ctrl_data_i), //Input register
	.proc_ctrl_data_o(proc_ctrl_data_o), //output register
	.proc_ctrl_we(proc_ctrl_we),
	.scan_val(scan_val), //Current row to be shifted in
	.current_bcm_bit(current_bcm_bit), //Current bit requested for bcm
	.shift_en(sr_enable),
	.pwm_data_ra(r1), //Bits to be shifted into LEDs
	.pwm_data_rb(r2), //Each SR corresponds to a row
	.pwm_data_ba(b1),
	.pwm_data_bb(b2),
	.pwm_data_ga(g1),
	.pwm_data_gb(g2)
);

LEDdriver driverController
(
	.clk(clk),
	.n_rst(n_rst),
	.enable(enable),
	
	.oe(oe),
	.scan_val(scan_val),
	.current_bcm_bit(current_bcm_bit),
	.mux_val(mux_val),
	.clk_out(clk_out),
	.latch_SR(latch_SR),
	.sr_enable(sr_enable),
	.latch_pts(latch_pts),
	.shift_reg_empty(shift_reg_empty)
);

endmodule
