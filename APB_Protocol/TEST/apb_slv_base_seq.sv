///////////////////////////////////////////////
// File:          apb_slv_base_seq.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB slv_base_sequence file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_SLV_BASE_SEQ_SV
`define APB_SLV_BASE_SEQ_SV

class apb_slv_base_seq extends uvm_sequence#(apb_master_trans);
   // UVM Factory Registration Macro
   //
   `uvm_object_utils(apb_slv_base_seq);

   //Apb slave transaction class instance
   //
   apb_slave_trans item;

   //Sequence item instance
   //
   apb_master_trans trans_h;

   //Instance of the sequencer 
   //
   apb_slave_sequencer p_sequencer;

   //Memory for the reactive agent
   //
   bit [`DATA_WIDTH-1:0] slv_mem[int];

   //virtual interface instance
   //
   virtual apb_inf vif;

   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_slv_base_seq");
      super.new(name);
   endfunction : new

   task body();
      //casting required becaues the m_sequencer is parent class handle so it can
      //not access the child class properties directly
      `uvm_info(get_type_name(),"INSIDE THE SLAVE SEQUENCE BODY",UVM_DEBUG);
      if(!uvm_config_db#(virtual apb_inf)::get(null,"","vif",vif))
         `uvm_fatal(get_name(),"Not able to get the interface");

      if(!$cast(p_sequencer,m_sequencer))
         `uvm_fatal(get_type_name,"Casting Failed");

      forever begin
         //used m_sequencer to acssess the sequencer elements
         `uvm_info(get_type_name(),"INSIDE THE FOREVER LOOP",UVM_HIGH); 
         fork
            begin
               p_sequencer.item_fifo.get(item);
               `uvm_info(get_type_name(),$sformatf("SLAVE SEQUENCE TRNSACTION TYPE = %s",item.kind_e),UVM_DEBUG);
               `uvm_info(get_type_name(),$sformatf("SLAVE MEMORY slv_mem = %0p",slv_mem),UVM_DEBUG);
               case(item.kind_e)
                  WRITE : begin
                     //checking for the read only register
                     if((item.PADDR != 8'h00)&&(item.PADDR != 8'h02))begin                                     
                        `uvm_info(get_type_name(),"SLAVE SEQUENCE WRITE TASK",UVM_FULL);
                        slv_mem[item.PADDR] = item.PWDATA;
                        item.PSLVERR = 1'b0;
                        `uvm_send(item)
                     end // if
                        
                     else begin 
                        `uvm_info(get_type_name(),"SLAVE SEQUENCE ELSE WRITE ON PROTECTED(READ ONLY) LOCATION",UVM_FULL);
                        item.PSLVERR = 1'b1;
                        `uvm_info(get_type_name(),"UVM_SEND CALLED",UVM_FULL);
                        //if protected address is there then the PSLVERR is 1 then 
                        //`uvm_send is called soto drive to interface it is called
                        `uvm_send(item)
                     end // else
                     `uvm_info(get_type_name(),$sformatf("SLAVE SEQUENCE slv_mem[%0h] = %0h",item.PADDR,slv_mem[item.PADDR]),UVM_DEBUG);
                  end //write

                  READ  : begin
                     `uvm_info(get_type_name(),"SLAVE SEQUENCE READ TASK",UVM_FULL);
                     if(slv_mem.exists(item.PADDR))begin
                        `uvm_info(get_type_name(),$sformatf("SLAVE SEQUENCE READ ADDRESS = %0h",item.PADDR),UVM_DEBUG);
                        item.PSLVERR = 1'b0;
                        item.PRDATA =  slv_mem[item.PADDR];
                     end //if

                     else if(item.PADDR == 8'h02)begin
                        item.PRDATA = '1;
                        item.PSLVERR = 1'b1;
                       `uvm_info(get_type_name(),$sformatf("SLAVE ADDRESS IS READONLY OR PROTECTED slave_mem ADDRESS = %0h, PRDATA = %0d, PSLVERR = %0d",item.PADDR,item.PRDATA,item.PSLVERR),UVM_DEBUG);
                     end // else if
                     
                     else begin 
                       `uvm_info(get_type_name(),$sformatf("SLAVE ADDRESS NOT EXSIST slave_mem ADDRESS = %0h",item.PADDR),UVM_DEBUG);
                        item.PRDATA = 'h0;
                        item.PSLVERR = 1'b0;
                     end //else
                     //To send the PRDATA is send to interface and also to send the PSLVERR
                     `uvm_send(item)
                  end //read
               endcase
            end // begin

            wait(vif.PRESETn == 0)begin
               //$display($realtime,"Reset applied");
               slv_mem.delete();
            end // wait

            join_any

            //to avoid falling into the forever loop
            wait(vif.PRESETn == 1)begin
               //$display($realtime,"Reset deassrted");
            end //wait
      end //forever
   endtask : body 
endclass : apb_slv_base_seq
`endif //: APB_SLV_BASE_SEQ_SV
