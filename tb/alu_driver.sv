import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_driver extends uvm_driver #(alu_sequence_item);
  virtual alu_interface vif;
  `uvm_component_utils(alu_driver)

  function new(string name = "alu_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Not set at top level");
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);

      `uvm_info(get_type_name(), $sformatf(
                "Driver: signals driven to the DUT are: A = %0d, B = %0d, Opcode = %0h",
                req.A,
                req.B,
                req.opcode
                ), UVM_HIGH)
      seq_item_port.item_done();
    end
  endtask : run_phase

  task automatic drive(alu_sequence_item req);
    do begin
      @(vif.cb_drv);
    end while (vif.cb_drv.rst !== 1'b0);

    vif.cb_drv.A <= req.A;
    vif.cb_drv.B <= req.B;
    vif.cb_drv.opcode <= req.opcode;
  endtask
endclass
