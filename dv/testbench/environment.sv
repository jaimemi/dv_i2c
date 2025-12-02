import i2c_pkg::*;
import uvm_pkg::*; 
`include "uvm_macros.svh"

class environment extends uvm_env;  
  `uvm_component_utils(environment)
  
  //agent
  i2c_agent agente;
  //scoreboard
  i2c_scoreboard scb;
  //coverage
  i2c_coverage cov;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
	
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	  //create other agents
    agente = i2c_agent::type_id::create("agt", this);
    // scb = my_scoreboard::type_id::create("scb", this);
    scb = i2c_scoreboard::type_id::create("scb", this);
    cov = i2c_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // agente.monitor.port.connect(scb.fifo_seq.analysis_export);
    // El puerto del monitor se llama 'port' (ver monitor_i2c.sv)
    // El puerto del scoreboard lo hemos llamado 'item_collected_export'
    agente.monitor.port.connect(scb.item_collected_export);
    // El 'analysis_export' viene gratis al heredar de uvm_subscriber
    agente.monitor.port.connect(cov.analysis_export);
  endfunction
endclass : environment
