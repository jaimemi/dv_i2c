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
  logic [7:0] reg_rd_data_wire;
  logic [6:0] i2c_addr_wire = 7'd1; // Dirección del I2C slave

   logic [7:0] fake_registers [0:255]; // Simulacion de registros

  environment env;
  //dut instance
  i2c_slave dut(
    .SDA(vif.sdata), // Bus SDA
    .SCL(vif.sclk), // Bus SCL
    .rst_n(vif.reset_n), // Reset del i2c slave
    .address(i2c_addr_wire), // Address del i2c slave aportado por el testbench
    .reg_addr(reg_addr_wire), // Direccion del registro leida por i2c slave
    .wr1rd0(wr1rd0_wire), // i2c_slave: 1 si la operación es de escritura, 0 si es de lectura
    .reg_wr_data(reg_wr_data_wire), // el i2c_slave decodifica la informacion a escribir en el registro
    .reg_rd_data(reg_rd_data_wire), // Base de datos que sirve como simulacion de registros
    .reg_req(reg_req_wire) // i2c_slave: Indica al reg_block que puede leer/escribir en un address.
  );
  //other instances?

  // Clock
  initial begin
    vif.clk = 0;
    forever #1ns vif.clk = ~vif.clk;
  end
  
  // Waves
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

  // Initialize fake_registers
  initial begin
      foreach(fake_registers[i]) fake_registers[i] = 0;
  end

  // Write fake_registers from dut
  always @(posedge vif.clk) begin
    if (reg_req_wire && wr1rd0_wire) begin
      fake_registers[reg_addr_wire] = reg_wr_data_wire;
      $display("Escritura en addr %0h: %0h", reg_addr_wire, reg_wr_data_wire);
    end
  end

  // Read fake_registers from dut
  assign reg_rd_data_wire = fake_registers[reg_addr_wire];


    
endmodule : top
