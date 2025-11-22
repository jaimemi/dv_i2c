`ifndef _I2C_AGT
`define _I2C_AGT

class i2c_agent extends uvm_agent;
  `uvm_component_utils(i2c_agent)
    
  //instanciate components
  i2c_driver driver;
  uvm_sequencer#(i2c_basic_tr) sequencer;
  i2c_monitor monitor;
  i2c_config cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
    
  function void build_phase(uvm_phase phase);
    //create components
    monitor = i2c_monitor::type_id::create("i2c_mon", this);
    cfg = i2c_config::type_id::create("i2c_cfg", this);

    if(cfg.active) begin
      sequencer = uvm_sequencer#(i2c_basic_tr)::type_id::create("sequencer", this);
      driver = i2c_driver::type_id::create("i2c_drv", this);
    end
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    //connect driver
    super.connect_phase(phase);

    monitor.cfg = cfg;

    if(cfg.active) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
      driver.cfg = cfg;
    end
  endfunction : connect_phase
    
  task run_phase(uvm_phase phase);
  endtask : run_phase

endclass : i2c_agent

`endif  // _I2C_AGT
