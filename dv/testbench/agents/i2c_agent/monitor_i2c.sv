`ifndef _I2C_MON
`define _I2C_MON

class i2c_monitor extends uvm_monitor;
  `uvm_component_utils(i2c_monitor)

  uvm_analysis_port #(i2c_basic_tr) port;

  virtual dut_if dut_vif;
  i2c_config cfg;

  byte data;
  i2c_basic_tr tr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    assert(uvm_config_db#(virtual dut_if)::get(this, "", "dut_if", dut_vif));  
  endfunction
  
  task run_phase(uvm_phase phase);
    byte         first_byte, second_byte, third_byte;
    logic[4:0]   i2c_addr;
    logic[1:0]   i2c_slv_addr;
    logic        rd_wr, ack;
    bit          start_condition = 0;

    forever begin

      if(!start_condition) begin
        @(negedge dut_vif.sdata iff dut_vif.sclk == 1);
      end

      start_condition = 0;
      tr = new("tr monitor");

      fork
        // PROCESO A: Captura normal de la trama
        begin : transaction_capture
          // Check polarity
          @(negedge dut_vif.sclk);

          //if(dut_vif.sclk) break;
          // Read first byte: addr, r/w
          get_byte(first_byte);
          get_ack(ack);

          i2c_addr = first_byte[7:3];
          i2c_slv_addr = first_byte[2:1];
          rd_wr = first_byte[0];

          // Read second byte: register address
          get_byte(second_byte);
          get_ack(ack);

          // Read third byte: register data
          get_byte(third_byte);
          get_ack(ack);        

          if(i2c_slv_addr == 1) begin
            // Send value from agent through the port
            tr.addr = second_byte;
            tr.data = third_byte;
            tr.read = !rd_wr;
            data = third_byte;

            @(posedge dut_vif.sclk);
            port.write(tr);
            //@(posedge dut_vif.sdata);
          end else begin
            `uvm_info("I2C", $sformatf("Device Addr desconocido : %d", i2c_slv_addr), UVM_LOW)
          end

          `uvm_info("I2C", $sformatf("Mon reads %p", tr), UVM_LOW);
        end

        // PROCESO B: Vigilante de Restart / Start inesperado
        begin : restart_watcher
          // Esperamos primero a que SCL baje para asegurarnos de que estamos DENTRO
          // de la trama actual y no detectamos el mismo Start que lanzó el fork.
          wait(dut_vif.sclk == 0);

          // Ahora vigilamos si aparece un NUEVO Start (SDA baja mientras SCL alto)
          @(negedge dut_vif.sdata iff dut_vif.sclk == 1);
          
          // Si llegamos aquí, hubo un restart.
          start_condition = 1;
          `uvm_info("I2C_MON", "Condición de Restart detectada. Abortando trama actual.", UVM_LOW);
        end // Fin del proceso B
      join_any // Esperamos a que termine CUALQUIERA de los dos
      disable fork; // Matamos el proceso que siga vivo (ej: si hubo restart, matamos la captura)
    end   
  endtask : run_phase

  `include "utils_i2c.sv"

  local task get_ack(output logic ack);
    @(posedge dut_vif.sclk); 
    ack = dut_vif.sdata;
  endtask : get_ack
  
endclass: i2c_monitor

`endif // _I2C_MON
