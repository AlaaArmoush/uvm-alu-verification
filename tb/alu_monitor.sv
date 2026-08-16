import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_monitor extends uvm_monitor;
  virtual alu_interface vif;
  `uvm_component_utils(alu_monitor)

  function new(string name = "alu_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction

  uvm_analysis_port #(alu_sequence_item) port;
  alu_sequence_item item;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("monitor_port", this);

    if (!uvm_config_db#(virtual alu_interface)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "Not set at top level");
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    `uvm_info("MONITOR_CLASS", "Inside Run Phase!", UVM_HIGH)

    forever begin
      @(vif.cb_mon);

      if (vif.cb_mon.rst !== 1'b0) continue;

      item        = alu_sequence_item::type_id::create("item");
      item.rst    = vif.cb_mon.rst;
      item.A      = vif.cb_mon.A;
      item.B      = vif.cb_mon.B;
      item.opcode = vif.cb_mon.opcode;
      item.result = vif.cb_mon.result;
      item.error  = vif.cb_mon.error;

      port.write(item);
    end
  endtask : run_phase
endclass
