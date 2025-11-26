`ifndef _DUT_IF
`define _DUT_IF

interface dut_if();
  logic clk;		//chip clock
  logic reset_n;	//chip reset
  
  //other signals?
  
  tri1 sclk;
  tri1 sdata;   //be aware with inout signals. It is an opendrain that must be driven by someone continiuously
  
  //internal variables to manage inout signals
  logic sda_drive;			//I2C interface. data
  logic scl_drive;			//I2C interface. clock
      
  logic sda_val;
  logic scl_val;

  // Test information
  logic [7:0] reg_addr_wire;
  logic       wr1rd0_wire;
  logic [7:0] reg_wr_data_wire;
  logic       reg_req_wire;
  logic [7:0] reg_rd_data_wire;
  logic [6:0] i2c_addr_wire = 7'd1;
  
  //glue logic
  assign sdata = sda_drive ? sda_val : 'z;
  assign sclk = scl_drive ? scl_val : 'z;

endinterface

`endif // _DUT_IF
