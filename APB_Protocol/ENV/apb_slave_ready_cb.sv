////////////////////////////////////////////////
// File:          apb_ready_cb.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB slave driver callback class
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_READY_CB_SV
`define APB_READY_CB_SV
  
class apb_slave_ready_cb extends apb_slave_drv_cb;

   // UVM Factory Registration Macro
   //
   `uvm_object_utils(apb_slave_ready_cb);

   //Interface class instance
   //
   virtual apb_inf vif;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods:      
   function new(string name = "apb_slave_ready_cb");
      super.new(name);
   endfunction : new

   //callback method overriding      
   virtual task ready_asrt;
      if(!uvm_config_db#(virtual apb_inf)::get(null,"","vif",vif))
         `uvm_fatal(get_name,"Not able to get the interface");

         ready_1(12); 
         ready_0(1);
         ready_1(10); 
         ready_0(1);
         ready_1(10); 
         ready_0(1);
         ready_1(10); 
         ready_0(1);
         ready_1(10); 
         ready_0(1);
         ready_1(10); 
         ready_0(1);
         ready_1(10); 
         ready_0(1);
         ready_1(10); 
         ready_0(1);
         ready_1(11); 
         ready_0(1);
   endtask : ready_asrt

   task ready_1(int clock);
      if(clock >1)begin
         repeat(clock-1)begin
            @(posedge vif.PCLK);
         end //repeat
         `uvm_info(get_type_name(),"ready == 1 - if",UVM_DEBUG);
      end //if

      else begin
         @(posedge vif.PCLK)
            vif.PREADY = 1'b1;
         `uvm_info(get_type_name(),"ready == 1 - else",UVM_DEBUG);
      end //else

      if(clock >1) begin
         @(posedge vif.PCLK)
            vif.PREADY = 1'b1;
            `uvm_info(get_type_name(),"ready == 1 - ",UVM_DEBUG);
      end //else
   endtask : ready_1

   task ready_0(int clock);
      if(clock >1)begin
         repeat(clock-1)begin
            @(posedge vif.PCLK);
         end //repeat
         `uvm_info(get_type_name(),"ready == 0 - if",UVM_DEBUG);
      end //if

      else begin
         @(posedge vif.PCLK)
            vif.PREADY = 1'b0;
         `uvm_info(get_type_name(),"ready == 0 - else",UVM_DEBUG);
      end //else

      if(clock >1) begin
         @(posedge vif.PCLK)
            vif.PREADY = 1'b0;
            `uvm_info(get_type_name(),"ready == 0 - ",UVM_DEBUG);
      end //else
   endtask : ready_0

endclass : apb_slave_ready_cb
`endif //APB_READY_CB_SV





















/*
*          ready_1(10); 
         ready_0(1);
         ready_1(10); 
         ready_0(1);
         ready_1(10); 
         ready_0(1);
* */


/*
*          repeat(9)begin
            @(posedge vif.PCLK);
         end
         $display($realtime,,,,"R1-----------");
         vif.PREADY = 1'b1;
         
         repeat(1)begin
            @(posedge vif.PCLK);
         end

         vif.PREADY = 1'b0;
         $display($realtime,,,,"R2-----------");


             /*  #12.5;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;
      
      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;
      
      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;
      
      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;

      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;

      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;

      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;

      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;

      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;
      
      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;
      
      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;
      
      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;      
      
      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;
      
      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;
      
      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;
      #1;*/
     /* 
      #9;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;*/
