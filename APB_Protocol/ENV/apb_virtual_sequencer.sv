////////////////////////////////////////////////
// File:          apb_virtual_sequencer.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB virtual sequencer file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_VIRTUAL_SEQUENCER
`define APB_VIRTUAL_SEQUENCER
class apb_virtual_sequencer extends uvm_sequencer#(apb_virtual_trans);
   // UVM Factory Registration Macro
   //  
   `uvm_component_utils(apb_virtual_sequencer);

   //Instance of the sub_sequencers
   //
   apb_master_sequencer mseqr_h
   apb_slave_sequencer  sseqr_h;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods: 
   function new(string name = "apb_virtual_sequencer",uvm_component parent);
      super.new(name,parent);
   endfunction : new

endclass : apb_virtual_sequencer
`endif //: APB_VIRTUAL_SEQUENCER
