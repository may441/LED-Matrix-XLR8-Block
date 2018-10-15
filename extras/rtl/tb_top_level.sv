`timescale 1ns/1ns

module tb_top_level();

   logic clk;
   logic n_rst;
   integer test_no;
   logic [7:0]  dbus_in; //   Data Bus logic
   logic [7:0] dbus_out; //  Data Bus 
   logic       io_out_en; // IO  Enable
   // DM
   logic [7:0]  ramadr; //    RAM Address
   logic        ramre; //     RAM Read Enable
   logic        ramwe; //     RAM Write Enable
   logic        dm_sel; //    DM Select

    logic clk_out; 
    logic r1;      
    logic r2;      
    logic b1;      
    logic b2;      
    logic g1;      
    logic g2;      
    logic[3:0] multi;
    logic latch_SR;

    always #5 clk = ~clk;

top_level my_top_level(
    .clk(clk),
    .n_rst(n_rst),
	
    .dbus_in(dbus_in), //   Data Bus 
    .dbus_out(dbus_out), //  Data Bus 
    .io_out_en(io_out_en), // IO  Enable
   // DM
     .ramadr(ramadr), //    RAM Address
     .ramre(ramre), //     RAM Read Enable
     .ramwe(ramwe), //     RAM Write Enable
     .dm_sel(dm_sel), //    DM Select

     .clk_out(clk_out), 
     .r1(r1),      
     .r2(r2),      
     .b1(b1),      
     .b2(b2),      
     .g1(g1),      
     .g2(g2),      
     .a(multi[0]),       
     .b(multi[1]),       
     .c(multi[2]),
     .d(multi[3]),
     .latch_SR(latch_SR)        
);

task set_reg;
	input[7:0] reg_addr;
	input[7:0] reg_val;
begin
	ramadr = reg_addr;
	dbus_in = reg_val;
	#10
	ramwe = 1'b1;
	#10
	ramwe = 1'b0;
	#10
	ramwe = 1'b0;
end
endtask

task set_led;
	input [7:0]row;
	input [7:0]col;
	input [7:0]r_val;
	input [7:0]g_val;
	input [7:0]b_val;
begin
	set_reg(1,row);
	set_reg(2,col);
	set_reg(3,r_val);
	set_reg(4,g_val);
	set_reg(5,b_val);
	set_reg(0,3);	
end
endtask
initial
begin
ramwe = 1'b0;
clk = 1'b0;
n_rst = 1'b1;
test_no = 0;
//io_out_en = 1'b0;
dm_sel = 1'b0;
ramre = 1'b0;
//Reset
n_rst = 1'b0;
#10
n_rst = 1'b1;

//Test 1: Set bit
set_led(0,20,127,127,127);
//set_led(0,30,0,127,0);
//set_led(0,10,0,0,127);
//set_led(4,40,127,0,0);
//set_led(8,40,127,0,0);

//TODO hook up parallel ports and test those 
//TODO test read interface
//TODO test 

end

endmodule 