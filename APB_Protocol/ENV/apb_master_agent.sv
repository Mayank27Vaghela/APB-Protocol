////////////////////////////////////////////////
// File:          apb_master_agent.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB master agent file 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_MASTER_AGENT
`define APB_MASTER_AGENT

class apb_master_agent extends uvm_agent;
   // UVM Factory Registration Macro
   //
   `uvm_component_utils(apb_master_agent);

   //Analysis port 
   //
   uvm_analysis_port#(apb_master_trans) a_mport;

   //------------------------------------------
   // Sequencer,Driver and Monitor Intances
   //------------------------------------------  
   apb_master_sequencer seqr_h;
   apb_master_driver    drv_h;
   apb_master_monitor   mon_h;

   //config class instance
   //
   apb_master_config cfg_h;

   //virtual interface instance
   //
   virtual apb_inf vif;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods: 
   //
   function new(string name = "apb_master_agent",uvm_component parent);
      super.new(name,parent);
      a_mport = new("a_mport",this);
   endfunction : new

   //build_phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(),"Inside the build_phase",UVM_DEBUG);
      //creating monitor      
      mon_h  = apb_master_monitor::type_id::create("mon_h",this);

      //getting the config class
      if(!uvm_config_db#(apb_master_config)::get(this,"","master_cfg",cfg_h))
         `uvm_fatal(get_full_name(),"Not able to get the master config");

      //Checking if agent is ACTIVE or PASSIVE (ACTIVE then create)
      if(cfg_h.is_active == UVM_ACTIVE)begin
         `uvm_info(get_type_name(),"MASTER ACTIVE AGENT",UVM_HIGH);
         seqr_h = apb_master_sequencer::type_id::create("seqr_h",this);
         drv_h  = apb_master_driver::type_id::create("drv_h",this);
      end //if is_active

      //getting virtual interface
      if(!uvm_config_db#(virtual apb_inf)::get(this,"","vif",vif))
         `uvm_fatal(get_full_name,"Not able to get the virtual interface");
   endfunction : build_phase

   //connect_phase
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(),"Inside the connect_phase",UVM_DEBUG);
      
      //If Agent is ACTIVE then connect      
      if(cfg_h.is_active == UVM_ACTIVE)begin
         drv_h.seq_item_port.connect(seqr_h.seq_item_export);
         drv_h.vif = vif;
      end // is_active

      //Assignment tp monitor interface
      mon_h.vif = vif;

      //Analysis port connection
      mon_h.item_collected_port.connect(a_mport);
   endfunction : connect_phase

endclass : apb_master_agent
`endif //: APB_MASTER_AGENT
