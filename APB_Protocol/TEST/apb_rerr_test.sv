/////////////////////////////////////////////
// File:          apb_rerr_test.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB rerr_test file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_RERR_TEST_SV
`define APB_RERR_TEST_SV

class apb_rerr_test extends apb_base_test;
   // UVM Factory Registration Macro
   //
   `uvm_component_utils(apb_rerr_test);

   //Write sequence instance
   //
   apb_rerr_seq seq_h;

   //Instance of the slave base sequence
   apb_slv_base_seq sseq_h;
   
   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_rerr_test",uvm_component parent);
      super.new(name,parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info(get_type_name(),"INSIDE RUN_PHASE",UVM_DEBUG);
      seq_h = apb_rerr_seq::type_id::create("seq_h");
      sseq_h = apb_slv_base_seq::type_id::create("seq_h");
      fork 
         seq_h.start(env_h.apb_muvc_h.agent_h[0].seqr_h);
         sseq_h.start(env_h.apb_suvc_h.agent_h[0].seqr_h);
      join_any
      phase.drop_objection(this);
   endtask : run_phase
endclass : apb_rerr_test
`endif //: APB_RERR_TEST_SV

//is we have multiple driver then start the sequqence on the respective
//sequencer of that agent
