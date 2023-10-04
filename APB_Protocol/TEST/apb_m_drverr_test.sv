///////////////////////////////////////////////
// File:          apb_m_drverr_test.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB m_drverr_test file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_M_DRVERR_TEST_SV
`define APB_M_DRVERR_TEST_SV

class apb_m_drverr_test extends apb_base_test;
   // UVM Factory Registration Macro
   //
   `uvm_component_utils(apb_m_drverr_test);

   //Write sequence instance
   //
   apb_write_seq wseq_h;

   //Instance of the slave base sequence
   apb_slv_base_seq sseq_h;

   //callback instance
   //
   apb_master_imp_cb m_cb;
   
   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_m_drverr_test",uvm_component parent);
      super.new(name,parent);
   endfunction : new

   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      wseq_h  = apb_write_seq::type_id::create("seq_h");
      sseq_h = apb_slv_base_seq::type_id::create("sseq_h");
      m_cb   = apb_master_imp_cb::type_id::create("m_cb",this);
      uvm_callbacks#(apb_master_driver,apb_master_drv_cb)::add(env_h.apb_muvc_h.agent_h[0].drv_h,m_cb);
      fork 
         wseq_h.start(env_h.apb_muvc_h.agent_h[0].seqr_h);
         sseq_h.start(env_h.apb_suvc_h.agent_h[0].seqr_h);
      join_any
      phase.drop_objection(this);
   endtask : run_phase
endclass : apb_m_drverr_test
`endif //: APB_M_DRVERR_TEST_SV

//is we have multiple driver then start the sequence on the respective
//sequencer of that agent
