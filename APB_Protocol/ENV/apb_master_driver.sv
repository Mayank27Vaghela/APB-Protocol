////////////////////////////////////////////////
// File:          apb_master_driver.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB Master Driver 
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_MASTER_DRIVER
`define APB_MASTER_DRIVER

class apb_master_driver extends uvm_driver #(apb_master_trans);

   // UVM Factory Registration Macro
   //   
   `uvm_component_utils(apb_master_driver);

   //bit for checking that the try nrxt item is called or not
   //
   bit try;

   //r_count is the counter for timeout if the PREADY not came
   //
   int r_count;

   //Temp variable to store the value of the r_count while the r_count is 0
   int r_temp;

   //indicats that  if the ready is asserted at the last cycle then the
   //timeout will not occour to do this i am comparing with >9 not >=9
   //for breaking the forever loop but still if ready is not asserted at the
   //9th cycle but timeout will not occur so this bit will set if ready is
   //high at the 9th cycle
   bit rdy = 0;

   //virtual interface instance
   //
   virtual apb_inf vif;

   //Registaring the callback
   //
   `uvm_register_cb(apb_master_driver,apb_master_drv_cb);

   //Taking uvm_pool to provide the write data and address to the scorebord
   //
   uvm_pool #(bit[`ADDR_WIDTH-1:0],bit[`DATA_WIDTH-1:0]) drv2sb_pool;
 
   //------------------------------------------
   // Methods
   //------------------------------------------

   //Standard UVM Methods: 
   //
   function new(string name = "apb_master_driver",uvm_component parent);
      super.new(name,parent);
      //setting as globel pool is new is done then the scoreboard will not share same uvm_pool
      drv2sb_pool = uvm_pool#(bit[`ADDR_WIDTH-1:0],bit[`DATA_WIDTH-1:0])::get_global_pool();
   endfunction : new

   //run_phase
   task run_phase(uvm_phase phase);
      `uvm_info(get_type_name(),"INSIDE THE RUN_PHASE",UVM_DEBUG);
      forever begin
         fork
            begin
               `uvm_info(get_type_name(),"PREASETn NOT ASSERTED",UVM_FULL);
               wait(vif.PRESETn==0)begin
                  `uvm_info(get_type_name(),"RESET ASSERTED",UVM_FULL);
               end
            end //PRESETn

            forever begin
               `uvm_info(get_type_name(),"INSIDE FOREVER CALLED",UVM_HIGH);
               `uvm_info(get_type_name(),"BEFORE TRY_NEXT_ITEM",UVM_FULL);
               seq_item_port.try_next_item(req);
               try = 1;
               `uvm_info(get_type_name(),"TRY_NEXT_ITEM_CALLED",UVM_FULL);

               //task to check and drive the data as per the protocol into the interface
               send_to_dut();     

               `uvm_info(get_type_name(),"BEFORE THE BREAK",UVM_HIGH);
               `uvm_info(get_type_name(),$sformatf("READY TIMOUT = %0d",(`READY_TIMEOUT)),UVM_HIGH);

               if(r_temp >= (`READY_TIMEOUT-1))begin
                  `uvm_info(get_type_name(),"INSIDE THE CONDITION FOR THR MAX COUNT",UVM_FULL);
                  `uvm_info(get_type_name(),$sformatf("rdy = %0d",rdy),UVM_DEBUG);
                  if(rdy == 0)begin
                     `uvm_info(get_type_name(),"BREAK CALLED",UVM_HIGH);
                     break;
                  end
                  `uvm_info(get_type_name(),$sformatf("rdy AFTER %0d",rdy),UVM_DEBUG);
               end
               //seq_item_port.item_done(); do not write item done here
            end //forever 
         join_any

         `uvm_info(get_type_name(),"RESET ASSERTED",UVM_HIGH);
    
         disable fork;
         `uvm_info(get_type_name(),"DISABLE FORK CALLED",UVM_FULL);
         `uvm_info(get_type_name,"AFTER RESET PENABLE",UVM_DEBUG);
         vif.PENABLE = 1'b0;
        
         //not deasserting ready because it make the transaction stuck
         `uvm_info(get_type_name,"AFTER RESET PSEL",UVM_FULL);
         vif.PSEL = 1'b0;
         vif.PWRITE <= 1'b0;

         wait(vif.PRESETn == 1)
            `uvm_info(get_type_name(),"RESET DEASSRTED",UVM_FULL); 
            //checking if the transaction is there in the process and reset asserted or not if that happened then again 
            //transaction(same transaction when the reset is applied) must be send to DUT  
            //checking this avoids a conditions when the transaction is completed but at that time when enable is deasseted the 
            //reset is asserted then the new transaction is not fetched and now the reset part will be called so again when 
            //reset is deassered the previous transaction is driven to the DUT so to avoid that here the try flag is there 
            //which indicates if the try_next_item is called or not 

         `uvm_info(get_type_name(),"BEFORE TRY",UVM_DEBUG);
         if(try == 1)begin
            send_to_dut();
         end //if 

         `uvm_info(get_type_name(),"AFTER TRY",UVM_DEBUG);
         //Here while doing normal transaction why item done will not called because of the default condition of the driver that 
         //if no transaction is there then drive 0 to the interface so if no reset arrives in between then the disable fork 
         //will never seen by the compiler

         `uvm_info(get_type_name(),$sformatf("BEFORE r_temp",r_temp),UVM_DEBUG);
         if(r_temp >= `READY_TIMEOUT-1)begin
            `uvm_info(get_type_name(),$sformatf("INSIDE CONDITION(OUT SIDE FOREVER LOOP) r_temp = %0d",r_temp),UVM_DEBUG);
            r_temp = 0;
            if(rdy == 0)begin
               `uvm_info(get_type_name(),"INSIDE READY \"BREAK\"",UVM_DEBUG);
               break;
            end //if rdy
         end //if

         r_temp = 0;
      end// forever

     `uvm_info(get_type_name(),"OUTSIDE THE OUTER FOREVER LOOP(INSIDE THE RUN_PHASE TASK)",UVM_FULL);
     `uvm_fatal(get_type_name(),"READY TIMEOUT!!! \n\n\t\t\tPLEASE CHECK PREADY MUST BE ASSERTED BETWEEN THE READY TIMEOUT TIME (YOU CAN CHANGE TIMEOUT TIME FROM THE DEFINES FILE FORM \"READY_TIMEOUT\" VARIABLE.)");
   endtask : run_phase

   task send_to_dut();
      //checking that if transaction is available then drive the control signals and data,
      //otherwise drive the default values of the signals
      if(req != null)begin
      
         //to avoid the one cycle delay while doing back to back transactions
         //$isunknown is used for if the initial reset is not given and the
         //tried to start a transaction
         if(vif.PSEL != 1 || ($isunknown(vif.PSEL)==1))begin
            @(posedge vif.PCLK)
            vif.PSEL <= 1'b1;
         end //if
         
         //checking the type of the transaction it is  read or write
         case(req.kind_e)
            WRITE : write(req);
            READ  : read(req);
         endcase

         //Initially when the PSEL is asseted then in the next cycle master needs to
         //drive the enable 1
         @(posedge vif.PCLK)begin
            if(vif.PRESETn)
            vif.PENABLE <= 1'b1;
            `uvm_info(get_type_name(),"PENABLE ASSERTED",UVM_FULL);
         end

         //At same cycle we are checking if the ready is available or not if ready is
         //there the transaction is completed and in the next cycle the enable need to be zero
         //here checking at the enable the ready is available or not if not
         //then wait for ready had problem when the doing the test of b2b write read with the wait states
         //(when the pready is assrted at negedge of PCLK)

         fork
            begin
               //checking if the PREADY is asserted as same time when the
               //PENABLE is assrted if PEANBLE is assrted then transaction is
               //completed otherwise then wait for PREADY to be assrted 
               if(vif.PREADY)begin
                  `uvm_info(get_type_name(),"WAIING FOR READY",UVM_FULL); 
                  `uvm_info(get_type_name(),"READY",UVM_DEBUG);
               end
               else begin
                  `uvm_info(get_type_name(),"INSIDE READY WAIT",UVM_DEBUG);
                  @(posedge vif.PCLK)
                     `uvm_info(get_type_name(),"BEFORE READY",UVM_DEBUG);
                     wait(vif.PREADY);
                     `uvm_info(get_type_name(),"AFTER READY",UVM_DEBUG);
               end //else
            end // thread 1

            begin
               repeat(`READY_TIMEOUT-1)begin
                  @(posedge vif.PCLK)
                     r_count++;
                     `uvm_info(get_type_name(),$sformatf("rd_count = %0d",r_count),UVM_DEBUG);
               end //repeat
            end // thread 2
            
            //waiting for PRESETn to be asserted
            begin
               wait(!vif.PRESETn);
            end
         join_any

         disable fork;

         //if PRESETn is assrted the the count for the PREADY should be 0
         if(vif.PRESETn ==0)
            r_count = 0;

         //if the PREADY r_count is the max count then check for the PREADY is
         //assrted at the last cycle or not that is stored in the rdy bit
         if(r_count == (`READY_TIMEOUT-1))begin
            `uvm_info(get_type_name(),"TIMEOUT OCCOURED",UVM_FULL);
            `uvm_info(get_type_name(),$sformatf("TIMEOUT rd_count = %0d",r_count),UVM_DEBUG);
              rdy = 0;
              if(vif.PREADY)begin
                  rdy = 1;
                  `uvm_info(get_type_name(),$sformatf("PREADY rdy = %0d",rdy),UVM_DEBUG);
              end //if PREADY
         end // r_count

         //storing the r_count into the r_temp
         r_temp = r_count;

         //resetting the r_count 
         r_count = 0;
         `uvm_info(get_type_name(),$sformatf("r_temp = %0d",r_temp),UVM_DEBUG);
         //$display($realtime,"out");
         @(posedge vif.PCLK)
           vif.PENABLE <= 1'b0;

           `uvm_info(get_type_name(),"ITEM DONE BEFORE",UVM_FULL); 
           seq_item_port.item_done(); //do not put item done here 

           //we have put item done here other wise our first transaction will not get the item_done 
           `uvm_info(get_type_name(),"ITEM DONE CALLED",UVM_FULL); 
           try = 0;
          `uvm_info(get_type_name(),$sformatf("AFTER TRY try = %0d",try),UVM_DEBUG); 
      end //if (req !=null) 

      //if no transaction is avilable then the control signals are zero
      else begin
      `uvm_info(get_type_name(),"NO TRANSACTION \"NULL\"",UVM_HIGH);

      //To aviod getting the PSEL zero while the back to back transaction the PSEL
      //is deasseted before.
         vif.PSEL <= 1'b0;
         `uvm_info(get_type_name(),"ELSE PSEL IS DEASSERTED",UVM_FULL);
         @(posedge vif.PCLK)
            vif.PENABLE <= 1'b0;
         vif.PWRITE <= 1'b0;
      end // else
   endtask : send_to_dut 

   //Drive transaction to interface
   //for the write transaction
   virtual task write(apb_master_trans req);
      `uvm_info(get_type_name(),"WRITE TASK CALLED",UVM_FULL); 
      vif.PADDR <= req.PADDR;
      vif.PWDATA <= req.PWDATA;
      vif.PWRITE <= req.kind_e;
      drv2sb_pool.add(req.PADDR,req.PWDATA);
      `uvm_info(get_type_name(),$sformatf("drv2sb_pool members = %0d",drv2sb_pool.num()),UVM_HIGH)
   endtask : write

   //for the read transaction
   virtual task read(apb_master_trans req);
      `uvm_info(get_type_name(),"READ TASK CALLED",UVM_FULL); 
      vif.PADDR <= req.PADDR;
      vif.PWRITE <= req.kind_e;
   endtask : read 
endclass : apb_master_driver
`endif //: APB_MASTER_DRIVER
