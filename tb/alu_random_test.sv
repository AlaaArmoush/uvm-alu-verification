import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_random_test extends alu_base_test;
  `uvm_component_utils(alu_random_test)

  alu_random_sequence random_sequence;

  function new(string name = "alu_random_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    random_sequence = alu_random_sequence::type_id::create("random_sequence");

    repeat (500) begin
      random_sequence.start(environment.agent.sequencer);
    end

    wait_for_last_response();

    `uvm_info(get_type_name(), "Random test stimulus completed", UVM_LOW)

    phase.drop_objection(this);
  endtask : run_phase
endclass


