`ifndef _I2C_SCB
`define _I2C_SCB

class i2c_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(i2c_scoreboard)

    // 1. Puerto para recibir datos del Monitor
    //    Usa uvm_analysis_imp porque este componente IMPLEMENTA la función write()
    uvm_analysis_imp #(i2c_basic_tr, i2c_scoreboard) item_collected_export;

    virtual dut_if dut_vif;

    // Memoria interna que almacena resultados esperados

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_export = new("item_collected_export", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        assert(uvm_config_db#(virtual dut_if)::get(this, "", "dut_if", dut_vif));  
    endfunction

    // 3. Función write: Se ejecuta automáticamente CADA VEZ que el monitor envía algo
    virtual function void write(i2c_basic_tr tr);

        reg_addr_check: assert(tr.addr == dut_vif.reg_addr_wire)
            else `uvm_error("CHECKER", $sformatf("FALLO: En addr %0h. El DUT decodificó %0h", 
                                                    tr.addr, dut_vif.reg_addr_wire));
        
        if (tr.read) begin
            // --- CASO LECTURA ---
            reg_read_chk: assert(tr.data == dut_vif.reg_rd_data_wire) 
                else `uvm_error("CHECKER", $sformatf("FALLO: En addr %0h se leyó %0h, se esperaba %0h", 
                                                    tr.addr, tr.data, dut_vif.reg_rd_data_wire));
        end else begin
            // --- CASO LECTURA ---
            reg_write_chk: assert(dut_vif.reg_wr_data_wire == tr.data) 
                else `uvm_error("CHECKER", $sformatf("FALLO: En addr %0h se leyó %0h, se esperaba %0h", 
                                                    tr.addr, dut_vif.reg_wr_data_wire, tr.data));
        end
        
    endfunction

endclass : i2c_scoreboard

`endif // _I2C_SCB