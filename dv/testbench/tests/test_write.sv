class test_write extends base_test;

  `uvm_component_utils(test_write)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    i2c_basic_seq seq;
    // Definimos la dirección y dato esperados para usarlo en la comprobación
    byte addr_chk = 8'h01;
    byte data_chk = 8'h55;

    phase.raise_objection(this);
    `uvm_info(get_name(), "  ** INICIANDO TEST WRITE **", UVM_LOW)

    // 1. Crear y configurar la secuencia de ESCRITURA
    seq = i2c_basic_seq::type_id::create("seq");
    seq.i2c_addr = addr_chk; 
    seq.i2c_data = data_chk; 
    seq.i2c_read = 1'b0; // Write!

    `uvm_info(get_name(), $sformatf("Escribiendo 0x%0h en dirección 0x%0h...", data_chk, addr_chk), UVM_LOW)

    // 2. Lanzar la secuencia
    seq.start(env.agente.sequencer);

    // 3. Esperar un poco para asegurar que la transacción ha terminado y el TB ha capturado el dato
    #10us;

    // 4. CHECKER DIRECTO CON LABEL
    // El label 'reg_write_chk' servirá para el vPlan.
    reg_write_chk: assert(top.fake_registers[addr_chk] == data_chk) 
      else `uvm_error("CHECKER", $sformatf("FALLO: En addr %0h se leyó %0h, se esperaba %0h", 
                                           addr_chk, top.fake_registers[addr_chk], data_chk));

    `uvm_info(get_name(), "  ** TEST WRITE COMPLETADO **", UVM_LOW)

 	  phase.drop_objection(this);
  endtask
endclass : test_write
