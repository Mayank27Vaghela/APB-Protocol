///////////////////////////////////////////////
// File:          apb_wrerr_test.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB wrerr read test file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_WRERR_TEST_SV
`define APB_WRERR_TEST_SV

class apb_wrerr_test extends apb_base_test;
   // UVM Factory Registration Macro
   //
   `uvm_component_utils(apb_wrerr_test);

   //Write sequence instance
   //
   apb_werr_seq wseq_h;
   apb_rerr_seq  rseq_h;

   //virtual interface instance
   virtual apb_inf vif;

   //Instance of the slave base sequence
   apb_slv_base_seq sseq_h;

   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_wrerr_test",uvm_component parent);
      super.new(name,parent);
   endfunction : new

   //run_phase
   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info(get_type_name(),"INSIDE RUN_PHASE",UVM_DEBUG);
      wseq_h = apb_werr_seq::type_id::create("wseq_h");
      rseq_h = apb_rerr_seq::type_id::create("rseq_h");
      sseq_h = apb_slv_base_seq::type_id::create("sseq_h");
      fork
         begin
            wseq_h.start(env_h.apb_muvc_h.agent_h[0].seqr_h);
            rseq_h.start(env_h.apb_muvc_h.agent_h[0].seqr_h);
         end
         sseq_h.start(env_h.apb_suvc_h.agent_h[0].seqr_h);
      join_any
      phase.drop_objection(this);
   endtask : run_phase
endclass : apb_wrerr_test
`endif //: APB_WRERR_TEST_SV_SV

//is we have multiple driver then start the sequqence on the respective
//sequencer of that agent
