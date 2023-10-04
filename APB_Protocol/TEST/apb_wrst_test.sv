///////////////////////////////////////////////
// File:          apb_wrst_test.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB wrst read test file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_WRST_TEST_SV
`define APB_WRST_TEST_SV

class apb_wrst_test extends apb_base_test;
   // UVM Factory Registration Macro
   //
   `uvm_component_utils(apb_wrst_test);

   //Write sequence instance
   //
   apb_wrr_seq seq_h;

   //virtual interface instance
   virtual apb_inf vif;

   //Instance of the slave base sequence
   apb_slv_base_seq sseq_h;

   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_wrst_test",uvm_component parent);
      super.new(name,parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info(get_type_name(),"INSIDE RUN_PHASE",UVM_DEBUG);
      seq_h = apb_wrr_seq::type_id::create("seq_h");
      sseq_h = apb_slv_base_seq::type_id::create("seq_h");
      fork
         seq_h.start(env_h.apb_muvc_h.agent_h[0].seqr_h);
         sseq_h.start(env_h.apb_suvc_h.agent_h[0].seqr_h);
      join_any
      phase.drop_objection(this);
   endtask : run_phase

endclass : apb_wrst_test
`endif //: APB_WRST_TEST_SV_SV

//is we have multiple driver then start the sequqence on the respective
//sequencer of that agent
