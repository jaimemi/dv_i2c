class test_device_addr extends base_test;

  `uvm_component_utils(test_device_addr)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  // This function modifies the i2c clk frequency
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    // Rango: De 500ns (1MHz - Muy rápido) a 5000ns (100kHz - Estándar)
    // Nota: 'clk_period_ns' define el semi-periodo (tiempo en alto o bajo), no el periodo total.
    env.agente.cfg.clk_period_ns = 5000;

    `uvm_info(get_name(), $sformatf("Frecuencia I2C modificada. Nuevo periodo: %0d ns", 
                                env.agente.cfg.clk_period_ns), UVM_LOW)
  endfunction
  
  task run_phase(uvm_phase phase);
    i2c_basic_seq seq;
    
    // Definimos la dirección y dato esperados para usarlo en la comprobación
    bit [7:0] rand_device_addr;
    bit [7:0] rand_addr;
    bit [7:0] rand_data;
    bit       rand_rw;   // 0: Write, 1: Read
    int       num_transacciones = 50; // Número de pruebas a realizar

    phase.raise_objection(this);

    #20ns // Esperar al reset

    `uvm_info(get_name(), $sformatf(" ** INICIANDO TEST OTHER I2C ADDR **"), UVM_LOW)

    repeat(num_transacciones) begin
      // 1. Aleatorizacion
      rand_device_addr = $urandom_range(2, 3); // Solo se cogen posiciones 1 y 2
      rand_addr = $urandom(); 
      rand_data = $urandom();           
      rand_rw   = $urandom();

      // 2. Creación de la secuencia
      seq = i2c_basic_seq::type_id::create("seq");
      seq.i2c_device_addr = rand_device_addr;
      seq.i2c_addr = rand_addr;
      seq.i2c_read = rand_rw; // 0: Write, 1: Read
      if (rand_rw == 0) begin
          seq.i2c_data = rand_data;
          `uvm_info("TEST_RND", $sformatf("[WRITE] I2C Addr : 0x%0h | Addr: 0x%0h | Data: 0x%0h", rand_device_addr, rand_addr, rand_data), UVM_LOW)
      end else begin
          top.reg_memory = rand_data;
          `uvm_info("TEST_RND", $sformatf("[READ] I2C Addr : 0x%0h | Addr: 0x%0h | Data: 0x%0h", rand_device_addr, rand_addr, rand_data), UVM_LOW)
      end

      // 3. Ejecución
      seq.start(env.agente.sequencer);

      #5000ns;

      `uvm_info(get_name(), $sformatf(" ** INICIANDO RETRY **"), UVM_LOW)

      seq.i2c_device_addr = 1;

      seq.start(env.agente.sequencer);
    end

    `uvm_info(get_name(), "  ** TEST OTHER I2C ADDRESS COMPLETADO **", UVM_LOW)
 	  
    phase.drop_objection(this);
  endtask
endclass : test_device_addr
