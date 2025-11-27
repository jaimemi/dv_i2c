local task get_byte(output logic [7:0] b);
  b = 0;
  repeat(8) begin
      b = (b << 1);   //serialize -> shift
      @(posedge dut_vif.sclk); 
      b[0] = dut_vif.sdata; //new bit, at the end
  end
endtask : get_byte

local task set_byte(logic[7:0] b, int period_ns=1000);		//we assume SCLK=0, toggle data in posedge
    // dut_vif.sda_drive = 1;  //get the use of the data line
    repeat(8) begin
      dut_vif.sda_val = b[7];
      b = b << 1;
      #(period_ns*1ns);
      dut_vif.scl_val = !dut_vif.scl_val;
      #(period_ns*1ns);
      dut_vif.scl_val = !dut_vif.scl_val;
//      #(period_ns*1ns);
    end
    // dut_vif.sda_drive = 0;  //allow slave to set ACK
endtask

local task set_ack(int period_ns=1000);
    // dut_vif.sda_drive = 1;
    dut_vif.sda_val = 0;
    #(period_ns*1ns);
    dut_vif.scl_val = 1;
    #(period_ns*1ns);
    // ack = dut_vif.sdata;
    dut_vif.scl_val = 0;
    // dut_vif.sda_drive = 0;
endtask

local task set_start(int period_ns=1000);
    // dut_vif.sda_drive = 1;
    dut_vif.scl_val = 1;
    dut_vif.sda_val = 0;
    #(period_ns*1ns);
    dut_vif.scl_val = 0;
    //#(period_ns*1ns);
endtask

local task set_stop(int period_ns=1000);
    // dut_vif.sda_drive = 1;
    // #(period_ns*1ns);
    dut_vif.sda_val = 0;
    dut_vif.scl_val = 0;
    #(period_ns*1ns);
    dut_vif.scl_val = 1;
    #(period_ns*1ns);
    dut_vif.sda_val = 1;
endtask
        
