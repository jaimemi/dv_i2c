typedef class i2c_basic_seq;
class i2c_adapter extends uvm_reg_adapter;
	`uvm_object_utils(i2c_adapter)

	function new(string name = "i2c_adapter");
		super.new(name);
	endfunction
  
    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        i2c_basic_tr tr = i2c_basic_tr::type_id::create("tr reg2bus");
		
		tr.addr = rw.addr;
		tr.read = (rw.kind == UVM_READ);
		if(rw.kind == UVM_WRITE) tr.data = rw.data;

		return tr;
    endfunction
	
    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        i2c_basic_tr tr;
		
		if(!$cast(tr, bus_item)) begin
			`uvm_fatal("ADAPTER", "Bus item is not i2c seq")
		end
		
		rw.kind = (tr.read == 1) ? UVM_READ : UVM_WRITE;
		rw.addr = tr.addr;
		rw.data = tr.data;
		rw.n_bits = 8;
		rw.status = UVM_IS_OK;
    endfunction
	
endclass
