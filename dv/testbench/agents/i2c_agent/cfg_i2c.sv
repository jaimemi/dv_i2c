class i2c_config extends uvm_object;

    uvm_active_passive_enum active = UVM_ACTIVE;
    int clk_period_ns = 1000;

   `uvm_object_utils_begin(i2c_config)
        `uvm_field_enum(uvm_active_passive_enum, active,        UVM_ALL_ON)
        `uvm_field_int (clk_period_ns, UVM_ALL_ON)
   `uvm_object_utils_end

    function new (string name = "i2c_config");
        super.new(name);
    endfunction: new

endclass