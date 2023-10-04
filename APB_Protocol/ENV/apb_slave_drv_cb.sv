////////////////////////////////////////////////
// File:          apb_slave_drv_cb.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB slave driver base callback class
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_SLAVE_DRIVER_CB_SV
`define APB_SLAVE_DRIVER_CB_SV
  
class apb_slave_drv_cb extends uvm_callback;

   // UVM Factory Registration Macro
   //
   `uvm_object_utils(apb_slave_drv_cb);

   //Interface class instance
   //
   //virtual apb_inf vif;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods:      
   function new(string name = "apb_slave_drv_cb");
      super.new(name);
   endfunction : new

   //callback method
   //
   virtual task ready_asrt;
   /*if(!uvm_config_db#(virtual apb_inf)::get(null,"","vif",vif))
      `uvm_fatal(get_name,"Not able to get the interface");*/
   endtask : ready_asrt

endclass : apb_slave_drv_cb
`endif //APB_SLAVE_DRIVER_CB_SV
