import uvm_pkg::*;
`include "uvm_macros.svh"

`include "dut_if.sv"
`include "lib_test.sv"
//`include "adc_dms_model.sv"

module top;
  //dut if instance
  dut_if dut_if();
  //dut instance
  //----- Conectar interfaz
  //----- Poner interfaz en config database
  //other instances?

  // Clock
  bit clk;
  always #2 clk <= ~clk;
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    $shm_open("waves.shm");
    $shm_probe("ASM");
	//reset?
  end
  
  initial begin
	//interface to database?
    run_test(); //+UVM_TESTNAME=test_dummy
  end
    
endmodule : top
