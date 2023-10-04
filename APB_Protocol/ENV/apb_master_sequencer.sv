////////////////////////////////////////////////
// File:          apb_master_sequencer.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB master sequencer file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_MASTER_SEQUENCER
`define APB_MASTER_SEQUENCER
class apb_master_sequencer extends uvm_sequencer#(apb_master_trans);
   // UVM Factory Registration Macro
   //   
   `uvm_component_utils(apb_master_sequencer);

   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods: 
   //
   function new(string name = "apb_master_sequencer",uvm_component parent);
      super.new(name,parent);
   endfunction : new

endclass : apb_master_sequencer
`endif //: APB_MASTER_SEQUENCER
