////////////////////////////////////////////////
// File:          apb_slave_uvc.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB slave uvc file 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_SLAVE_UVC
`define APB_SLAVE_UVC

class apb_slave_uvc extends uvm_agent;
   // UVM Factory Registration Macro
   //   
   `uvm_component_utils(apb_slave_uvc);

   //------------------------------------------
   // Slave Agent and Slave config instace
   //------------------------------------------ 
   apb_slave_config cfg_h;
   apb_slave_agent  agent_h[];

   //Analysis port
   //
   uvm_analysis_port#(apb_slave_trans) u_sport;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods: 
   function new(string name = "apb_slave_uvc",uvm_component parent);
      super.new(name,parent);
      u_sport = new("u_sport",this);
   endfunction : new

   //build_phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(),"INSIDE BUILD_PHASE",UVM_DEBUG);
      cfg_h = apb_slave_config::type_id::create("cfg_h");

      //setting the config class for agent       
      uvm_config_db#(apb_slave_config)::set(this,"*","slave_cfg",cfg_h);

      //creating the agents as per the config
      agent_h = new[cfg_h.no_of_agents];

      foreach(agent_h[i])begin
         agent_h[i] = apb_slave_agent::type_id::create($sformatf("agent_h[%0d]",i),this);
      end //foreach
   endfunction : build_phase

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(),"INSIDE CONNECT_PHASE",UVM_DEBUG)
      //Analysis port connection
      agent_h[0].a_sport.connect(u_sport);
   endfunction : connect_phase

endclass : apb_slave_uvc
`endif //: APB_SLAVE_UVC
