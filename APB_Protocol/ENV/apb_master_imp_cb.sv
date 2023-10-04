////////////////////////////////////////////////
// File:          apb_master_imp_cb.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB Master Driver 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_MASTER_IMP_CB
`define APB_MASTER_IMP_CB

class apb_master_imp_cb extends apb_master_drv_cb;

   // UVM Factory Registration Macro
   //   
   `uvm_object_utils(apb_master_imp_cb);

   //virtual interface instance
   //
   virtual apb_inf vif;
 
   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods: 
   //
   function new(string name = "apb_master_imp_cb");
      super.new(name);
   endfunction : new

   task psel_asrt();
      if(!uvm_config_db#(virtual apb_inf)::get(null,"","vif",vif))
         `uvm_fatal(get_type_name(),"Not able to get virtual interface");
   endtask : psel_asrt

   task penable_asrt();
      vif.PENABLE <= 1'b0;
   endtask : penable_asrt

   task penable_dasrt();
   endtask : penable_dasrt

 endclass : apb_master_imp_cb

`endif //: APB_MASTER_IMP_CB
