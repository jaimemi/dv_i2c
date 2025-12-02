`ifndef I2C_COVERAGE
`define I2C_COVERAGE

class i2c_coverage extends uvm_subscriber #(i2c_basic_tr);
  `uvm_component_utils(i2c_coverage)

  i2c_basic_tr tr;

  covergroup i2c_cg;
    option.per_instance = 1;

    // Cubrimos TODO el rango de 8 bits (0 a 255).
    // 'bins addr[]' crea un contenedor individual para CADA dirección.
    // Así podrás ver exactamente qué direcciones has tocado y cuáles te faltan.
    // Si prefieres agruparlas para que sea más fácil llegar al 100%, puedes usar 'auto_bin_max'.
    cp_addr: coverpoint tr.addr {
      bins valid_addr[] = {[0:255]}; 
    }

    // Operación (Lectura vs Escritura)
    cp_rw: coverpoint tr.read {
      bins write = {0};
      bins read  = {1};
    }

    // Cross: ¿Hemos hecho RW en cada una de las 256 direcciones?
    // (Nota: Esto genera 256 * 2 = 512 objetivos de cobertura)
    cross_addr_rw: cross cp_addr, cp_rw;

  endgroup : i2c_cg

  function new(string name, uvm_component parent);
    super.new(name, parent);
    i2c_cg = new();
  endfunction : new

  virtual function void write(i2c_basic_tr t);
    this.tr = t;
    i2c_cg.sample();
    `uvm_info("COV", $sformatf("Sampleado Addr: %0h, Read: %0b", t.addr, t.read), UVM_HIGH)
  endfunction : write

endclass : i2c_coverage

`endif