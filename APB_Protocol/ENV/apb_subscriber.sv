////////////////////////////////////////////////
// File:          apb_subscriber.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB subscriber file 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_SUBSCRIBER_SV
`define APB_SUBSCRIBER_SV
class apb_subscriber extends uvm_subscriber#(apb_slave_trans);
   // UVM Factory Registration Macro
   //   
   `uvm_component_utils(apb_subscriber);

   //APB Master transaction class instance
   //
   apb_slave_trans strans_h;

   //Instance of virtual interface
   //
   virtual apb_inf vif;

   //Covergroup for functional coverage
   //
   covergroup apb_cg;
      option.per_instance = 1;
      kind_cp : coverpoint strans_h.kind_e iff(vif.PRESETn)
      {
         option.comment = "Transaction type";
         bins kind_cb[] = {READ,WRITE};
      }

      transition_cp : coverpoint strans_h.kind_e iff(vif.PRESETn)
      {
         option.comment = "Transition of the Transactions and B2B Transaction";
         bins trans_cb[] = (WRITE,READ => WRITE,READ);
         bins b2b_cb     = (WRITE=>READ[*2]);
      }

      PADDR_cp : coverpoint strans_h.PADDR iff(vif.PRESETn)
      {
         option.comment = "PADDR Range from low to high";
         bins RO_PRO_cb[]         = {8'h0,8'h2};
         bins PADDR_low_rng_cb    = {8'h1,[8'h3:8'hA]};
         bins PADDR_mid_rng_cb    = {[8'hB:8'h1D]};
         bins PADDR_high_rng_cb   = {[8'h1E:8'hFF]};
      }

      PWDATA_cp : coverpoint strans_h.PWDATA iff(vif.PRESETn)
      {
         option.comment = "PWDATA Range from low to high";
         bins PWDATA_low_rng_cb   = {['h0 :'h54]};
         bins PWDATA_mid_rng_cb   = {['h55:'hA9]};
         bins PWDATA_high_rng_cb  = {['hAA:'hFF]};
      }

      PRDATA_cp : coverpoint strans_h.PRDATA iff(vif.PRESETn)
      {
         option.comment = "PRDATA Range from low to high";
         bins PRDATA_low_rng_cb   = {['h0 :'h54]};
         bins PRDATA_mid_rng_cb   = {['h55:'hA9]};
         bins PRDATA_high_rng_cb  = {['hAA:'hFF]};
      }

      kindXPADDR_cp : cross kind_cp,PADDR_cp iff(vif.PRESETn)
      {
         option.comment = "At every type of Transaction PADDR is available or not";
      }

      writeXPWDATA_cp  : cross kind_cp,PWDATA_cp iff(vif.PRESETn)
      {
         option.comment = "Cross between write Transaction and PWDATA";
         type_option.comment = "Ignoring the PRDATA while write is transaction done";
         ignore_bins readXPWDATA_cb = writeXPWDATA_cp with (kind_cp == READ);
      }

      readXPRDATA_cp  : cross kind_cp,PRDATA_cp iff(vif.PRESETn)
      {
         option.comment = "Cross between read Transaction and PRDATA";
         type_option.comment = "Ignoring the PWDATA while read is transaction done";
         ignore_bins writeXPRDATA = readXPRDATA_cp with (kind_cp == WRITE);
      }

      PSLVERR_cp : coverpoint strans_h.PSLVERR iff(vif.PRESETn)
      {
         option.comment = "Values of PSLVERR";
         bins PSLVERR_cb[] = {0,1};
      }

      wrXPSLVERR_cp : cross kind_cp,PSLVERR_cp iff(vif.PRESETn)
      {
         option.comment = "Cross between PSLVERR is assrted with the Transaction type";
         ignore_bins wrPSLVERR0_cb = binsof(PSLVERR_cp) intersect{0}; 
      }
   endgroup

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods: 
   //
   function new(string name = "apb_subscriber",uvm_component parent);
      super.new(name,parent);
      apb_cg = new();
   endfunction : new

   //build_phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(),"INSIDE BUILD_PHASE",UVM_DEBUG);
      //retriving the virtual interface
      if(!uvm_config_db#(virtual apb_inf)::get(this,"","vif",vif))
         `uvm_fatal(get_type_name(),"Not able to get virtual interface");
   endfunction : build_phase

   //extract_phase
   function void extract_phase(uvm_phase phase);
      super.extract_phase(phase);
      `uvm_info(get_type_name(),"INSIDE EXTRACT_PHASE",UVM_DEBUG);
      //Printing the overall functional covrage coverage
      `uvm_info(get_type_name(),$sformatf(" TOTAL FUNCTIONAL COVERAGE = %0f",$get_coverage()),UVM_NONE);
   endfunction : extract_phase

   //write method
   function void write(apb_slave_trans t);
      `uvm_info(get_type_name(),"INSIDE WRITE METHOD",UVM_FULL);
      strans_h = t;
      apb_cg.sample();
   endfunction : write
endclass
`endif //: APB_SUBSCRIBER
