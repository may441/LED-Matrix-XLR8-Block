///////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright (c) Alorium Technology 2016
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : xlr8_wrap_template.v
// Author      : Steve Phillips
// Description : Template for wrapping user XB in glue logic needed
//               to interface cleanly with AVR core
//
// This template module provides an starting point for the user to
// enable thier module to communicate cleanly with the AVR core. The
// AVR core provides a relatively simple, standard interface which
// must be adhered to in order to interoperate cleanly.
//
// 
//=================================================================
///////////////////////////////////////////////////////////////////

module xlr8_xb_LEDDriver  // NOTE: Change the module name to match your design
  #(
    parameter CTRL_ADDR = 0
    )
   (
    // Input/Ouput definitions for the module. These are standard and
    // while other ports could be added, these are required.
    //  
    // Clock and Reset
    input        clk, //       Clock
    input        rstn, //      Reset
    input        clken, //     Clock Enable
    // I/O 
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
    output wire latch_SR,
    output wire oe
    );
   
top_level #(.BASE_ADDR(CTRL_ADDR)) LEDDriverModule
(
	.clk(clk),
	.n_rst(rstn),
	.dbus_in(dbus_in), //   Data Bus Input
	.dbus_out(dbus_out), //  Data Bus Output
	.io_out_en(io_out_en), // IO Output Enable
	
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
   .a(a),       
   .b(b),       
   .c(c),
	.d(d),
   .latch_SR(latch_SR),
	.oe(oe)
);

endmodule

