class test_dummy extends base_test;

  `uvm_component_utils(test_dummy)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    i2c_basic_seq seq;

    phase.raise_objection(this);
    `uvm_info(get_name(), "  ** INICIANDO TEST DUMMY **", UVM_LOW)

    seq = i2c_basic_seq::type_id::create("seq");

    seq.i2c_addr = 8'h01; 
    seq.i2c_data = 8'h55; 
    seq.i2c_read = 1'b0;

    `uvm_info(get_name(), "Enviando secuencia al driver...", UVM_LOW)
    seq.start(env.agente.sequencer);

	  #50us;
    
 	  `uvm_info(get_name(), "  ** TEST DUMMY COMPLETADO **", UVM_LOW)
 	  phase.drop_objection(this);
  endtask
endclass : test_dummy
