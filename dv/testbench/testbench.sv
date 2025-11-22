import uvm_pkg::*;
`include "uvm_macros.svh"

`include "dut_if.sv"
`include "package_i2c.sv"
`include "lib_test.sv"
//`include "adc_dms_model.sv"

module top;
  //dut if instance
  dut_if vif();

  logic [7:0] reg_addr_wire;
  logic       wr1rd0_wire;
  logic [7:0] reg_wr_data_wire;
  logic       reg_req_wire;
  logic [7:0] reg_rd_data_wire = '0; // No hay reg_block
  logic [6:0] i2c_addr_wire = 7'd1; // Dirección del I2C slave

  environment env;
  //dut instance
  i2c_slave dut(
    .SDA(vif.sdata),
    .SCL(vif.sclk),
    .rst_n(vif.reset_n),
    .address(i2c_addr_wire),
    .reg_addr(reg_addr_wire), // La dirección se ha leido correctamente
    .wr1rd0(wr1rd0_wire), // 1 si la operación es de escritura, 0 si es de lectura
    .reg_wr_data(reg_wr_data_wire), // Decodifica la info que escribe el maestro por I2C para que se guarde en el reg_block.
    .reg_rd_data(reg_rd_data_wire), // Obtiene la información del registro
    .reg_req(reg_req_wire) // Indica al reg_block que puede leer/escribir en un address.
  );
  //other instances?

  // Clock
  initial begin
    vif.clk = 0;
    forever #1ns vif.clk = ~vif.clk;
  end
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    $shm_open("waves.shm");
    $shm_probe("ASM");
	//reset?
    vif.reset_n = 0;
    repeat(5) @(posedge vif.clk);
    vif.reset_n = 1;
  end
  
  initial begin
	//interface to database?
    uvm_config_db#(virtual dut_if)::set(null, "*", "dut_if", vif);
    run_test(); //+UVM_TESTNAME=test_dummy
  end
    
endmodule : top
