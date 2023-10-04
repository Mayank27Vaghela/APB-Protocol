///////////////////////////////////////////////
// File:          apb_mix_test.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB mix read test file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_MIX_TEST_SV
`define APB_MIX_TEST_SV

class apb_mix_test extends apb_base_test;
   // UVM Factory Registration Macro
   //
   `uvm_component_utils(apb_mix_test);

   //Write sequence instance
   //
   apb_write_seq  wseq_h;
   apb_read_seq   rseq_h;
   apb_wr_seq     wrseq_h;
   apb_wrr_seq    wrrseq_h;

   //virtual interface instance
   virtual apb_inf vif;

   //Instance of the slave base sequence
   apb_slv_base_seq sseq_h;

   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_mix_test",uvm_component parent);
      super.new(name,parent);
   endfunction : new

   //run_phase
   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info(get_type_name(),"INSIDE RUN_PHASE",UVM_DEBUG);
      wseq_h = apb_write_seq::type_id::create("wseq_h");
      rseq_h = apb_read_seq::type_id::create("rseq_h");
      wrseq_h = apb_wr_seq::type_id::create("wrseq_h");
      wrrseq_h = apb_wrr_seq::type_id::create("wrrseq_h");
      sseq_h = apb_slv_base_seq::type_id::create("sseq_h");
      fork
         begin          
            wseq_h.start(env_h.apb_muvc_h.agent_h[0].seqr_h);
            rseq_h.start(env_h.apb_muvc_h.agent_h[0].seqr_h);
            wrseq_h.start(env_h.apb_muvc_h.agent_h[0].seqr_h);
            wrrseq_h.start(env_h.apb_muvc_h.agent_h[0].seqr_h);
         end
         sseq_h.start(env_h.apb_suvc_h.agent_h[0].seqr_h);
      join_any
      phase.drop_objection(this);
   endtask : run_phase
endclass : apb_mix_test
`endif //: APB_MIX_TEST_SV_SV

//is we have multiple driver then start the sequqence on the respective
//sequencer of that agent
