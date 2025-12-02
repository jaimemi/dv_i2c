class test_all extends base_test;

  `uvm_component_utils(test_all)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  // Configuración inicial estándar (sin randomizar el reloj en cada vuelta)
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    env.agente.cfg.clk_period_ns = 2000; // Una velocidad media segura
    `uvm_info(get_name(), "Configuración: Clock Fijo a 2000ns", UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
    i2c_basic_seq seq;
    
    // Variables para la aleatorización
    bit [7:0] rand_addr;
    bit [7:0] rand_data;
    bit       rand_rw;       // 0: Write, 1: Read
    bit       rand_abort;    // 1: Cortar trama
    byte      rand_dev_addr; // Dirección del dispositivo
    
    int       iteraciones = 400; // Número de pruebas

    phase.raise_objection(this);
    #20ns; 

    `uvm_info("TEST_ALL", $sformatf(" ** INICIANDO SUPER-TEST SIN CLK (%0d iters) **", iteraciones), UVM_LOW)

    repeat(iteraciones) begin
        
        // 1. ALEATORIZACIÓN
        rand_addr = $urandom(); 
        rand_data = $urandom();           
        
        // 70% Escritura (Write), 30% Lectura (Read)
        rand_rw = ($urandom_range(0, 100) < 30) ? 1 : 0; 
        
        // 10% de probabilidad de ABORTAR la trama
        rand_abort = ($urandom_range(0, 100) < 10) ? 1 : 0;

        // 5% de probabilidad de dirección de dispositivo ERRÓNEA (!= 1)
        if ($urandom_range(0, 100) < 5) rand_dev_addr = $urandom_range(2, 3);
        else                            rand_dev_addr = 1;


        // 2. CONFIGURACIÓN DE LA SECUENCIA
        seq = i2c_basic_seq::type_id::create("seq");
        
        // Asignamos a las variables de la secuencia (según tu seq_i2c.sv)
        seq.i2c_device_addr = rand_dev_addr;
        seq.i2c_addr    = rand_addr;
        seq.i2c_data    = rand_data;
        seq.i2c_read    = rand_rw;
        seq.i2c_force_abort = rand_abort;


        // 3. GESTIÓN DE LA MEMORIA DEL TESTBENCH
        // Solo actualizamos la memoria si la transacción va a ser VÁLIDA y de ESCRITURA.
        // Si abortamos o la dirección del chip está mal, el DUT no guardará nada.
        if (rand_abort == 0 && rand_dev_addr == 1) begin
            if (rand_rw == 0) begin
                // WRITE: El DUT guardará el dato, así que actualizamos nuestro mapa para el Scoreboard
                `uvm_info("TEST_ALL", $sformatf("[WRITE] Addr:0x%0h Data:0x%0h", rand_addr, rand_data), UVM_HIGH)
            end else begin
                // READ: No tocamos la memoria (leemos lo que haya).
                // El Scoreboard verificará si coincide con lo que escribimos antes.
                top.reg_memory = rand_data;
                `uvm_info("TEST_ALL", $sformatf("[READ ] Addr:0x%0h", rand_addr), UVM_HIGH)
            end
        end else begin
             // Log de inyección de error
             `uvm_info("TEST_ALL", $sformatf("[ERROR] Abort:%0b DevAddr:0x%0h", rand_abort, rand_dev_addr), UVM_HIGH)
        end

        // 4. EJECUCIÓN
        seq.start(env.agente.sequencer);
        
        // // Tiempo muerto para asegurar que el bus se libera tras un abort
        // #2000ns; 
    end

    `uvm_info("TEST_ALL", "  ** SUPER-TEST COMPLETADO **", UVM_LOW)
 	  phase.drop_objection(this);
  endtask
endclass : test_all