////////////////////////////////////////////////
// File:          apb_slave_sequencer.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB master sequencer file 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_SLAVE_SEQUENCER
`define APB_SLAVE_SEQUENCER
class apb_slave_sequencer extends uvm_sequencer#(apb_slave_trans);
   // UVM Factory Registration Macro
   //  
   `uvm_component_utils(apb_slave_sequencer);

   //Analysis export and analysis fifo declaration for the reactive agent
   //
   uvm_analysis_export#(apb_slave_trans) item_export;
   uvm_tlm_analysis_fifo#(apb_slave_trans) item_fifo;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods: 
   function new(string name = "apb_slave_sequencer",uvm_component parent);
      super.new(name,parent);
      item_export = new("item_export",this);
      item_fifo = new("item_fifo",this);
   endfunction : new

   //connect_phase
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(),"INSIDE CONNECT_PHASE",UVM_DEBUG);
      item_export.connect(item_fifo.analysis_export);
   endfunction : connect_phase

endclass : apb_slave_sequencer
`endif //: APB_SLAVE_SEQUENCER
