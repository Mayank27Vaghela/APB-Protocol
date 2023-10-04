////////////////////////////////////////////////
// File:          apb_slave_monitor.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB Slave monitor file 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_SLAVE_MONITOR
`define APB_SLAVE_MONITOR
class apb_slave_monitor extends uvm_monitor;
   // UVM Factory Registration Macro
   //    
   `uvm_component_utils(apb_slave_monitor);

   //virtual interface instance
   //
   virtual apb_inf vif;

   //Slave transaction class instance
   //
   apb_slave_trans trans_h;

   //Analysis port declareation for the reactive agent
   //
   uvm_analysis_port#(apb_slave_trans) item_req_port;
   uvm_analysis_port#(apb_slave_trans) item_collected_port;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods:  
   function new(string name = "apb_slave_monitor",uvm_component parent);
      super.new(name,parent);
      item_req_port = new("item_req_port",this);
      item_collected_port = new("item_collected_port",this);
   endfunction : new

   //build_phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(),"INSIDE BUILD_PHASE",UVM_DEBUG);
      trans_h = apb_slave_trans::type_id::create("trans_h");
   endfunction : build_phase

   //run_phase
   task run_phase(uvm_phase phase);
      //sampling data from interface      
      `uvm_info(get_type_name(),"INSIDE RUN_PHASE",UVM_DEBUG);
      monitor_apb_data(); 
   endtask : run_phase

   //Monitor always monitors the data as per the protocol so forever loop is taken
   virtual task monitor_apb_data();
      `uvm_info(get_type_name(),"INSIDE THE monitor_apb_data TASK",UVM_FULL);
      forever begin
         `uvm_info(get_type_name(),"INSIDE FOREVER LOOP",UVM_FULL);
         @(posedge vif.PENABLE)begin
            trans_h.kind_e = trans_kind_e'(vif.PWRITE);
            case(trans_h.kind_e)
               WRITE : write();
               READ  : read(); 
            endcase
         end //PENABLE
      end //forever
   endtask : monitor_apb_data

   task write();
      `uvm_info(get_type_name(),"WRITE METHOD CALLED SLAVE MONITOR",UVM_FULL);
      trans_h.PADDR = vif.PADDR;
      `uvm_info(get_type_name(),$sformatf("trans_h.PADDR = %0d",trans_h.PADDR),UVM_DEBUG);
      trans_h.PWDATA = vif.PWDATA;
      $cast(trans_h.kind_e,vif.PWRITE);
      //Taking the write data to the sequencer
      item_req_port.write(trans_h);
      //trans_h.print(uvm_default_tree_printer);
   endtask : write

   task read();
      wait(vif.PREADY==1);
      `uvm_info(get_type_name(),"READ TASK CALLED SLAVE MONITOR",UVM_FULL);
      trans_h.PADDR = vif.PADDR;
      trans_h.PRDATA = vif.PRDATA;
      trans_h.PSLVERR = vif.PSLVERR;
      //trans_h.print(uvm_default_table_printer);
      item_req_port.write(trans_h);

      `uvm_info(get_type_name(),$sformatf("PRDATA = %0h",trans_h.PRDATA),UVM_DEBUG);
      
      //slave read data for the scoreboard and sc
      #0.25;

      `uvm_info(get_type_name(),$sformatf("AFTER THE DELAY PRDATA = %0h",trans_h.PRDATA),UVM_DEBUG);
      //if(!vif.PSLVERR)begin
         item_collected_port.write(trans_h);
      //end //if

      //else
         //`uvm_info(get_type_name(),$sformatf("PSLVERR!!\n"),UVM_NONE);
   endtask : read

endclass : apb_slave_monitor
`endif //: APB_SLAVE_MONITOR
