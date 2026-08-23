import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_and_sequence extends uvm_sequence #(alu_sequence_item);
  `uvm_object_utils(alu_and_sequence)

  function new(string name = "alu_and_sequence");
    super.new(name);
  endfunction

  task body();
    alu_sequence_item req = alu_sequence_item::type_id::create("req");

    start_item(req);
    if (!req.randomize() with {
          rst == 1'b0;
          opcode == 3'b010;
        }) begin
      `uvm_fatal(get_type_name(), "Failed to randomize AND request")
    end
    finish_item(req);
  endtask
endclass


