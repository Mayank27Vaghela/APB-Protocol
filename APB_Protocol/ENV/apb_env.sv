///////////////////////////////////////////////
// File:          apb_env.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB environment file 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_ENV_SV
`define APB_ENV_SV

class apb_env extends uvm_env;
   // UVM Factory Registration Macro
   //
   `uvm_component_utils(apb_env);

   //------------------------------------------
   // Master and Salve UVC handles
   //------------------------------------------ 
   apb_master_uvc apb_muvc_h;
   apb_slave_uvc  apb_suvc_h;

   //Instance of scoreboard and subscriber
   //
   apb_scoreboard sb_h;
   apb_subscriber sc_h;

   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods
   function new(string name = "apb_env",uvm_component parent);
      super.new(name,parent);
   endfunction : new

   //build_phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      `uvm_info(get_name(),"Inside the build_phase",UVM_DEBUG);
      //Creating the master agent wrapper(master_uvc)      
      apb_muvc_h = apb_master_uvc::type_id::create("apb_muvc_h",this);
   
      //Creating the slave agent wrapper(slave_uvc)      
      apb_suvc_h = apb_slave_uvc::type_id::create("apb_suvc_h",this);
      sb_h = apb_scoreboard::type_id::create("sb_h",this);
      sc_h = apb_subscriber::type_id::create("sc_h",this);
   endfunction : build_phase

   //connect_phase
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      `uvm_info(get_name(),"Inside the connect_phase",UVM_DEBUG);
      //master monitor and slave monitor connection to the scoreboard
      apb_muvc_h.u_mport.connect(sb_h.mmon_imp);
      apb_suvc_h.u_sport.connect(sb_h.smon_imp);
 
      //master monitor and slave monitor connection to the subscriber
      apb_suvc_h.agent_h[0].mon_h.item_req_port.connect(sc_h.analysis_export);
   endfunction : connect_phase
endclass : apb_env
`endif //: APB_ENV_SV
