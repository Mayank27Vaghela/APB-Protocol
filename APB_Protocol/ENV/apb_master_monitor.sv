////////////////////////////////////////////////
// File:          apb_master_monitor.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB master monitor file 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_MASTER_MONITOR
`define APB_MASTER_MONITOR
class apb_master_monitor extends uvm_monitor;
   // UVM Factory Registration Macro
   // 
   `uvm_component_utils(apb_master_monitor);

   //virtual interface instance
   virtual apb_inf vif;

   //Instance of the master transaction class
   //
   apb_master_trans trans_h;

   //Analysis port for scoreboard and coverage collector
   //
   uvm_analysis_port#(apb_master_trans) item_collected_port;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods: 
   //
   function new(string name = "apb_master_monitor",uvm_component parent);
      super.new(name,parent);
      item_collected_port = new("item_collected_port",this);
   endfunction : new

   //build_phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(),"Inside the build_phase",UVM_DEBUG); 
      trans_h = apb_master_trans::type_id::create("trans_h");
   endfunction : build_phase

   //run_phase
   task run_phase(uvm_phase phase);
      //sample data from interface
      `uvm_info(get_type_name(),"Inside the run_phase",UVM_DEBUG); 
      monitor_apb_data();
   endtask : run_phase

   //Task for monitoring
   virtual task monitor_apb_data();
      `uvm_info(get_type_name(),"INSIDE THE MONITOR TASK",UVM_FULL);
      forever begin
      `uvm_info(get_type_name(),"INSIDE THE FOREVER LOOP",UVM_HIGH);
         @(posedge vif.PENABLE)begin
            //cating from the PWRITE to the kind_e enum
            trans_h.kind_e = trans_kind_e'(vif.PWRITE);
            //checking the type of the transaction
            case(trans_h.kind_e)
               WRITE : write();
            endcase
         end //PENABLE
      `uvm_info(get_type_name(),"OUTSIDE THE FOREVER LOOP",UVM_HIGH);
      end //forever      
   endtask : monitor_apb_data

   //write method
   task write();
      `uvm_info(get_type_name(),"WRITE CALLED FROM MASTER MONITOR",UVM_HIGH);
      //waiting for the PREADY so that we can capture the PSLVERR
      wait(vif.PREADY == 1);
      //dealy because the sampled value of PSLAVRR was old value not new value
      #0.25;
      trans_h.PADDR   = vif.PADDR;
      trans_h.PWDATA  = vif.PWDATA;
      trans_h.PSLVERR = vif.PSLVERR;
      //write method call for the master monitor to send data to sb and sc
      `uvm_info(get_type_name(),$sformatf($realtime,"PADDR = %0d",trans_h.PADDR),UVM_FULL); 
      `uvm_info(get_type_name(),$sformatf($realtime,"PWDATA = %0d",trans_h.PWDATA),UVM_FULL); 

      `uvm_info(get_type_name(),$sformatf("MASTER MONITOR trans_h paddr = %0p",trans_h.PADDR),UVM_DEBUG);
      `uvm_info(get_type_name(),$sformatf("MASTER MONITOR trans_h pwdata = %0p",trans_h.PWDATA),UVM_DEBUG);

      //the monitor was sampling the previous transaction data not current so
      //taking some hard coded dealy no other option
      
      //if PSLVERR is not there then and then send the transaction to the scoreboard
      item_collected_port.write(trans_h);
      
      /*if(vif.PSLVERR)begin
         if(trans_h.PADDR == 8'd2)begin
            `uvm_info(get_type_name(),$sformatf("PASSED || PSLVERR!!\n"),UVM_NONE);
         end
         else 
            `uvm_info(get_type_name(),$sformatf("FAILED || PSLVERR!!\n"),UVM_NONE);
      end //if*/

   endtask : write

endclass : apb_master_monitor
`endif //: APB_MASTER_MONITOR
