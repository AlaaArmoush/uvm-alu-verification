import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_overflow_sequence extends uvm_sequence #(alu_sequence_item);
  `uvm_object_utils(alu_overflow_sequence)

  function new(string name = "alu_overflow_sequence");
    super.new(name);
  endfunction

  task body();
    alu_sequence_item req = alu_sequence_item::type_id::create("req");

    start_item(req);
    if (!req.randomize() with {
          rst == 1'b0;
          opcode == 3'b000;
          A == 32'sh7fff_ffff;
          B == 32'sd1;
        }) begin
      `uvm_fatal(get_type_name(), "Failed to randomize overflow request")
    end
    finish_item(req);
  endtask
endclass
