///////////////////////////////////////////////
// File:          apb_wrr_seq.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB write reset and read sequence file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_WRR_SEQ_SV
`define APB_WRR_SEQ_SV

class apb_wrr_seq extends uvm_sequence#(apb_master_trans);
   // UVM Factory Registration Macro
   //
   `uvm_object_utils(apb_wrr_seq);

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
   function new(string name = "apb_wrr_seq");
      super.new(name);
   endfunction : new

   task body();
      `uvm_info(get_type_name(),"INSIDE BODY",UVM_DEBUG);
      if(!uvm_config_db#(virtual apb_inf)::get(null,"","vif",vif))
         `uvm_fatal(get_name(),"Unable to get virtual interface");

      repeat(5)begin
         trans_h = apb_master_trans::type_id::create("trans_h");
         start_item(trans_h);
         if(!trans_h.randomize() with {kind_e == WRITE;})
            `uvm_fatal("W_SEQ","Randomization Failed");
         finish_item(trans_h);
         //trans_h.print();
      end

      vif.PRESETn = 1'b0;
      #5;
      vif.PRESETn = 1'b1; 

      repeat(5)begin
         trans_h = apb_master_trans::type_id::create("trans_h");
         start_item(trans_h);
         if(!trans_h.randomize() with {kind_e == READ;})
            `uvm_fatal("W_SEQ","Randomization Failed");
         finish_item(trans_h);
         //trans_h.print();
      end
      
   endtask : body 

endclass : apb_wrr_seq

`endif //: APB_WRR_SEQ_SV
