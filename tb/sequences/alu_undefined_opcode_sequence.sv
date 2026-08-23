import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_undefined_opcode_sequence extends uvm_sequence #(alu_sequence_item);
  `uvm_object_utils(alu_undefined_opcode_sequence)

  function new(string name = "alu_undefined_opcode_sequence");
    super.new(name);
  endfunction

  task body();
    alu_sequence_item req = alu_sequence_item::type_id::create("req");

    start_item(req);
    if (!req.randomize() with {
          rst == 1'b0;
          opcode inside {3'b101, 3'b110, 3'b111};
        }) begin
      `uvm_fatal(get_type_name(), "Failed to randomize undefined-opcode request")
    end
    finish_item(req);
  endtask
endclass
