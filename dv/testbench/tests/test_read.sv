class test_read extends base_test;

  `uvm_component_utils(test_read)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  // This function modifies the i2c clk frequency
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    // Jerarquical access to config within agent
    // env -> agente -> cfg -> variable; 
    env.agente.cfg.clk_period_ns = 5000;

    `uvm_info(get_name(), $sformatf("Frecuencia I2C modificada. Nuevo periodo: %0d ns", 
                                env.agente.cfg.clk_period_ns), UVM_LOW)
  endfunction
  
  task run_phase(uvm_phase phase);
    i2c_basic_seq seq;
    // Definimos la dirección y dato esperados para usarlo en la comprobación
    byte addr_chk = 8'h03;
    byte data_chk = 8'hA5;

    phase.raise_objection(this);

    #20ns // Esperar al reset

    `uvm_info(get_name(), "  ** INICIANDO TEST READ **", UVM_LOW)

    // PREPARACIÓN: Escribimos 'backdoor' en la memoria del TB
    // Esto simula que el registro ya tiene el valor 0xA5 guardado.
    `uvm_info(get_name(), $sformatf("Pre-cargando memoria TB: addr %0h = %0h", addr_chk, data_chk), UVM_LOW)

    //0. Cargar el registro de lectura del DUT
    top.reg_memory = data_chk;
    
    // 1. Crear y configurar la secuencia de LECTURA
    seq = i2c_basic_seq::type_id::create("seq");
    seq.device_addr = 1;
    seq.i2c_addr = addr_chk; 
    seq.i2c_read = 1'b1; // Read!
    seq.force_abort = 0;

    `uvm_info(get_name(), $sformatf("Leyendo 0x%0h de la dirección 0x%0h...", data_chk, addr_chk), UVM_LOW)

    // 2. Lanzar la secuencia
    seq.start(env.agente.sequencer);

    // 3. Esperar un poco para asegurar que la transacción ha terminado y el TB ha capturado el dato
    #10us;

    `uvm_info(get_name(), "  ** TEST READ COMPLETADO **", UVM_LOW)

 	  phase.drop_objection(this);
  endtask
endclass : test_read
