////////////////////////////////////////////////
// File:          apb_master_trans.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB Master transaction class
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_MASTER_TRANS_SV
`define APB_MASTER_TRANS_SV
  
class apb_master_trans extends uvm_sequence_item;
      
   //------------------------------------------
   // Data Members (Outputs rand)
   //------------------------------------------   
   rand  trans_kind_e kind_e;
   randc bit [(`ADDR_WIDTH  - 1) :0] PADDR;
   rand  bit [(`DATA_WIDTH  - 1) :0] PWDATA;
         bit                         PSLVERR;     
   constraint trans_type {soft kind_e == WRITE;}

   //UVM Factory Registration Macro
   //
   `uvm_object_utils(apb_master_trans)
     /*`uvm_object_utils_begin(apb_master_trans)
        `uvm_field_enum(trans_kind_e,kind_e,UVM_DEFAULT);
        `uvm_field_int(PADDR,UVM_DEFAULT | UVM_DEC);
        `uvm_field_int(PWDATA,UVM_DEFAULT | UVM_DEC);
     `uvm_object_utils_end*/

   //Constraint for the PADDR
   //
   constraint addr {soft PADDR inside {[0:30]};}

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods:      
   function new(string name = "apb_master_trans");
      super.new(name);
   endfunction : new

   virtual function string convert2string();
      string s = "";
      s = super.convert2string();
      //foreach(kind_e[i])begin
         $sformat(s,"%s kind_e\t%s\n",s,kind_e.name());
      //end
      return s;
   endfunction : convert2string

   function void do_print(uvm_printer printer);
      //super.do_print(printer);
      //printer.print_enum("Transaction Type",kind_e);
      printer.print_string("kind_e",kind_e.name());
      printer.print_int("PADDR",PADDR,$bits(PADDR),UVM_DEC);
      printer.print_int("PWDATA",PWDATA,$bits(PWDATA),UVM_DEC);
   endfunction : do_print
endclass : apb_master_trans
`endif //APB_MASTER_TRANS_SV
