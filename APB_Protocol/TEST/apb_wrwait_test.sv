///////////////////////////////////////////////
// File:          apb_wrwait_test.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB wrwait read test file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_WRWAIT_TEST_SV
`define APB_WRWAIT_TEST_SV

class apb_wrwait_test extends apb_base_test;
   // UVM Factory Registration Macro
   //
   `uvm_component_utils(apb_wrwait_test);

   //Write sequence instance
   //
   apb_wr_seq seq_h;

   //virtual interface instance
   virtual apb_inf vif;

   //Instance of the slave base sequence
   apb_slv_base_seq sseq_h;

   //Instance of derived callback class(apb_slave_ready_cb)
   //
   apb_slave_r_wait_cb rd_cb; 
   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_wrwait_test",uvm_component parent);
      super.new(name,parent);
   endfunction : new

   //build_phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(),"INSIDE BUILD_PHASE",UVM_DEBUG);
      rd_cb = apb_slave_r_wait_cb::type_id::create("rd_cb",this);
   endfunction : build_phase

   //run_phase
   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info(get_type_name(),"INSIDE RUN_PHASE",UVM_DEBUG);
      uvm_callbacks#(apb_slave_driver,apb_slave_drv_cb)::add(env_h.apb_suvc_h.agent_h[0].drv_h,rd_cb);
      seq_h = apb_wr_seq::type_id::create("seq_h");
      sseq_h = apb_slv_base_seq::type_id::create("seq_h");
      fork
         seq_h.start(env_h.apb_muvc_h.agent_h[0].seqr_h);
         sseq_h.start(env_h.apb_suvc_h.agent_h[0].seqr_h);
      join_any
      phase.drop_objection(this);
   endtask : run_phase
endclass : apb_wrwait_test
`endif //: APB_WRWAIT_TEST_SV_SV

//is we have multiple driver then start the sequqence on the respective
//sequencer of that agent
