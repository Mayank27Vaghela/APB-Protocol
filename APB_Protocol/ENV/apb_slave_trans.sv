////////////////////////////////////////////////
// File:          apb_slave_trans.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB Slave Transaction file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_SLAVE_TRANS_SV
`define APB_SLAVE_TRANS_SV
class apb_slave_trans extends uvm_sequence_item;

   //------------------------------------------
   // Data Members (Read data non-rand)
   //------------------------------------------            
 
   trans_kind_e kind_e;
   bit [(`ADDR_WIDTH  - 1) :0] PADDR;
   bit [(`DATA_WIDTH  - 1) :0] PWDATA;
 
   bit [(`DATA_WIDTH - 1):0] PRDATA;
  
   bit PSLVERR;

   //UVM Factory Registration Macro
   //
   `uvm_object_utils_begin(apb_slave_trans)
      `uvm_field_enum(trans_kind_e,kind_e,UVM_DEFAULT);
      `uvm_field_int(PADDR,UVM_DEFAULT | UVM_DEC);
      `uvm_field_int(PWDATA,UVM_DEFAULT | UVM_DEC);
      `uvm_field_int(PRDATA,UVM_DEFAULT | UVM_DEC);
      `uvm_field_int(PSLVERR,UVM_DEFAULT);
   `uvm_object_utils_end

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods:        
   function new(string name = "apb_slave_trans");
      super.new(name);
   endfunction : new 

   endclass : apb_slave_trans
`endif //: APB_SLAVE_TRANS_SV
