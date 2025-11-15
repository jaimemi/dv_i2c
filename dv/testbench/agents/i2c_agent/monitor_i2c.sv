`ifndef _I2C_MON
`define _I2C_MON

class i2c_monitor extends uvm_monitor;
  `uvm_component_utils(i2c_monitor)

  uvm_analysis_port #(i2c_basic_tr) port;
  virtual dut_if dut_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    assert(uvm_config_db#(virtual dut_if)::get(this, "", "dut_if", dut_vif));  
  endfunction
  
  task run_phase(uvm_phase phase);
    fork
      @(posedge dut_vif.reset_n);
      forever begin
        // Definir variables de lectura
        i2c_basic_tr tr;

        logic [7:0] byte_addr, byte_reg, byte_data;
        logic ack1, ack2, ack3;

        tr = i2c_basic_tr::type_id::create("tr");

        // Decodificar datos
        wait_for_start();

        get_byte(byte_addr);
        get_ack(ack1);
      
        get_byte(byte_reg);
        get_ack(ack2);
      
        get_byte(byte_data);
        get_ack(ack3);

        wait_for_stop();

        // Rellenar lla transacción con los datos observados
        tr.device_addr = byte_addr[7:1];
        tr.read        = byte_addr[0];
        tr.addr        = byte_reg;
        tr.data        = byte_data;

        // Linea de datos baja. Esperar.
        `uvm_info(get_type_name(), $sformatf("Transacción I2C detectada: %s", tr.sprint()), UVM_HIGH)
        port.write(tr);

      end
    join_none;    
  endtask : run_phase

  local task wait_for_start();
    `uvm_info(get_type_name(), "Monitor: Esperando START", UVM_HIGH)
    forever begin
      @(negedge dut_vif.sda_val); // Espera a que SDA baje
      if (dut_vif.scl_val == 1) begin // Comprueba si SCL estaba alto
        `uvm_info(get_type_name(), "Monitor: START detectado", UVM_HIGH)
        break; // ¡Es un START! Salir del bucle.
      end
    end
  endtask

  local task get_byte(output logic [7:0] byte_out);
    for (int i = 0; i < 8; i++) begin
      // Los datos se leen en el flanco de subida de SCL
      @(posedge dut_vif.scl_val);
      byte_out[7-i] = dut_vif.sda_val;
      @(negedge dut_vif.scl_val);
    end
  endtask
  
  local task get_ack(output logic ack);
    // El ACK se lee en el 9º flanco de subida
    @(posedge dut_vif.scl_val);
    ack = dut_vif.sda_val;
    @(negedge dut_vif.scl_val);
  endtask

  local task wait_for_stop();
    `uvm_info(get_type_name(), "Monitor: Esperando STOP", UVM_HIGH)
    forever begin
      @(posedge dut_vif.sda_val); // Espera a que SDA suba
      if (dut_vif.scl_val == 1) begin // Comprueba si SCL estaba alto
        `uvm_info(get_type_name(), "Monitor: STOP detectado", UVM_HIGH)
        break; // ¡Es un STOP! Salir del bucle.
      end
    end
  endtask
  
endclass: i2c_monitor

`endif // _I2C_MON
