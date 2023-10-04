////////////////////////////////////////////////
// File:          apb_scoreboard.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB scoreboard file 
/////////////////////////////////////////////////
//
// Class Description:
//
//
`ifndef APB_SCOREBOARD_SV
`define APB_SCOREBOARD_SV
class apb_scoreboard extends uvm_scoreboard;
   // UVM Factory Registration Macro
   //   
   `uvm_component_utils(apb_scoreboard);

   //Analysis implementation for the master monitor
   //
   `uvm_analysis_imp_decl(_apb_mas_mon)
   `uvm_analysis_imp_decl(_apb_slv_mon)

   //Analysis implementation port declaration
   //
   uvm_analysis_imp_apb_mas_mon#(apb_master_trans,apb_scoreboard) mmon_imp;
   uvm_analysis_imp_apb_slv_mon#(apb_slave_trans,apb_scoreboard) smon_imp;

   //Master transaction and Slave transaction class instance
   //
   apb_master_trans mas_trans_h;
   apb_slave_trans slv_trans_h; 

   //Reference model memory
   //
   bit[`DATA_WIDTH-1 : 0] ref_model_mem[int];

   //A variable to store the read data 
   //
   apb_slave_trans act_rd_data;
   bit[`DATA_WIDTH-1 : 0] exp_rd_data;
   bit[`DATA_WIDTH-1 : 0] exp_data;

   //Queue to store the actual data(from DUT)
   //
   apb_slave_trans       act_data_q[$];
   bit[`DATA_WIDTH : 0]  exp_data_q[$];

   //Interface instance
   //
   virtual apb_inf vif;

   //This variable counts the number of pass transactions
   //
   longint pass_count; 

   //This variable counts the number of write padd transactions
   //
   longint write_pass_count;

   //This variable counts the number of pass PSLVERR
   //
   longint pslverr_pass_count;
   
   //This variable holds the READONLY Address
   //
   int ronly_addr = 8'b0;

   //This variable holds the PROTECTED Address
   //
   int protec_addr = 8'd2;

   //MAster agent config class instance
   //
   apb_master_config cfg_h;

   //uvm_pool for taking the write transaction from master driver to scoreboard
   //
   uvm_pool #(bit[`ADDR_WIDTH-1:0],bit[`DATA_WIDTH-1:0]) drv2sb_pool;

   //This variable holds the wirte data for the write comparision
   //
   bit[`DATA_WIDTH-1:0] write_data;

   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_scoreboard",uvm_component parent);
      super.new(name,parent);
      //constructing the implementation ports
      mmon_imp = new("mmon_imp",this);
      smon_imp = new("smon_imp",this);
   endfunction : new

   //build_phase
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      //getting the virtual interface 
      if(!uvm_config_db#(virtual apb_inf)::get(this,"","vif",vif))
         `uvm_fatal(get_type_name,"Not able to get interface");
      `uvm_info(get_type_name(),$sformatf($realtime,"INSIDE BUILD PHASE"),UVM_DEBUG); 

      //Creating the master transaction and salve transaction
      mas_trans_h = apb_master_trans::type_id::create("mas_trans_h"); 
      slv_trans_h = apb_slave_trans::type_id::create("slv_trans_h"); 

      //getting the config class of the master agent to check for active or passive driver
      //
      /*if(!uvm_config_db#(apb_master_config)::get(this,"env_h.apb_muv_h.agent_h[0]","master_cfg",cfg_h))begin
         `uvm_error(get_full_name(),"Unable to get the Master config");
      end // if(get)*/

      //it will retun the global pool
      //
      drv2sb_pool = uvm_pool#(bit[`ADDR_WIDTH-1:0],bit[`DATA_WIDTH-1:0])::get_global_pool();
   endfunction : build_phase 

   //write method implementation of master monitor
   function void write_apb_mas_mon(apb_master_trans mas_trans_h);
      `uvm_info(get_type_name(),"INSIDE MASTER MONITOR WRITE METHOD",UVM_DEBUG);
      //mas_trans_h.print(uvm_default_table_printer);
      
      //if write transaction is there then write inside the reference model memory
      if(mas_trans_h.kind_e == WRITE)begin
         ref_model_mem[mas_trans_h.PADDR] = mas_trans_h.PWDATA;
         `uvm_info(get_type_name(),$sformatf(" WRITE OPERATION ref_model_mem[%0h] = %0h\n",mas_trans_h.PADDR,ref_model_mem[mas_trans_h.PADDR]),UVM_DEBUG);

         //checking the write trnsaction for the only b2b write transaction no read transaction
         //if(cfg_h.is_active == UVM_ACTIVE)begin
            `uvm_info(get_type_name(),$sformatf("mas_trans_h.PADDR = %0d",mas_trans_h.PADDR),UVM_HIGH);
            if(drv2sb_pool.exists(mas_trans_h.PADDR))begin
               `uvm_info(get_type_name(),"drv2eb_pool item exists",UVM_DEBUG);
               //using get method of uvm_pool to get the data from given address
               write_data = drv2sb_pool.get(mas_trans_h.PADDR);
               if(!(mas_trans_h.PWDATA == write_data))begin
                  `uvm_error(get_type_name(),$sformatf("WRITE FAILED!! || DATA MISMATCH ACTUAL PWDATA = %0d EXPECTED PWDATA = %0d\n",mas_trans_h.PWDATA,write_data));
               end //if

               else begin
                  if(!`PASS_COUNT_FULL)
                     write_pass_count++;
                  else begin
                     `uvm_info(get_type_name(),$sformatf("PASSED!! || ONLY WRITE ACTUAL PWDATA = %0d EXPECTED PWDATA = %0d\n",mas_trans_h.PWDATA,write_data),UVM_NONE);
                     `uvm_info(get_type_name(),"PASSED!! || PADDR MATCHED",UVM_HIGH);
                  end //else
               end //else
            end //if
            else
               //add update here to write expected address
               `uvm_error(get_type_name(),$sformatf("WRITE FAILED!! || ADDRESS MISMATCH ACTUAL PADDR = %0d",mas_trans_h.PADDR));
           //write_data = get_global(mas_trans_h
         //end

         //checking for the PSLVERR
         if(mas_trans_h.PSLVERR)begin
            case(mas_trans_h.PADDR)
                     ronly_addr  : begin 
                                    if(`PASS_COUNT_FULL)begin
                                       `uvm_info(get_type_name(),$sformatf("PSLAVERR PASSED!! act PADDR = %0d exp PADDR = %0d\n",mas_trans_h.PADDR,ronly_addr),UVM_NONE);     end 
                                    else 
                                       pslverr_pass_count++;
                                   end
                     protec_addr : begin
                                    if(`PASS_COUNT_FULL)begin
                                       `uvm_info(get_type_name(),$sformatf("PSLAVERR PASSED!! act PADDR = %0d exp PADDR = %0d\n",mas_trans_h.PADDR,protec_addr),UVM_NONE);    end 
                                    else
                                       pslverr_pass_count++;
                                   end
                     default     : begin
                                   `uvm_error(get_type_name(),$sformatf("PSLAVERR IS ASSERTED AT WRONG ADDRESS act PADDR = %0d exp PADDR = %0d\n",act_rd_data.PADDR,ronly_addr)); 
                                   end   
                  endcase

         end //if
      end //if 
   endfunction : write_apb_mas_mon

   //write method implementation of slave monitor
   function void write_apb_slv_mon(apb_slave_trans slv_trans_h);
      `uvm_info(get_type_name(),"INSIDE SLAVE MONITOR WRITE METHOD",UVM_FULL); 
      //slv_trans_h.print(uvm_default_table_printer);

      `uvm_info(get_type_name(),"BEFORE PUSH BACK SB",UVM_FULL);

      //push the actual read data from the slave monitor
      act_data_q.push_back(slv_trans_h);

      //`uvm_info(get_type_name(),$sformatf("pb act_data_q = %p",act_data_q),UVM_DEBUG);
      //`uvm_info(get_type_name(),$sformatf("pr_data = %0d",slv_trans_h.PRDATA),UVM_DEBUG);
      //`uvm_info(get_type_name(),$sformatf("pr_addr = %0d",slv_trans_h.PADDR),UVM_DEBUG);

      //checking the address is exists or not for the read transaction
      if(ref_model_mem.exists(slv_trans_h.PADDR))begin 
         `uvm_info(get_type_name(),"READ ADDRESS EXISTS",UVM_FULL);

         //checking the transaction type if read then store the expected read data into
         //the exp_data variable and then push it in the expected data queue(exp_data_q)
         if(slv_trans_h.kind_e == READ)begin
            `uvm_info(get_type_name(),"READ OPERATION",UVM_DEBUG);
            exp_data = ref_model_mem[slv_trans_h.PADDR]; 
            exp_data_q.push_back(exp_data);
            `uvm_info(get_type_name(),$sformatf("exp_data_q = %p",exp_data_q),UVM_DEBUG);
         end// if i
      end //if o

      //if the address do not exists then push 0 into the expected data queue
      else begin
         `uvm_info(get_type_name(),"READ ADDRESS NOT EXISTS",UVM_FULL);
         exp_data_q.push_back(0);
         `uvm_info(get_type_name(),$sformatf("WHEN ADDR NOT EXISTS exp_data_q = %p",exp_data_q),UVM_DEBUG);
      end //else

      `uvm_info(get_type_name(),$sformatf("act_data_q = %p",act_data_q),UVM_DEBUG);
      `uvm_info(get_type_name(),$sformatf("ref_model_mem = %0p",ref_model_mem),UVM_DEBUG);
   endfunction : write_apb_slv_mon

   //run_phase
   task run_phase(uvm_phase phase);
      `uvm_info(get_type_name(),"INSIDE THE RUN_PHASE",UVM_DEBUG); 
      //every time the scoreboard should ready to accept the transaction so the forever loop
      forever begin
         //using fork join so can reset the reference model memory if the PRESETn is assrted 
         fork
            //wating PRESETn to be assrted
            wait(!vif.PRESETn)begin
               `uvm_info(get_type_name(),$sformatf("BEFORE RESET ref_model_mem = %0p",ref_model_mem),UVM_DEBUG);
               ref_model_mem.delete();
               `uvm_info(get_type_name(),$sformatf("AFTER RESET ref_model_mem = %0p",ref_model_mem),UVM_DEBUG);
            end 

            //wating for the actual data quaue and expected data queue size to be 1 and at same time so the comparision can be done
            wait ((act_data_q.size() && act_data_q.size()) == 1)begin
               //storing the data from the expected data queue and actual data
               //queue in to the respective variables act_rd_data and exp_rd_data also helps while printing the data
               act_rd_data = act_data_q.pop_front();
               if(act_rd_data.PSLVERR != 1'b1) begin
                  //$display("act_rd_dara = %0d",act_rd_data.PADDR);
                  exp_rd_data = exp_data_q.pop_front();

                  //comparing the actual data and expected data
                  if(act_rd_data.PRDATA == exp_rd_data)begin
                     //checking for the macro `PASS_COUNT_FULL for printing to check is the full print is required for the pass or not
                     //if 1 then print full data else print number of pass transactions
                     if(`PASS_COUNT_FULL)begin
                        `uvm_info(get_type_name(),$sformatf(" PASSED || PADDR = %0d, \tPWDATA = %0d, \tPRDATA = %0d \tEXPECTED PRDATA = %0d\n",slv_trans_h.PADDR,slv_trans_h.PWDATA,act_rd_data.PRDATA,exp_rd_data),UVM_NONE);
                        //`uvm_info(get_type_name,"PASSED",UVM_NONE);
                     end // if
                     else begin
                        //counting the no of passed transactions
                        pass_count++;
                     end //else
                  end //if 

                  //for failed transaction whole message will be printed
                     else begin
                        `uvm_info(get_type_name(),$sformatf(" FAILED || PADDR = %0d, \tPWDATA = %0d, \tPRDATA = %0d \tEXPECTED PRDATA = %0d\n", exp_rd_data ,slv_trans_h.PWDATA,act_rd_data.PRDATA,exp_rd_data),UVM_NONE);
                     end //else
                  end //if PSLVERR
               else begin
                  exp_rd_data = exp_data_q.pop_front();

                  case(act_rd_data.PADDR)
                     ronly_addr  : begin 
                                    if(`PASS_COUNT_FULL)begin
                                       `uvm_info(get_type_name(),$sformatf("PSLAVERR PASSED!! act PADDR = %0d exp PADDR = %0d\n",act_rd_data.PADDR,ronly_addr),UVM_NONE);     end
                                    else
                                       pslverr_pass_count++;
                                   end

                     protec_addr : begin
                                    if(`PASS_COUNT_FULL)begin
                                       `uvm_info(get_type_name(),$sformatf("PSLAVERR PASSED!! act PADDR = %0d exp PADDR = %0d\n",act_rd_data.PADDR,protec_addr),UVM_NONE);    end
                                     else 
                                        pslverr_pass_count++;
                                   end
                     default     : begin
                                   `uvm_error(get_type_name(),$sformatf("PSLAVERR IS ASSERTED AT WRONG ADDRESS act PADDR = %0d exp PADDR = %0d\n",act_rd_data.PADDR,ronly_addr));     
                                   end   
                  endcase
                  /*
                  if(act_rd_data.PADDR != ronly_addr)begin
                     `uvm_error(get_type_name(),$sformatf("PSLAVERR IS ASSERTED AT WRONG ADDRESS act PADDR = %0d exp PADDR = %0d",act_rd_data.PADDR,ronly_addr));
                  end
                  else

                     `uvm_error(get_type_name(),$sformatf("PSLAVERR IS ASSERTED AT WRONG ADDRESS act PADDR = %0d exp PADDR = %0d",act_rd_data.PADDR,exp_rd_data));*/
               end //else
            end //wait
         join_any

         //waiting to reset to be deassrted if not waiting then will go in infinite loop
         wait(vif.PRESETn);
      end //forever
   endtask : run_phase

   //extract_phase
   function void extract_phase(uvm_phase phase);
      super.extract_phase(phase);
      //as per the macro printing the pass count
      if(!`PASS_COUNT_FULL)begin
         `uvm_info(get_type_name(),$sformatf(" PASSED || NUMBER OF PASSED ONLY WRITE TRANSACTIONS = %0d\n",write_pass_count),UVM_NONE);
         `uvm_info(get_type_name(),$sformatf(" PASSED || NUMBER OF PASSED B2B WRITE AND READ TRANSACTIONS = %0d\n",pass_count),UVM_NONE);
         `uvm_info(get_type_name(),$sformatf(" PASSED || NUMBER OF PASSED PSLVERR = %0d\n",pslverr_pass_count),UVM_NONE);
      end
   endfunction : extract_phase

   //Report_phase
   function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      //if any one of the queue has some element still left means that means some dealy was there in any one 
      //of the transaction to come at scoreboard 
      if(exp_data_q.size() != 0)begin
         `uvm_fatal(get_type_name(),"EXPECTED DATA QUEUE IS 1");
      end //if 

      else begin
         if(act_data_q.size() != 0)
         `uvm_fatal(get_type_name(),"ACTUAL DATA QUEUE IS 1");
      end //else
   endfunction : report_phase
endclass : apb_scoreboard
`endif //: APB_SCOREBOARD














//sb1
/*
class apb_scoreboard extends uvm_scoreboard;
   // UVM Factory Registration Macro
   //   
   `uvm_component_utils(apb_scoreboard);

   //Analysis implementation for the master monitor
   //
   `uvm_analysis_imp_decl(_apb_mas_mon)
   `uvm_analysis_imp_decl(_apb_slv_mon)

   //Analysis implementation port declaration
   //
   uvm_analysis_imp_apb_mas_mon#(apb_master_trans,apb_scoreboard) mmon_imp;
   uvm_analysis_imp_apb_slv_mon#(apb_slave_trans,apb_scoreboard) smon_imp;

   //Master transaction and Slave transaction class instance
   //
   apb_master_trans mas_trans_h;
   apb_slave_trans slv_trans_h; 

   //Reference model memory
   //
   bit[`DATA_WIDTH : 0] ref_model_mem[int];

   //A variable to store the read data 
   //
   bit[`DATA_WIDTH : 0] act_rd_data;
   bit[`DATA_WIDTH : 0] exp_rd_data;

   //Queue to store the actual data(from DUT)
   //
   bit[`DATA_WIDTH : 0] act_data_q[$];

   //------------------------------------------
   // Methods
   //------------------------------------------

   // Standard UVM Methods:  
   function new(string name = "apb_scoreboard",uvm_component parent);
      super.new(name,parent);
      mmon_imp = new("mmon_imp",this);
      smon_imp = new("smon_imp",this);
   endfunction : new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mas_trans_h = apb_master_trans::type_id::create("mas_trans_h"); 
      slv_trans_h = apb_slave_trans::type_id::create("slv_trans_h"); 
   endfunction : build_phase 

   function void write_apb_mas_mon(apb_master_trans mas_trans_h);
      //$display("---MASTER---\n");
      //mas_trans_h.print(uvm_default_table_printer);
      if(mas_trans_h.kind_e == WRITE);
   begin
      ref_model_mem[mas_trans_h.PADDR] = mas_trans_h.PWDATA;
   end //if 
endfunction : write_apb_mas_mon

function void write_apb_slv_mon(apb_slave_trans slv_trans_h);
   //$display("---SLAVE---");
   //slv_trans_h.print(uvm_default_table_printer);

   if(ref_model_mem.exists(slv_trans_h.PADDR))
   begin 
   //$display("-----------------READ");
   if(slv_trans_h.kind_e == READ)begin
      exp_rd_data = ref_model_mem[slv_trans_h.PADDR];
      act_data_q.push_back(slv_trans_h.PWDATA);
   end// if i
end //if o
else
   exp_rd_data = '0;         

//$display("ref_model_mem = %0p",ref_model_mem);

endfunction : write_apb_slv_mon

task run_phase(uvm_phase phase);
   phase.raise_objection(this);
   forever begin
      wait (act_data_q.size != 0)begin
         act_rd_data = act_data_q.pop_front();
         if(act_rd_data == exp_rd_data)begin
            `uvm_info(get_type_name(),$sformatf("PASSED || PADDR = %0h, PWDATA =%0h, PRDATA = %0h expected PRDATA = %0h",slv_trans_h.PADDR,slv_trans_h.PWDATA,act_rd_data,exp_rd_data),UVM_NONE);//`uvm_info(get_type_name,"PASSED",UVM_NONE);

         end //if 

         else begin
            `uvm_info(get_type_name(),$sformatf("FAILED || PADDR = %0h, PWDATA =%0h, PRDATA = %0h expected PRDATA = %0h",slv_trans_h.PADDR,slv_trans_h.PWDATA,act_rd_data,exp_rd_data),UVM_NONE);
         end //else
      end //wait
   end //forever
   phase.drop_objection(this);
endtask : run_phase
endclass
*/


//sb2
//class apb_scoreboard extends uvm_scoreboard;
// UVM Factory Registration Macro
/*   
`uvm_component_utils(apb_scoreboard);

//Analysis implementation for the master monitor
//
`uvm_analysis_imp_decl(_apb_mas_mon)
`uvm_analysis_imp_decl(_apb_slv_mon)

//Analysis implementation port declaration
//
uvm_analysis_imp_apb_mas_mon#(apb_master_trans,apb_scoreboard) mmon_imp;
uvm_analysis_imp_apb_slv_mon#(apb_slave_trans,apb_scoreboard) smon_imp;

//Master transaction and Slave transaction class instance
//
apb_master_trans mas_trans_h;
apb_slave_trans slv_trans_h; 

//Reference model memory
//
bit[`DATA_WIDTH : 0] ref_model_mem[int];

//A variable to store the read data 
//
bit[`DATA_WIDTH : 0] act_rd_data;
bit[`DATA_WIDTH : 0] exp_rd_data;

//Queue to store the actual data(from DUT)
//
bit[`DATA_WIDTH : 0] act_data_q[$];

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:  
function new(string name = "apb_scoreboard",uvm_component parent);
   super.new(name,parent);
   mmon_imp = new("mmon_imp",this);
   smon_imp = new("smon_imp",this);
endfunction : new

function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   mas_trans_h = apb_master_trans::type_id::create("mas_trans_h"); 
   slv_trans_h = apb_slave_trans::type_id::create("slv_trans_h"); 
endfunction : build_phase 

function void write_apb_mas_mon(apb_master_trans mas_trans_h);
   $display("---MASTER---\n");
   //mas_trans_h.print(uvm_default_table_printer);
   if(mas_trans_h.kind_e == WRITE);
begin
   ref_model_mem[mas_trans_h.PADDR] = mas_trans_h.PWDATA;
end //if 
   endfunction : write_apb_mas_mon

   function void write_apb_slv_mon(apb_slave_trans slv_trans_h);
      //$display("---SLAVE---");
      //slv_trans_h.print(uvm_default_table_printer);

      //$display("before pb");
      act_data_q.push_back(slv_trans_h.PRDATA);
      $display("act_data_q = %p",act_data_q);
      //$display("pb");
      //        $display("pb act_data_q = %p",act_data_q);
      //       $display("pr_data = %0d",slv_trans_h.PRDATA);
      //      $display("pr_addr = %0d",slv_trans_h.PADDR);

      if(ref_model_mem.exists(slv_trans_h.PADDR))
      begin 
      //$display("-----------------READ");
      if(slv_trans_h.kind_e == READ)begin
         exp_rd_data = ref_model_mem[slv_trans_h.PADDR];
      end// if i
   end //if o
   else
      exp_rd_data = '0;         
   //$display("act_data_q = %p",act_data_q);
   //$display("ref_model_mem = %0p",ref_model_mem);
   if (act_data_q.size != 0)begin
      act_data_q.pop_front();
      act_rd_data = act_data_q.pop_front();
      if(act_rd_data == exp_rd_data)begin
         //`uvm_info(get_type_name(),$sformatf("PASSED || PADDR = %0d, PWDATA =%0d, PRDATA = %0d expected PRDATA = %0d",slv_trans_h.PADDR,slv_trans_h.PWDATA,act_rd_data,exp_rd_data),UVM_NONE);
         `uvm_info(get_type_name,"PASSED",UVM_NONE);

      end //if 

      else begin
         `uvm_info(get_type_name(),$sformatf("FAILED || PADDR = %0d, PWDATA =%0d, PRDATA = %0d expected PRDATA = %0d",slv_trans_h.PADDR,slv_trans_h.PWDATA,act_rd_data,exp_rd_data),UVM_NONE);
      end //else
   end //wait
   */
