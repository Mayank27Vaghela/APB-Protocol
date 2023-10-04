////////////////////////////////////////////////
// File:          apb_master_uvc.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB master uvc file 
/////////////////////////////////////////////////

//
// Class Description: 
//
//
`ifndef APB_MASTER_UVC
`define APB_MASTER_UVC

class apb_master_uvc extends uvm_agent;
   // UVM Factory Registration Macro
   //
   `uvm_component_utils(apb_master_uvc);

   //------------------------------------------
   // Agent and config class instance
   //------------------------------------------ 
   apb_master_config cfg_h;
   apb_master_agent  agent_h[];

   //Analysis port
   uvm_analysis_port#(apb_master_trans) u_mport;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods:     
   function new(string name = "apb_master_uvc",uvm_component parent);
      super.new(name,parent);
      u_mport = new("u_mport",this);
   endfunction : new

   //build_phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      `uvm_info(get_type_name(),"INSIDE THE BUILD_PHASE",UVM_DEBUG); 
      
      //Creating the agent wrapper(UVC)       
      cfg_h = apb_master_config::type_id::create("cfg_h");
      uvm_config_db#(apb_master_config)::set(this,"*","master_cfg",cfg_h);

      agent_h = new[cfg_h.no_of_agents];

      //creating the agents as per the config
      foreach(agent_h[i])begin
         agent_h[i] = apb_master_agent::type_id::create($sformatf("agent_h[%0d]",i),this);
      end // foreach       
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(),"INSIDE THE CONNECT_PHASE",UVM_DEBUG); 
      agent_h[0].a_mport.connect(u_mport);
   endfunction : connect_phase

endclass : apb_master_uvc
`endif //: APB_MASTER_UVC
