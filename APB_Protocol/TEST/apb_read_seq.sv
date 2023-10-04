///////////////////////////////////////////////
// File:          apb_read_seq.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB read_sequence file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_READ_SEQ_SV
`define APB_READ_SEQ_SV

class apb_read_seq extends uvm_sequence#(apb_master_trans);
   // UVM Factory Registration Macro
   //
   `uvm_object_utils(apb_read_seq);

   //Sequence item instance
   //
   apb_master_trans trans_h;

   //Intetface class instance
   //
   virtual apb_inf vif;
   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_read_seq");
      super.new(name);
   endfunction : new

   task body();
      `uvm_info(get_type_name(),"INSIDE BODY",UVM_DEBUG);
      if(!uvm_config_db#(virtual apb_inf)::get(null,"","vif",vif))
         `uvm_fatal(get_name,"Not able to get the virtual interface");

      repeat(3)begin
         trans_h = apb_master_trans::type_id::create("trans_h");
         start_item(trans_h);
         if(!trans_h.randomize() with {kind_e == READ;})
            `uvm_fatal("R_SEQ","Randomization Failed");
         finish_item(trans_h);
         //trans_h.print();
      end //repeat

      //Inbetween  reset
      vif.PRESETn = 1'b0;
      #5;
      vif.PRESETn = 1'b1;

      repeat(4)begin
         trans_h = apb_master_trans::type_id::create("trans_h");
         start_item(trans_h);
         if(!trans_h.randomize() with {kind_e == READ;})
            `uvm_fatal("R_SEQ","Randomization Failed");
         finish_item(trans_h);
         //trans_h.print();
      end //repeat
   endtask : body 

endclass : apb_read_seq
`endif //: APB_READ_SEQ_SV
