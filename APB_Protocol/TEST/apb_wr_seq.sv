///////////////////////////////////////////////
// File:          apb_wr_seq.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB write read sequence file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_WR_SEQ_SV
`define APB_WR_SEQ_SV

class apb_wr_seq extends uvm_sequence#(apb_master_trans);
   // UVM Factory Registration Macro
   //
   `uvm_object_utils(apb_wr_seq);

   //Sequence item instance
   //
   apb_master_trans trans_h;

   //virtual interface instance
   //
   virtual apb_inf vif;
   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_wr_seq");
      super.new(name);
   endfunction : new

   task body();
      `uvm_info(get_type_name(),"INSIDE BODY",UVM_DEBUG);
      if(!uvm_config_db#(virtual apb_inf)::get(null,"","vif",vif))
         `uvm_fatal(get_name(),"Unable to get virtual interface");

      repeat(10)begin
         trans_h = apb_master_trans::type_id::create("trans_h");
         start_item(trans_h);
         if(!trans_h.randomize() with {kind_e == WRITE;})
            `uvm_fatal("W_SEQ","Randomization Failed");
         finish_item(trans_h);

         trans_h = apb_master_trans::type_id::create("trans_h");
         start_item(trans_h);
         if(!trans_h.randomize() with {kind_e == READ;})
            `uvm_fatal("W_SEQ","Randomization Failed");
         finish_item(trans_h);
      end
   endtask : body 

endclass : apb_wr_seq
`endif //: APB_WR_SEQ_SV
