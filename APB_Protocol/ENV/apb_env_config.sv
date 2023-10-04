////////////////////////////////////////////////
// File:          apb_env_config.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB master config file 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_MASTER_CONFIG
`define APB_MASTER_CONFIG

class apb_env_config extends uvm_object;

   //------------------------------------------
   // Data Members 
   //------------------------------------------  

   //configure agent as active or passive   
   uvm_active_passive_enum is_active = UVM_ACTIVE;

   //number of agent in the environment
   //
   int no_of_agents = 1;

   // UVM Factory Registration Macro
   //
   `uvm_object_utils_begin(apb_env_config)
     `uvm_field_enum(uvm_active_passive_enum,is_active,UVM_DEFAULT)
     `uvm_field_int(no_of_agents,UVM_DEFAULT)
   `uvm_object_utils_end

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods:  
   function new(string name = "apb_env_config");
      super.new(name);
   endfunction : new
  
endclass : apb_env_config
`endif //APB_MASTER_CONFIG
