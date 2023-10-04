///////////////////////////////////////////////
// File:          apb_top.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB top file 
/////////////////////////////////////////////////

//
// Top module Description:
//
//
`include "apb_defines.sv"
`timescale 10ns/1ps

`ifndef APB_TOP_SV
`define APB_TOP_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "apb_assrtions.sv"

module apb_top;

   import apb_pkg::*;

   //PCLK and Active low RESET   
   bit PCLK;
   bit PRESETn = 1;

   //clock generation
   initial begin
      forever begin
         PCLK = 1'b0;
         #((1/((1e-8)*(`APB_CLK_FREQ)))/2.0);
         PCLK = 1'b1;
         #((1/((1e-8)*(`APB_CLK_FREQ)))/2.0);
      end //forever
   end //initial

   //Initial reset
   initial begin
      PRESETn = 1'b1;
      //#18.5;
      #0.5;
      PRESETn = 1'b0;
      #1;
      PRESETn = 1'b1;
      //#21;
      //PRESETn = 1'b0;
      //#1;
      //PRESETn = 1'b1;
   end //initial

   //Interface instance
   apb_inf inf(PCLK,PRESETn);

   //RTL instantialtion
   /* apb_mem DUT(._PCLK(inf.PCLK),._PRESETn(inf.PRESETn),._PSEL1(inf.PSEL),._PWRITE(inf.PWRITE),._PENABLE(inf.PENABLE),._PADDR(inf.PADDR),._PWDATA(inf.PWDATA),._PRDATA(inf.PRDATA),._PREADY(inf.PREADY),._PSLVERR(inf.PSLVERR));*/

   /*
   //RTL instantialtion
   APB DUT(.PCLK(inf.PCLK),.PRESET(inf.PRESETn),.PSEL(inf.PSEL),.PWRITE(inf.PWRITE),.PENABLE(inf.PENABLE),.PADDR(inf.PADDR),.PWDATA(inf.PWDATA),.PRDATA(inf.PRDATA),.PREADY(inf.PREADY),.PSLVERR(inf.PSLVERR));
*/ 

   bind  inf apb_assrtions asrt(PCLK,PRESETn,inf.PSEL,inf.PENABLE,inf.PWRITE,inf.PADDR,inf.PWDATA,inf.PRDATA,PREADY,PSLVERR);

   initial begin
      //Setting the interface
      uvm_config_db#(virtual apb_inf)::set(null,"*","vif",inf);
      run_test("");
   end

endmodule: apb_top
`endif //: APB_TOP_SV










/*task automatic reset(ref bit PRESETn,input real a_reset, real d_reset);
PRESETn = 1'b1;
#a_reset;
PRESETn = 1'b0;
#d_reset;
PRESETn = 1'b1;
endtask : reset*/
