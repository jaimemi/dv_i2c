class test_dummy extends base_test;

  `uvm_component_utils(test_dummy)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  task run_phase(uvm_phase phase);
    i2c_basic_seq seq;
    // Definimos la dirección y dato esperados para usarlo en la comprobación
    byte addr_chk = 8'h01;
    byte data_chk = 8'h55;

    phase.raise_objection(this);
    `uvm_info(get_name(), "  ** INICIANDO TEST DUMMY **", UVM_LOW)

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

    // 4. CHECKER: Accedemos jerárquicamente al array del Testbench
    // Nota: 'top' es el nombre del módulo en testbench.sv y 'reg_rd_data_wire' el array que creaste.
    if (top.reg_rd_data_wire[addr_chk] !== data_chk) begin
      `uvm_error("CHECKER", $sformatf("FALLO: El reg_rd_data_wire[%0h] tiene 0x%0h, se esperaba 0x%0h", 
                                      addr_chk, top.reg_rd_data_wire[addr_chk], data_chk))
    end else begin
      `uvm_info("CHECKER", $sformatf("EXITO: El reg_rd_data_wire[%0h] se actualizó correctamente a 0x%0h", 
                                     addr_chk, top.reg_rd_data_wire[addr_chk]), UVM_LOW)
    end

    `uvm_info(get_name(), "  ** TEST DUMMY COMPLETADO **", UVM_LOW)

 	  phase.drop_objection(this);
  endtask
endclass : test_dummy
