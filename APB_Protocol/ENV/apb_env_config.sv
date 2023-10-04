////////////////////////////////////////////////
// File:          apb_env_config.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB environment config file 
/////////////////////////////////////////////////

//
// class Description:
//
//
`ifndef APB_ENV_CONFIG
`define APB_ENV_CONFIG

class apb_env_config extends uvm_object;

   `uvm_object_utils(apb_env_config);
   //------------------------------------------
   // Data Members 
   //------------------------------------------  

   //To enable or disable the coverage
   //
   bit coverage = 1'b1;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods:  
   function new(string name = "apb_env_config");
      super.new(name);
   endfunction : new
  
endclass : apb_env_config
`endif //APB_ENV_CONFIG
