import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_regression_test extends alu_base_test;
  `uvm_component_utils(alu_regression_test)

  alu_random_sequence           random_sequence;
  alu_add_sequence              add_sequence;
  alu_sub_sequence              sub_sequence;
  alu_and_sequence              and_sequence;
  alu_or_sequence               or_sequence;
  alu_xor_sequence              xor_sequence;
  alu_undefined_opcode_sequence undefined_opcode_sequence;
  alu_overflow_sequence         overflow_sequence;
  alu_underflow_sequence        underflow_sequence;

  string                        sequence_name;

  function new(string name = "alu_regression_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    random_sequence = alu_random_sequence::type_id::create("random_sequence");
    add_sequence = alu_add_sequence::type_id::create("add_sequence");
    sub_sequence = alu_sub_sequence::type_id::create("sub_sequence");
    and_sequence = alu_and_sequence::type_id::create("and_sequence");
    or_sequence = alu_or_sequence::type_id::create("or_sequence");
    xor_sequence = alu_xor_sequence::type_id::create("xor_sequence");
    undefined_opcode_sequence =
        alu_undefined_opcode_sequence::type_id::create("undefined_opcode_sequence");
    overflow_sequence = alu_overflow_sequence::type_id::create("overflow_sequence");
    underflow_sequence = alu_underflow_sequence::type_id::create("underflow_sequence");

    if (!$value$plusargs("SEQ_NAME=%s", sequence_name)) sequence_name = "all";

    `uvm_info(get_type_name(), $sformatf("Selected sequence: %s", sequence_name), UVM_LOW)

    case (sequence_name)
      "alu_random_sequence": random_sequence.start(environment.agent.sequencer);

      "alu_add_sequence": add_sequence.start(environment.agent.sequencer);

      "alu_sub_sequence": sub_sequence.start(environment.agent.sequencer);

      "alu_and_sequence": and_sequence.start(environment.agent.sequencer);

      "alu_or_sequence": or_sequence.start(environment.agent.sequencer);

      "alu_xor_sequence": xor_sequence.start(environment.agent.sequencer);

      "alu_undefined_opcode_sequence": undefined_opcode_sequence.start(environment.agent.sequencer);

      "alu_overflow_sequence": overflow_sequence.start(environment.agent.sequencer);

      "alu_underflow_sequence": underflow_sequence.start(environment.agent.sequencer);

      "all": begin
        random_sequence.start(environment.agent.sequencer);
        add_sequence.start(environment.agent.sequencer);
        sub_sequence.start(environment.agent.sequencer);
        and_sequence.start(environment.agent.sequencer);
        or_sequence.start(environment.agent.sequencer);
        xor_sequence.start(environment.agent.sequencer);
        undefined_opcode_sequence.start(environment.agent.sequencer);
        overflow_sequence.start(environment.agent.sequencer);
        underflow_sequence.start(environment.agent.sequencer);
      end

      default:
      `uvm_fatal("INVALID_SEQ_NAME", $sformatf("Unknown sequence selected: %s", sequence_name))
    endcase

    wait_for_last_response();

    `uvm_info(get_type_name(), $sformatf("Sequence completed: %s", sequence_name), UVM_LOW)

    phase.drop_objection(this);
  endtask : run_phase
endclass
