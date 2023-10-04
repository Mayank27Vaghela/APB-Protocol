///////////////////////////////////////////////
// File:          apb_base_test.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB base_testironment file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_BASE_TEST_SV
`define APB_BASE_TEST_SV

class apb_base_test extends uvm_test;
   // UVM Factory Registration Macro
   //
   `uvm_component_utils(apb_base_test);

   //Environment class instance
   //
   apb_env_config env_cfg; 
   
   //Environment class instance
   //
   apb_env env_h;

   //Instance of the slave sequencer   
   apb_slave_sequencer seqr_h;

   //Instance of the slave base sequence
   //   apb_slv_base_seq sseq_h;

   uvm_table_printer m_printer;
   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_base_test",uvm_component parent);
      super.new(name,parent);
   endfunction : new

   //build_phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(),"INSIDE BUILD_PHASE",UVM_DEBUG); 
      env_cfg = apb_env_config::type_id::create("env_cfg");
      uvm_config_db#(apb_env_config)::set(this,"*","env_cfg",env_cfg);

      //Creating the Environment
      env_h = apb_env::type_id::create("env_h",this);
      //uvm_top.unable_print_topology = 1;
      m_printer = new();
   endfunction : build_phase

   //End_of_elaboration_phase
   function void end_of_elaboration_phase(uvm_phase phase);
      super.end_of_elaboration_phase(phase);
      `uvm_info(get_type_name(),"INSIDE END_OF_ELABORATION_PHASE",UVM_FULL);
      //printing testbench components      
       //uvm_top.print_topology(m_printer);
       `uvm_info(get_type_name(),$sformatf("\n%p",this.sprint),UVM_LOW);
       //this.print();
      //`uvm_info(get_type_name(),$sfortmaf("%s",s),UVM_LOW);
   endfunction : end_of_elaboration_phase

   //run_phase
   task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info(get_type_name(),"INSIDE RUN_PHASE",UVM_DEBUG); 
      //slave in always reactive so for all test cases this sequence must start on its sequencer and also we can make it as the default sequence
      phase.drop_objection(this);
      //phase.phase_done.set_drain_time(this,100ns);
   endtask : run_phase
endclass : apb_base_test
`endif //: APB_BASE_TEST_SV_SV
