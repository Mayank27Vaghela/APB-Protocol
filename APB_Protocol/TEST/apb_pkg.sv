///////////////////////////////////////////////
// File:          apb_pkg.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   APB package file 
/////////////////////////////////////////////////

//
// Package Discription:
//

`ifndef APB_PKG_SV
`define APB_PKG_SV

`include "apb_defines.sv"
`include "apb_inf.sv"
package apb_pkg;
   //header files
   import uvm_pkg::*;
   `include "uvm_macros.svh"
   
   //Global defines file
   `include "apb_defines.sv"

   //Agent configuration file
   `include "apb_master_config.sv"
   `include "apb_slave_config.sv"

   //Master and slave transaction files  
   `include "apb_master_trans.sv"
   `include "apb_slave_trans.sv"

   //master and  slave sequencer files
   `include "apb_master_sequencer.sv"
   `include "apb_slave_sequencer.sv"

   `include "apb_master_drv_cb.sv"

   //Master files
   `include "apb_master_driver.sv"
   `include "apb_master_monitor.sv"
   `include "apb_master_agent.sv"
   `include "apb_master_uvc.sv"

   `include "apb_slave_drv_cb.sv"

   //Slave files
   `include "apb_slave_driver.sv"
   `include "apb_slave_monitor.sv"
   `include "apb_slave_agent.sv"
   `include "apb_slave_uvc.sv"

   //Scoreboard and subscriber
   `include "apb_scoreboard.sv"
   `include "apb_subscriber.sv"

   //Environment and Testcases seuqences
   `include "apb_env.sv"

   //callback files
   `include "apb_slave_ready_cb.sv"
   `include "apb_master_imp_cb.sv"
   `include "apb_slave_r_wait_cb.sv"
   `include "apb_write_seq.sv"
   `include "apb_read_seq.sv"
   `include "apb_wr_seq.sv"
   `include "apb_wrr_seq.sv"
   `include "apb_werr_seq.sv"
   `include "apb_rerr_seq.sv"
   `include "apb_slv_base_seq.sv"

   //Testcases   
   `include "apb_base_test.sv"
   `include "apb_write_test.sv"
   `include "apb_wwait_test.sv"
   `include "apb_read_test.sv"
   `include "apb_rwait_test.sv"
   `include "apb_wr_test.sv"
   `include "apb_wrst_test.sv"
   `include "apb_wrwait_test.sv"
   `include "apb_werr_test.sv"
   `include "apb_rerr_test.sv"
   `include "apb_wrerr_test.sv"
   `include "apb_mix_test.sv"
   `include "apb_m_drverr_test.sv"
endpackage : apb_pkg
`endif //APB_PKG
