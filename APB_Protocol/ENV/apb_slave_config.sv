////////////////////////////////////////////////
// File:          apb_slave_config.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB slave config file 
/////////////////////////////////////////////////
//
// Class Description:
//
`ifndef APB_SLAVE_CONFIG
`define APB_SLAVE_CONFIG

class apb_slave_config extends uvm_object;

   //------------------------------------------
   // Data Members 
   //------------------------------------------   
   //configure agent as active or passive  
   uvm_active_passive_enum is_active = UVM_ACTIVE;

   //number of agent in the environment   
   int no_of_agents = 1;

   //salve 1 address range
   bit[0:`ADDR_WIDTH-1]salve1_s = 8'd0;
   bit[0:`ADDR_WIDTH-1]slave1_e = 8'd25;

   bit[0:`ADDR_WIDTH-1]salve2_s;
   bit[0:`ADDR_WIDTH-1]slave2_e;
   // UVM Factory Registration Macro
   //
   `uvm_object_utils_begin(apb_slave_config)
      `uvm_field_enum(uvm_active_passive_enum,is_active,UVM_DEFAULT)
      `uvm_field_int(no_of_agents,UVM_DEFAULT)
    `uvm_object_utils_end

   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_slave_config");
      super.new(name);
   endfunction : new
  
endclass : apb_slave_config

`endif //: APB_SLAVE_CONFIG




//if we ahve multiple agents then all agents are active or passive
