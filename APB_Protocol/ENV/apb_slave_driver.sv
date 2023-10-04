////////////////////////////////////////////////
// File:          apb_slave_driver.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB slave driver
/////////////////////////////////////////////////

//
// Class Description:
//
//
`ifndef APB_SLAVE_DRIVER
`define APB_SLAVE_DRIVER

class apb_slave_driver extends uvm_driver#(apb_slave_trans);

   // UVM Factory Registration Macro
   //
   `uvm_component_utils(apb_slave_driver);

   //Registration for the callbacks (implemented for ready)
   //
   `uvm_register_cb(apb_slave_driver,apb_slave_drv_cb)

   //virtual interface
   //
   virtual apb_inf vif;

   //Adding get_count to prevent the slave driver to drive the read data every
   //time when reset is assered because the read data should be available when
   //the read transaction is there

   //count for the get_next_item call
   //
   bit get_count;

   // ready count the default ready must be assrted at initial clock edge not every time
   //
   bit rd_count;

   // variable for executing the callback only 1time during the simulation
   //
   bit cb;

   //
   //If the PRESETn is assrted then the PREADY should deassrted and when then
   //when the PREASETn is deasseted the PREADY should be asserted then the
   //PREADY should be assrted because there is no callback for that testcase 
   //so this bit is used for sync.
   bit rst = 1'b0;

   //
   //This bir helps and stops the multiple times calling of the drive_to_inf task call
   bit d2i;

   //------------------------------------------
   // Methods
   //------------------------------------------

   //standard UVM Methods: 
   function new(string name = "apb_slave_driver",uvm_component parent);
      super.new(name,parent);
   endfunction : new

   //run_phase
   task run_phase(uvm_phase phase);
      `uvm_info(get_type_name(),"INSIDE RUN_PHASE",UVM_DEBUG);
      forever begin
           `uvm_info(get_type_name(),"INSIDE OUTER  FOREVER LOOP",UVM_FULL);
           fork
              `uvm_info(get_type_name(),"INSIDE FORK",UVM_FULL)
               //At every edge of clk checking that if the reset is there or not if there then we give priority to reset not 
               //this else reset is not there then checking for the rd_count to make sure that this will execute only once 
               //because this is require initially to provide the pready signal to the nowait testcases
               begin
                  if(vif.PRESETn != 0)begin
                     if(rd_count == 0) begin
                        `uvm_info(get_type_name(),"READY DRVING",UVM_FULL);
                        `uvm_info(get_type_name(),$sformatf("rd_count = %0d",rd_count),UVM_DEBUG);
                        vif.PREADY <= 1'b0;
                        vif.PSLVERR <= 1'b0;
                          
                        //calling the hook method for callback taking this cb is preventing this callback to be
                        //called evey time when reset is deassrted and due to forever loop this will be called agin so this
                        //cb will avoid calling the callback again and again 
                        if(cb == 0)begin
                           cb = 1;
                           `uvm_info(get_type_name()," BEFORE CALLBACK CALLED",UVM_HIGH);
                           `uvm_do_callbacks(apb_slave_driver,apb_slave_drv_cb,ready_asrt)
                           `uvm_info(get_type_name(),"AFTER CALLBACK CALLED",UVM_HIGH);
                          
                           @(posedge vif.PCLK)begin
                              //if i remove this then at first cycle the PREADY
                              //is assetrted and the callback will not work

                              if(vif.PRESETn)begin
                                 vif.PREADY <= 1'b1;
                                 `uvm_info(get_type_name(),"if ----- PREADY ASSERTED",UVM_FULL);
                                 rst = 1'b1;
                              end //if PRESETn
                              
                              else begin
                                 wait(vif.PRESETn)
                                    vif.PREADY <= 1'b1;
                                 rst = 1'b1;
                                 `uvm_info(get_type_name(),"else ----- PREADY ASSERTED",UVM_FULL);
                              end // else 
                           end // PCLK

                           rd_count = 1;
                           `uvm_info(get_type_name(),$sformatf("rd_count AFTER PREADY ASSERTED = %0d",rd_count),UVM_DEBUG);
                        end // if
                     end // if
                  end //if
               end //begin

               begin
                  wait(vif.PRESETn == 0);
                  `uvm_info(get_type_name(),"RESET ASSERTED",UVM_HIGH);
               end //wait

               //if you remove the forever read data will not come
               begin : DRIVE 
                  forever begin
                     @(posedge vif.PCLK)begin
                        `uvm_info(get_type_name(),"PCLK SLAVE DRIVER",UVM_FULL);
                        wait(vif.PSEL);
                           `uvm_info(get_type_name(),"PSEL SLAVE DRIVER",UVM_FULL);
                           @(posedge vif.PENABLE)begin
                              `uvm_info(get_type_name(),"PENB SLAVE DRIVER",UVM_FULL);
                              if(get_count == 0)begin
                                 `uvm_info(get_type_name(),"BEFORE GET_NEXT_ITEM SLAVE DRIVER",UVM_HIGH);
                                 get_count = 1;
                                 seq_item_port.get_next_item(req);
                                 `uvm_info(get_type_name(),"GET_NEXT_ITEM CALLED SLAVE DRIVER",UVM_FULL);
                                 drive_to_inf(req);
                                 seq_item_port.item_done;
                                 get_count = 0;
                                 `uvm_info(get_type_name(),"ITEM DONE CALLED SLAVE DRIVER",UVM_HIGH);
                              end //if
                           end //PENABLE
                     end //PCLK
                  end //forever
               end//begin
           join_any
           `uvm_info(get_type_name(),"AFTER join_any",UVM_DEBUG);

           //not doing diable fork here because of the 
           wait(vif.PRESETn == 0)begin
               `uvm_info(get_type_name(),"RESET ASSERTED",UVM_FULL);
               vif.PREADY <= '0;
               vif.PSLVERR <= 1'b0;
           end //wait

           //if not waiting for deassertion of the reset then due to the forever loop the loop never 
           //stops and our driver goes into the forever loop 
           wait(vif.PRESETn == 1)begin
               `uvm_info(get_type_name(),"RESET DEASSERTED",UVM_FULL);
               if(rst == 1)begin
                  vif.PREADY <= 1'b1;
               end //if
           end //wait
           `uvm_info(get_type_name(),"AT THE END OF THE OUTER FOREVER LOOP",UVM_FULL);
      end //forever
      `uvm_info(get_type_name(),"OUTSIDE THE FOREVER LOOP",UVM_FULL);
   endtask : run_phase

   task drive_to_inf(apb_slave_trans req);
      `uvm_info(get_type_name(),"TASK drive_to_inf CALLED",UVM_HIGH);
      `uvm_info(get_type_name(),$sformatf("kind_e = %s",req.kind_e),UVM_DEBUG);
      if(req.kind_e == READ)begin
         `uvm_info(get_type_name(),$sformatf("READ DATA PRDATA = %0h",req.PRDATA),UVM_DEBUG);
         wait(vif.PREADY)begin
            `uvm_info(get_type_name(),"SLAVE DRIVER DRIVING THE DATA TO INTERFACE",UVM_FULL);
            vif.PRDATA <= req.PRDATA;
            vif.PSLVERR <= req.PSLVERR;
         end //wait
      end //if

      else begin
         wait(vif.PREADY);
         //d2i = 1'b0;
         if(!vif.PRESETn)begin
            @(posedge vif.PCLK)
               vif.PSLVERR <= req.PSLVERR;
         end //if
                   
         else
            vif.PSLVERR <= req.PSLVERR;
      end //else
   endtask : drive_to_inf
endclass : apb_slave_driver
`endif //: APB_SLAVE_DRIVER



































       /*
       *
          *          fork
       begin
          @(vif.PCLK)
          vif.PREADY <= 1'b1;
          #20;
          vif.PREADY <= 1'b0;
       end
    join_none */


   /*
   *       @(vif.PCLK) begin
      vif.PREADY <= 1'b1;
      #2;
      vif.PREADY <= 1'b0;
      #2;
      vif.PREADY <= 1'b1;
      #5
      vif.PREADY <= 1'b0;
      #4;
      vif.PREADY <= 1'b1;
   end
   * */



  /*
  *
     * class apb_slave_driver extends uvm_driver#(apb_slave_trans);
  // UVM Factory Registration Macro
  //
  `uvm_component_utils(apb_slave_driver);

  //Registration for the callbacks (implemented for ready)
  //
  `uvm_register_cb(apb_slave_driver,apb_slave_drv_cb)

  //virtual interface
  virtual apb_inf vif;

  //Adding get_count to prevent the slave driver to drive the read data every
  //time when reset is assered because the read data should be available when
  //the read transaction is there

  //count for the get_next_item call
  //
  bit get_count;

  //------------------------------------------
  // Methods
  //------------------------------------------

  // Standard UVM Methods: 
  function new(string name = "apb_slave_driver",uvm_component parent);
     super.new(name,parent);
  endfunction : new

  //run_phase
  task run_phase(uvm_phase phase);
     //$display($realtime,"inside run_phase\n");
     fork
        vif.PREADY <= 1'b0;
        @(vif.PCLK) begin
           //calling the hook method for callback
           `uvm_do_callbacks(apb_slave_driver,apb_slave_drv_cb,ready_asrt)
           vif.PREADY <= 1'b1;
        end
        //$display($realtime,"before forever");

     begin
        wait(vif.PRESETn == 0);
        $display($realtime,,,"reset asserted");
     end

     forever begin
        //$display($time,,,,"get");
        seq_item_port.get_next_item(req);
        $display($realtime,"get called");
        get_count = 1;
        //$display($realtime,"inside get next item");
        //$display("get nxt");
        //driving to interface
        drive_to_inf(req);

        seq_item_port.item_done;
        //get_count = 0;
        $display($realtime,"item called");
     end //forever
  join_any
  //not doing diable fork here because of the 
  //disable fork;
  wait(vif.PRESETn == 0)begin
     $display($realtime,,,"reset asserted");
     vif.PREADY <= '0;
     if(get_count)begin
        $display("inside drive");
        if(req.kind_e == READ)
           vif.PRDATA <= '0;
     end //if 
  end //wait

  wait(vif.PRESETn == 1)begin
     vif.PREADY <= '1;
     if(get_count)begin
        $display("inside drive");
        if(req.kind_e == READ)
        end //if 
     end //wait
  endtask : run_phase

  task drive_to_inf(apb_slave_trans req);
     //$display("kind_e = %s",req.kind_e);
     if(req.kind_e == READ)begin
        //$display($realtime,"PRDATA = %0h",req.PRDATA);
        wait(vif.PREADY == 1)begin
           vif.PRDATA <= req.PRDATA;
        end //wait
     end //if 
  endtask : drive_to_inf

endclass : apb_slave_driver

*/
