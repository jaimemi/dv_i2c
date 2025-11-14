`include "agent_i2c.sv"

class environment extends uvm_env;  
  `uvm_component_utils(environment)
  
  //agents
  i2c_agent agente;

  virtual dut_if dut_vif;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
	
  function void build_phase(uvm_phase phase);
	//create other agents
    agente = i2c_agent::type_id::create("agt", this);
    // scb = my_scoreboard::type_id::create("scb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    //get interface from database 
    agente.driver.dut_vif = dut_vif;
    // agente.monitor.port.connect(scb.fifo_seq.analysis_export);
  endfunction
endclass : environment
