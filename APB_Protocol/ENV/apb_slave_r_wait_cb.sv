////////////////////////////////////////////////
// File:          apb_slave_r_wait_cb.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB slave driver callback class
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_SLAVE_R_WAIT_CB_SV
`define APB_SLAVE_R_WAIT_CB_SV
  
class apb_slave_r_wait_cb extends apb_slave_drv_cb;

   // UVM Factory Registration Macro
   //
   `uvm_object_utils(apb_slave_r_wait_cb);

   //Interface class instance
   //
   virtual apb_inf vif;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods:      
   function new(string name = "apb_slave_r_wait_cb");
      super.new(name);
   endfunction : new

   //callback method overriding      
   virtual task ready_asrt();
      if(!uvm_config_db#(virtual apb_inf)::get(null,"","vif",vif))
         `uvm_fatal(get_name,"Not able to get the interface");

      //use of hardcoded delays is not recommended(because in some cases the
      //PREADY is assrted is negedge of PCLK which is violation of protocol)
      #9.5;
      vif.PREADY = 1'b1;
      #20;
      vif.PREADY = 1'b0;
      #3;
      vif.PREADY = 1'b1;
      #2;
      vif.PREADY = 1'b0;
      #3;
      vif.PREADY = 1'b1;
   endtask : ready_asrt

   task ready_1(int cycle);
      repeat(cycle)begin
         @(posedge vif.PCLK)
            vif.PREADY = 1'b1;
      end //begin
   endtask : ready_1

   task ready_0(int cycle);
      repeat(cycle)begin
         @(posedge vif.PCLK)
            vif.PREADY = 1'b0;
      end //begin
   endtask : ready_0

endclass : apb_slave_r_wait_cb
`endif //APB_SLAVE_R_WAIT_CB_SV






/*
*       #10;
      vif.PREADY = 1'b1;
      #15.5;
      vif.PREADY = 1'b0;
      #2;
      vif.PREADY = 1'b1;
*/
