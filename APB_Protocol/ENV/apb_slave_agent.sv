////////////////////////////////////////////////
// File:          apb_slave_agent.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB slave agent file 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_SLAVE_AGENT
`define APB_SLAVE_AGENT
class apb_slave_agent extends uvm_sequencer;

   // UVM Factory Registration Macro
   //   
   `uvm_component_utils(apb_slave_agent);

   //------------------------------------------
   // sequqencer,driver and monitor instances
   //------------------------------------------  
   apb_slave_sequencer seqr_h;
   apb_slave_driver    drv_h;
   apb_slave_monitor   mon_h;

   //slave config class instance
   //
   apb_slave_config cfg_h;

   //virtual interface instance
   //
   virtual apb_inf vif; 

   //Analysis port
   //
   uvm_analysis_port#(apb_slave_trans) a_sport;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods: 
   function new(string name = "apb_slave_agent",uvm_component parent);
      super.new(name,parent);
      a_sport = new("a_sport",this);
   endfunction : new

   //build_phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      `uvm_info(get_type_name(),"INSIDE BUILD_PHASE",UVM_DEBUG);
      //Creating monitor     
      mon_h  = apb_slave_monitor::type_id::create("mon_h",this);
 
      //getting the config class
      if(!uvm_config_db#(apb_slave_config)::get(this,"","slave_cfg",cfg_h))
         `uvm_fatal(get_full_name,"Not able to get the slave config");

      //Checking Agent is ACTIVE or PASSIVE(ACTIVE then create)
      if(cfg_h.is_active == UVM_ACTIVE) begin
         `uvm_info(get_type_name(),"SLAVE ACTIVE AGENT",UVM_DEBUG);
         seqr_h = apb_slave_sequencer::type_id::create("seqr_h",this);
         drv_h  = apb_slave_driver::type_id::create("drv_h",this);
      end //if

      //getting virtual inerface
      if(!uvm_config_db#(virtual apb_inf)::get(this,"","vif",vif))
         `uvm_fatal(get_type_name,"Not able to get the Virtual interface");
   endfunction : build_phase

   //connect_phase
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      `uvm_info(get_type_name(),"INSIDE CONNECT_PHASE",UVM_DEBUG);
 
      //Chekcing of Agent is ACTIVE or PASSive and then connect
      if(cfg_h.is_active == UVM_ACTIVE) begin
         drv_h.seq_item_port.connect(seqr_h.seq_item_export);
         
         //connection between analysis port and sequencer analysis export for the reactive agent
         mon_h.item_req_port.connect(seqr_h.item_export);
         drv_h.vif = vif;
         
         //Analysis port connection
         mon_h.item_collected_port.connect(a_sport);
      end //if

      //assign the interface to monitor
      mon_h.vif = vif;
   endfunction : connect_phase

endclass : apb_slave_agent
`endif //: APB_SLAVE_AGENT
