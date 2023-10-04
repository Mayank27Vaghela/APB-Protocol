////////////////////////////////////////////////
// File:          apb_inf.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB Interface 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`timescale 10ns/1ps
interface apb_inf(input bit PCLK,input bit PRESETn);

   //Address, write data and read data
   logic [(`ADDR_WIDTH-1):0] PADDR;
   logic [(`DATA_WIDTH-1):0] PWDATA;
   logic [(`DATA_WIDTH-1):0] PRDATA;

   //Control signals
   logic PSEL = 0;
   logic PENABLE = 0;
   logic PWRITE;

   //Salve signals
   logic PREADY;
   logic PSLVERR;

   //Clocking block declaration for driver
   clocking drv_cb @(posedge PCLK);
     default input #1 output #0; 
     output PADDR,PWDATA,PRDATA,PSEL,PENABLE,PWRITE; 
  endclocking

   //Clocking block declaration for monitor
   clocking mon_cb@(posedge PCLK);
      default input #1 output #0;
      input PREADY,PSLVERR;
   endclocking

   //Modport for the driver
   modport DRV_MP(clocking drv_cb);

   //Modport for the monitor
   modport MON_MP(clocking mon_cb);
endinterface : apb_inf
