`ifndef _I2C_DRV
`define _I2C_DRV

class i2c_driver extends uvm_driver #(i2c_basic_tr);
  i2c_basic_tr req;
  int period_ns = 1000;
  `uvm_component_utils(i2c_driver)

  virtual dut_if dut_vif;
  i2c_config cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    assert(uvm_config_db#(virtual dut_if)::get(this, "", "dut_if", dut_vif));  
  endfunction

  task run_phase(uvm_phase phase);
    byte         first_byte, second_byte, third_byte;
    bit          ack;

    period_ns = cfg.clk_period_ns;
    dut_vif.scl_drive = 1;
    forever begin
      fork
        forever begin
          dut_vif.scl_drive = 0;
          dut_vif.sda_val = 0;
          dut_vif.sda_drive = 0;

          seq_item_port.get_next_item(req);
          `uvm_info("I2C", $sformatf("Drv writes %p", req), UVM_LOW);
          dut_vif.scl_drive = 1;

          // Send device address and r/w operation
          first_byte = {req.device_addr[6:0], !req.read};
          set_start(period_ns);
          set_byte(first_byte, period_ns);
          get_ack(ack, period_ns);
          //if(!ack == 0) break;

          // Send register address
          second_byte = req.addr;
          set_byte(second_byte, period_ns);
          get_ack(ack, period_ns);

          if(req.read) begin
            // Read operation --> for RAL read operation it's needed to get_byte
            fork
              set_byte(8'bz, period_ns);
              get_byte(third_byte);
            join
            set_ack(ack, period_ns);
            req.data = third_byte;  //for RAL, otherwise, it will read always 0
          end else begin
            // Write operation --> send register value
            third_byte = req.data;
            set_byte(third_byte, period_ns);
            get_ack(ack, period_ns);
          end

          //Stop condition
          set_stop(period_ns);
          #2 seq_item_port.item_done();
        end
      join_any;
      disable fork; 
    end
  endtask : run_phase
  
  `include "utils_i2c.sv"

  local task get_ack(output logic ack, input int period_ns=1000); // set ack?
    dut_vif.sda_drive = 0;
    dut_vif.scl_val = 0;
    #(period_ns*1ns);
    dut_vif.scl_val = 1;
    #(period_ns*1ns);
    dut_vif.scl_val = 0;
    #(period_ns*1ns);
    ack = dut_vif.sdata;
  endtask
  
endclass: i2c_driver

`endif // _I2C_DRV
