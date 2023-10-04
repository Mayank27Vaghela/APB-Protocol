///////////////////////////////////////////////
// File:          apb_write_seq.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB write_sequence file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_WRITE_SEQ_SV
`define APB_WRITE_SEQ_SV

class apb_write_seq extends uvm_sequence#(apb_master_trans);
   // UVM Factory Registration Macro
   //
   `uvm_object_utils(apb_write_seq);

   //Sequence item instance
   //
   apb_master_trans trans_h;

   //virtual interface class instance
   //
   virtual apb_inf vif;

   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_write_seq");
      super.new(name);
   endfunction : new

   //body task
   task body();
      `uvm_info(get_type_name(),"INSIDE BODY",UVM_DEBUG);
      if(!uvm_config_db#(virtual apb_inf)::get(null,"","vif",vif))
         `uvm_fatal(get_type_name(),"Not able to get the interface");

      repeat(5)begin
         trans_h = apb_master_trans::type_id::create("trans_h");
         start_item(trans_h);
         if(!trans_h.randomize() with {kind_e == WRITE;})
            `uvm_fatal("W_SEQ","Randomization Failed");
         finish_item(trans_h);
         trans_h.print();
      end //repeat
      
      vif.PRESETn = 1'b0;
      #3;
      vif.PRESETn = 1'b1;

      repeat(5)begin
         trans_h = apb_master_trans::type_id::create("trans_h");
         start_item(trans_h);
         if(!trans_h.randomize() with {kind_e == WRITE;})
            `uvm_fatal("W_SEQ","Randomization Failed");
         finish_item(trans_h);
         //trans_h.print();
      end //repeat

      vif.PRESETn = 1'b0;
      #3;
      vif.PRESETn = 1'b1;

      repeat(5)begin
         trans_h = apb_master_trans::type_id::create("trans_h");
         start_item(trans_h);
         if(!trans_h.randomize() with {kind_e == WRITE;})
            `uvm_fatal("W_SEQ","Randomization Failed");
         finish_item(trans_h);
         //trans_h.print();
      end //repeat
   endtask : body 

endclass : apb_write_seq
`endif //: APB_WRITE_SEQ_SV
