`ifndef _I2C_SEQ
`define _I2C_SEQ

`include "transaction_i2c.sv"

class i2c_basic_seq extends uvm_sequence#(i2c_basic_tr);
  byte i2c_device_addr = 1; // Master & Slave Addres
  byte i2c_addr;  //register address
  byte i2c_data;  //register value
  bit i2c_read = 0;   //1: read; 0: write
  bit i2c_force_abort = 0; // Force message abort
  
  `uvm_object_utils(i2c_basic_seq)
  
  function new(string name = "i2c_basic_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "i2c_basic_seq created", UVM_LOW)
    `uvm_do_with(req, { req.addr == i2c_addr;
                    req.data == i2c_data;
                    req.read == i2c_read; 
                    req.device_addr == i2c_device_addr;
                    req.force_abort == i2c_force_abort;});
  endtask : body
endclass : i2c_basic_seq

`endif // _I2C_SEQ
