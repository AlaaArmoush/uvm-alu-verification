import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_coverage extends uvm_subscriber #(alu_sequence_item);
  `uvm_component_utils(alu_coverage)

  covergroup alu_coverage_gp;
    coverpoint subscriber.A;
    coverpoint subscriber.B;
    coverpoint subscriber.opcode;
    coverpoint subscriber.result;
    coverpoint subscriber.error;
  endgroup

  alu_sequence_item subscriber;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    alu_coverage_gp = new();
    subscriber = alu_sequence_item::type_id::create("subscriber", this);
  endfunction

  //triggered by the monitor
  function void write(alu_sequence_item t);
    subscriber.A = t.A;
    subscriber.B = t.B;
    subscriber.opcode = t.opcode;
    subscriber.result = t.result;
    subscriber.error = t.error;

    alu_coverage_gp.sample();
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("ALU_COVERAGE", $sformatf("Coverage: %0.2f%%", alu_coverage_gp.get_inst_coverage()),
              UVM_NONE)
  endfunction
endclass
