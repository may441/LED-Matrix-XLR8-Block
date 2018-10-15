module LEDdriver_old
#( parameter MATRIX_WIDTH = 64, //Number of columns in pixels
parameter MATRIX_HEIGHT = 32, //Number of rows in pixels
parameter DATA_WIDTH = 8, //log2 of Resolution of PWM signal
parameter MUX_LENGTH = 4, //Length of mux
parameter WAIT_COUNT_LENGTH = 18, //log2 of 2^(current_BCM_Bit-1)*MATRIX_WIDTH*MATRIX_HEIGHT/2
parameter ROW_LENGTH = 7, //log2 of MATRIX_WIDTH
parameter SCAN_VAL_LENGTH = 5
)
(
	input wire clk,
	input wire n_rst,
	input wire enable,
	
	output wire [SCAN_VAL_LENGTH-1:0] scan_val,
	output reg [DATA_WIDTH-1:0] current_bcm_bit,
	output reg [MUX_LENGTH-1:0] mux_val,
	input wire shift_reg_empty,
	output reg clk_out,
	output reg latch_SR,
	output reg sr_enable,
	output reg latch_pts,
	output reg oe
	
);

//State machine enums
typedef enum {IDLE, INIT_SR, SHIFT_OUT,LATCH_VALS, INC_SCAN_VAL} line_loading_states;
typedef enum {DISABLED, INC_PCM, CHANGE_INTERLEAVE, LOAD_LED_VALS, LOAD_LED_VALS_WAIT, PCM_WAIT} bit_loading_states;

//State machine declarations
line_loading_states line_state;
line_loading_states line_state_n;

bit_loading_states bit_loader;
bit_loading_states bit_loader_n;

//Scan value next state
reg [SCAN_VAL_LENGTH-1:0] scan_val_raw;
reg [SCAN_VAL_LENGTH-1:0] scan_val_raw_n;
reg [DATA_WIDTH-1:0]current_bcm_bit_n;

//Row determination logic
reg scan_odd_vals;
reg scan_odd_vals_n;

//Next state for output enable
reg oe_n;

assign scan_val = scan_val_raw + scan_odd_vals;
assign mux_val = scan_val[MUX_LENGTH-1:0];

//Timer counter
reg timer_enable;
reg count_clear;
reg [DATA_WIDTH-1:0][WAIT_COUNT_LENGTH-1:0] wait_count_desired_val;
reg [WAIT_COUNT_LENGTH-1:0] timer_count_out;
wire timer_finished;

//Timer for PCM pulse modulation
flex_counter #(.NUM_CNT_BITS(WAIT_COUNT_LENGTH)) bit_loader_ctr(.clk(clk),.n_rst(n_rst),.clear(count_clear),.count_enable(timer_enable),.count_out(timer_count_out));

reg [ROW_LENGTH-1:0] sr_count_out;

//OE logic


//Generate wait values
genvar i;
generate
	for(i = 0; i < DATA_WIDTH+1; i = i + 1) 
	begin : genDesVal
			assign wait_count_desired_val[i] = (2**(i-1))*MATRIX_WIDTH*MATRIX_HEIGHT/2;
	end
endgenerate

//Timer finished logic
assign timer_finished = (timer_count_out >= wait_count_desired_val[current_bcm_bit]);

//always_ff @(posedge clk or negedge n_rst or negedge clk) begin
//	if(n_rst == 1'b0) begin
//		inv_clk = 1'b1;
//	end
//	else if(clk == 1'b1) begin
//		inv_clk = 1'b0;
//	end
//	else begin
//		inv_clk = 1'b1;
//	end
//end

//State machine current state logic
always_ff @(posedge clk or negedge n_rst) begin
	if(n_rst == 1'b0)
	begin
		line_state <= IDLE;
		bit_loader <= DISABLED;
		scan_val_raw <= 'b0;
		scan_odd_vals <= 'b0;
		current_bcm_bit <= 'b0;
		oe <= 'b0;
	end
	else
	begin
		line_state <= line_state_n;
		bit_loader <= bit_loader_n;
		scan_val_raw <= scan_val_raw_n;
		scan_odd_vals <= scan_odd_vals_n;
		current_bcm_bit <= current_bcm_bit_n;
		oe <= oe_n;
	end
end

//Line next state logic
always_comb begin
	line_state_n = line_state;
	latch_pts = 1'b0;
	clk_out = 1'b0;
	sr_enable = 1'b0;
	scan_val_raw_n = scan_val_raw;
	latch_SR = 1'b0;
	oe_n = 1'b1;
	case(line_state)
		IDLE:begin
			if((bit_loader == LOAD_LED_VALS)) begin line_state_n = INIT_SR; end
			scan_val_raw_n = 'b0;
			oe_n = 1'b0;
		end
		INIT_SR:begin
			line_state_n = SHIFT_OUT;
			latch_pts = 1'b1;
		end
		SHIFT_OUT:begin
			if(shift_reg_empty == 1'b1) begin line_state_n = LATCH_VALS; end
			clk_out = ~clk;
			sr_enable = 1'b1;
		end
		LATCH_VALS:begin
			line_state_n = INC_SCAN_VAL;
			latch_SR = 1'b1;
		end
		INC_SCAN_VAL:begin
			scan_val_raw_n = scan_val_raw + 2;
			if(scan_val_raw_n == MATRIX_HEIGHT/2) begin line_state_n = IDLE; end
			else begin line_state_n = INIT_SR; end
		end
	endcase
end

//Bit next state logic
always_comb begin
	bit_loader_n = bit_loader;
	current_bcm_bit_n = current_bcm_bit;	
	scan_odd_vals_n = scan_odd_vals;
	timer_enable = 1'b0;
	count_clear = 1'b0;
	
	case(bit_loader)
		DISABLED:begin
			if(enable == 1'b1) begin bit_loader_n = LOAD_LED_VALS; end
		end
		INC_PCM:begin
			bit_loader_n = LOAD_LED_VALS;
			current_bcm_bit_n = current_bcm_bit + 1;
			if(current_bcm_bit == DATA_WIDTH) begin 
			current_bcm_bit_n = 0; 
			bit_loader_n = CHANGE_INTERLEAVE;
			end
		end
		CHANGE_INTERLEAVE:begin
			bit_loader_n = LOAD_LED_VALS;
			scan_odd_vals_n = ~scan_odd_vals;
		end
		LOAD_LED_VALS:begin
			bit_loader_n = LOAD_LED_VALS_WAIT;
			count_clear = 1'b1;
		end
		LOAD_LED_VALS_WAIT:begin
		bit_loader_n = LOAD_LED_VALS_WAIT;
		if ((current_bcm_bit == 0)&&(line_state == IDLE)) 
			begin 
				bit_loader_n = INC_PCM;
			end
			else if ((current_bcm_bit != 0)&&(line_state == IDLE)) 
			begin 
				bit_loader_n = PCM_WAIT;
			end
		
		end
		PCM_WAIT:begin
			timer_enable = 'b1;
			if(timer_finished == 'b1) begin bit_loader_n = INC_PCM; end
		end
	endcase
	
	if(enable == 1'b0)
	begin
		bit_loader_n = DISABLED;
	end
end

endmodule
