////////////////////////////////////////////////
// File:          apb_assrtions.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   Assrtions 
/////////////////////////////////////////////////

//
// Assertions Description:
//
//

interface apb_assrtions(input logic PCLK,input logic PRESETn,input logic PSEL,input logic PENABLE,PWRITE,input logic[(`ADDR_WIDTH-1):0]PADDR,input logic[(`DATA_WIDTH-1):0]PWDATA,input logic[(`DATA_WIDTH-1):0]PRDATA,input logic PREADY,input logic PSLVERR);
   
   realtime time_period = 10ns;
   /*
   initial begin
      $display("time_period = %0t",`APB_CLK_FREQ);
      $display("time_period = %0t",time_period);
   end*/

  //Assertion for clock required clock is generated or not
   property clock_freq;
      realtime current_time;
      @(posedge PCLK)
      disable iff(!PRESETn)
      (1,current_time = $realtime) |=>(time_period == ($realtime - current_time));
   endproperty : clock_freq 

   CLOCK_CHECK:assert property(@(posedge PCLK)clock_freq)
      //`uvm_info("APB_ASSRTIONS","CLOCK PASSED!!",UVM_NONE)
   else
      `uvm_error("APB_ASSRTIONS","CLOCK FAILED!!\n");

   //Assertion for write and read with and without wait states
   property wr_wait_nowait;
      @(posedge PCLK)
      disable iff(!PRESETn)
      $rose(PSEL) && (!PENABLE) && (PWRITE || !PWRITE) |=> $rose(PENABLE) ##[0:(`READY_TIMEOUT-1)] PREADY;
   endproperty : wr_wait_nowait
    
   WR_CHECK:assert property(@(posedge PCLK)wr_wait_nowait)
   else 
      `uvm_error("APB_ASSRTIONS","WRITE FAILED!!\n");

   //Assertion for timeout of PREADY signal
   property timeout;
      @(posedge PCLK)
      disable iff(!PRESETn)
      $rose(PENABLE) |-> ##[0:(`READY_TIMEOUT-1)] PREADY; 
   endproperty : timeout
    
   TIMEOUT_CHECK:assert property(@(posedge PCLK)timeout)
   else 
      `uvm_error("APB_ASSRTIONS","TIMEOUT FAILED!!\n");

   //Asserion for b2b check when PENABLE is LOW then checking that PSEL is stable or not
   property b2b;
      @(posedge PCLK)
      disable iff(!PRESETn)
      $fell(PENABLE) |-> $stable(PSEL);
   endproperty : b2b
   
   B2B_CHECK:assert property(@(posedge PCLK)b2b)
   else 
      `uvm_error("APB_ASSRTIONS","b2b FAILED!!\n");

   //Assrtion for the stability of data inbetween PSEL and PREADY are asserted 
   property write_stable;
      @(posedge PCLK)
      disable iff(!PRESETn)
      PENABLE |-> ($stable(PSEL) && $stable(PADDR) && $stable(PWDATA) && $stable(PWRITE)) ##[0:(`READY_TIMEOUT-1)] PREADY;
      //$rose(PENABLE) ##0 $stable(PSEL) and $stable(PADDR) and $stable(PWDATA) and $stable(PWRITE); // no change same as && with ##0
      //$rose(PENABLE) ##0 $stable(PSEL) && $stable(PADDR) && $stable(PWDATA) && $stable(PWRITE);
      //$rose(PENABLE) |-> $stable(PSEL) && $stable(PADDR) && $stable(PWDATA) && $stable(PWRITE); same as "and"
   endproperty : write_stable

   STABILITY_CHECK : assert property(@(posedge PCLK)write_stable)
   else
      `uvm_error("APB_ASSERTIONS","WRITE STABLE FAILED\n");

   //Assrtion for when PREADY is Assrted at that time PRDATA is available or not
   property read_data;
      @(posedge PCLK)
      disable iff(!PRESETn)
       (!PWRITE) |-> ##[0:$] PREADY ##0 (!PRDATA || PRDATA);
      //if PRDATA x is sampled then error will occour
      //##[0:$] PREADY is there because sometimes PREADY is also extended by
      //inbetween reset and the assrtion starts at the PSEL but PREADT is
      //asserted after PENABLE
   endproperty : read_data

   RDATA_CHECK : assert property(@(posedge PCLK)read_data)
   else
      `uvm_error("APB_ASSERTIONS","READ_DATA IS NOT AVAILABLE AT INTERFACE AFTER PREADY\n");

   //Assertion for checking if PREADY is LOW then PRDATA should not available at interface

   //Assertion for PRESETn(Active low) so if Asserted then the all control
   //signals from master and slave side should go to zero.
   property async_reset;
     @(negedge PRESETn)
     1'b1 |=> @(posedge PCLK) (PSEL == 0 && PENABLE == 0 && PWRITE == 0 && PREADY == 0 && PSLVERR == 0);
   endproperty : async_reset

   ASYNCRST_CHECK : assert property(async_reset)
   else
     `uvm_error("APB_ASSERTIONS","RESET IS ASSRTED BUT CONTROL SIGNALS ARE NOT ZERO\n");

   //Assertion for checking the PSLVERR is asserted at write address
   property pslverr;
      int ronly = 8'd2;
      int protec = 8'b0;
      @(posedge PCLK)
      //PREADY && (PADDR == ronly) ##0 PSLVERR;
      //detecting PSLVERR and then checking so if while PRESETn is asserted
      //then at that time PSLVERR is assrted then error will be displayed 
      (PSEL && PENABLE && PREADY && PSLVERR) |-> ((PRESETn) && (PADDR == ronly)||(PADDR == protec));
   endproperty : pslverr

   PSLVERR_CHECK : assert property(pslverr)
   else
     `uvm_error("APB_ASSERTIONS","PSLVERR FAILED || CHECK THAT PSLVERR IS ASSERTED AT WRITE ADDRESS OR CHECK IF PSLVERR IS ASSERTED WHEN PRESETn IS ASSERTED\n");

endinterface : apb_assrtions





















/*
   //Assertion for checking if PREADY is LOW then PRDATA should not available at interface
   property unexp_rdata;
      @(posedge PCLK)
      disable iff(!PRESETn)
      !PREADY |-> (!PRDATA || PRDATA == 1'bx);
   endproperty : unexp_rdata

   unrdata_check : assert property(@(posedge PCLK)unexp_rdata)
   else
      `uvm_error("APB_ASSERTIONS","READ_DATA IS AVAILABLE AT PREADY IS NOT ASSERTED");
* */

/*
   property read_stable;
      @(posedge PCLK)
      disable iff(!PRESETn)
      PSEL |-> (!PWRITE) |=> PENABLE ##[0:(`READY_TIMEOUT-1)] PREADY |-> PRDATA or !PRDATA ;
   endproperty : read_stable

   read_stable_check : assert property(@(posedge PCLK)read_stable)
   else
      `uvm_error("APB_ASSERTIONS","READ STABLE FAILED");
*/

 /* 
   property pwrite;
      @(posedge PCLK)
      disable iff(!PRESETn)
      PSEL |-> PWRITE within PENABLE;
   endproperty : pwrite

   pwrite_check : assert property(@(posedge PCLK)pwrite)
   else
      `uvm_error("APB_ASSRTIONS","PWRITE FAILED");
   */   
   
  //Assrtion for checking b2b


/*
*    sequence stable;
      $stable(PRDATA) and $stable(PWRITE) and $stable(PWDATA) and $stable(PWRITE);
   endsequence : stable

   property s_check;
      @(posedge PCLK)
      disable iff(!PRESETn)
      write within stable; 
   endproperty : s_check

    stable_check:assert property(@(posedge PCLK)s_check)
   else 
      `uvm_error("APB_ASSRTIONS","PADDR,PWDATA and PWRITE is not stable!!");

/*
   property wait_stability;
      @(posedge PCLK)
      disable iff(!PRESETn)
      PSEL |=> PENABLE throughout !PREADY; 
   endproperty : wait_stability
   
   wait_stability_check:assert property(@(posedge PCLK)wait_stability)
   else 
      `uvm_error("APB_ASSRTIONS","PENABLE IS CHANGING THROUGH PREADY IS NOT ASSRTED!!");*/
/*
   property stable_addr;
      @(posedge PCLK)
      disable iff(!PRESETn)
      //$rose(PADDR) until_with !PREADY;   
   endproperty : stable_addr

   stable_addr_check:assert property(@(posedge PCLK)stable_addr)
   else 
      `uvm_error("APB_ASSRTIONS","ADDRESS IS NOT STABLE!!");
*/


