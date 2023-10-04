////////////////////////////////////////////////
// File:          apb_defines.sv
// Version:       v1
// Developer:     Mayank
// Project Name:  APB3 Protocol
// Discription:   Defines File 
/////////////////////////////////////////////////

//
// APB Define file:
//
//

   //Enum that indicates the transaction type
   typedef enum bit {READ,WRITE} trans_kind_e;

   //Address and Data width
   `define ADDR_WIDTH 8
   `define DATA_WIDTH 8
   `define APB_CLK_FREQ (1*(10**8)) //100Mhz 
   `define READY_TIMEOUT 10
   `define PASS_COUNT_FULL 0
   `define DRV_CB vif.DRV_MP.drv_cb
   `define MON_CB vif.DRV_MP.mon_cb

