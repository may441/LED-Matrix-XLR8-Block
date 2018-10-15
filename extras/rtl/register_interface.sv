module register_interface
#(
	parameter CTRL_ADDR = 0,
	parameter SEL_ROW_ADDR = CTRL_ADDR+1,
	parameter SEL_COL_ADDR = CTRL_ADDR+2,
	parameter R_ADDR = CTRL_ADDR+3,
	parameter G_ADDR = CTRL_ADDR+4,
	parameter B_ADDR = CTRL_ADDR+5,
	parameter ADDR_WIDTH = 8, //Length of processor interface addresses
	parameter DATA_WIDTH = 8, //log2 of Resolution of PWM signal
	parameter ROW_LENGTH = 7, //log2 of MATRIX_WIDTH
	parameter COLUMN_LENGTH = 6, //log2 of MATRIX_HEIGHT
	parameter INTERFACE_WIDTH = 3*DATA_WIDTH //R,G,B register length. Should be 3*DATA_WIDTH
	
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

	output wire enable,
	output wire [ROW_LENGTH-1:0] proc_ctrl_row, //Processor row access interface
	output wire [COLUMN_LENGTH-1:0] proc_ctrl_column, //Processor column access interface
	output wire proc_ctrl_we, //Writes value in proc_ctrl_data_i to current accessed pixel
	output wire [INTERFACE_WIDTH-1:0] proc_ctrl_data_i, //Input register
	input wire [INTERFACE_WIDTH-1:0] proc_ctrl_data_o //output register

);
	
reg[7:0] status_reg;
reg[7:0] status_reg_n;

reg[7:0] sel_row_reg;
reg[7:0] sel_row_reg_n;

reg[7:0] sel_col_reg;
reg[7:0] sel_col_reg_n;

reg[7:0] color_reg_r;
reg[7:0] color_reg_r_n;

reg[7:0] color_reg_g;
reg[7:0] color_reg_g_n;

reg[7:0] color_reg_b;
reg[7:0] color_reg_b_n;

wire status_reg_sel;
wire sel_row_sel;
wire sel_col_sel;
wire color_reg_r_sel;
wire color_reg_g_sel;
wire color_reg_b_sel;

wire curr_r_val;
wire curr_g_val;
wire curr_b_val;

assign curr_r_val = proc_ctrl_data_o[DATA_WIDTH-1:0];
assign curr_g_val = proc_ctrl_data_o[2*DATA_WIDTH-1:DATA_WIDTH];
assign curr_b_val = proc_ctrl_data_o[3*DATA_WIDTH-1:DATA_WIDTH];

assign proc_ctrl_data_i = {color_reg_b, color_reg_g, color_reg_r};
assign proc_ctrl_we = status_reg[1];
assign enable = status_reg[0];

assign status_reg_sel = ramadr == CTRL_ADDR;
assign sel_row_sel = ramadr == SEL_ROW_ADDR;
assign sel_col_sel = ramadr == SEL_COL_ADDR;
assign color_reg_r_sel = ramadr == R_ADDR;
assign color_reg_g_sel = ramadr == G_ADDR;
assign color_reg_b_sel = ramadr == B_ADDR;

assign dbus_out = ({8{status_reg_sel}} & status_reg) |
						({8{sel_row_sel}} & sel_row_reg) |
						({8{sel_col_sel}} & sel_col_reg) |
						({8{color_reg_r_sel}} & curr_r_val) |
						({8{color_reg_g_sel}} & curr_g_val) |
						({8{color_reg_b_sel}} & curr_b_val);
						
assign io_out_en = (status_reg_sel || sel_row_sel || sel_col_sel || color_reg_r_sel || color_reg_g_sel || color_reg_b_sel) && ramre;

always_ff @(posedge clk, negedge n_rst)
begin
	if(n_rst == 1'b0)
	begin
		status_reg <= 8'h01;
		color_reg_r <= 8'h00;
		color_reg_g <= 8'h00;
		color_reg_b <= 8'h00;		
		sel_row_reg <= 8'h00;
		sel_col_reg <= 8'h00;
	end
	else
	begin
		sel_row_reg <= sel_row_reg_n;
		sel_col_reg <= sel_col_reg_n;
		status_reg <= status_reg_n;
		color_reg_r <= color_reg_r_n;
		color_reg_g <= color_reg_g_n;
		color_reg_b <= color_reg_b_n;			
	end
end

always_comb
begin
	status_reg_n = status_reg;
	status_reg_n[1] = 1'b0; //Always clear write bit
	if(status_reg_sel==1'b1 && ramwe==1'b1)
		status_reg_n = dbus_in;
end

always_comb
begin
	sel_row_reg_n = sel_row_reg;
	if(sel_row_sel==1'b1 && ramwe==1'b1)
		sel_row_reg_n = dbus_in;
end

assign proc_ctrl_row = sel_row_reg;

always_comb
begin
	sel_col_reg_n = sel_col_reg;
	if(sel_col_sel==1'b1 && ramwe==1'b1)
		sel_col_reg_n = dbus_in;
end

assign proc_ctrl_column = sel_col_reg;

always_comb
begin
	color_reg_r_n = color_reg_r;
	if(color_reg_r_sel==1'b1 && ramwe==1'b1)
		color_reg_r_n = dbus_in;
end

always_comb
begin
	color_reg_g_n = color_reg_g;
	if(color_reg_g_sel==1'b1 && ramwe==1'b1)
		color_reg_g_n = dbus_in;
end

always_comb
begin
	color_reg_b_n = color_reg_b;
	if(color_reg_b_sel==1'b1 && ramwe==1'b1)
		color_reg_b_n = dbus_in;
end


endmodule
