////////////////////////////////////////////////
// File:          apb_master_drv_cb.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB Master Driver 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_MASTER_DRV_CB
`define APB_MASTER_DRV_CB

class apb_master_drv_cb extends uvm_callback;

   // UVM Factory Registration Macro
   //   
   `uvm_object_utils(apb_master_drv_cb);

   //virtual interface instance
   //
   virtual apb_inf vif;
 
   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods: 
   //
   function new(string name = "apb_master_drv_cb");
      super.new(name);
   endfunction : new

   task psel_asrt();
   endtask : psel_asrt

   task penable_asrt();
   endtask : penable_asrt

   task penable_dasrt();
   endtask : penable_dasrt

endclass : apb_master_drv_cb
`endif //: APB_MASTER_DRV_CB
