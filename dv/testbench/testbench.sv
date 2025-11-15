import uvm_pkg::*;
`include "uvm_macros.svh"

`include "dut_if.sv"
`include "lib_test.sv"
//`include "adc_dms_model.sv"

module top;
  //dut if instance
  dut_if dut_if();
  environment env;
  //dut instance
  initial begin
    dut_if.clk = 0;
    forever #1ns dut_if.clk = ~dut_if.clk;
  end
  //other instances?
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    $shm_open("waves.shm");
    $shm_probe("ASM");
	//reset?
    dut_if.reset_n = 0;
    repeat(5) @(posedge dut_if.clk);
    dut_if.reset_n = 1;
  end
  
  initial begin
	//interface to database?
    uvm_config_db#(virtual dut_if)::set(null, "*", "dut_if", dut_if);
    run_test(); //+UVM_TESTNAME=test_dummy
  end
    
endmodule : top
