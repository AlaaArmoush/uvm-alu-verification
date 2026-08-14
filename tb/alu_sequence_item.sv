import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_sequence_item extends uvm_sequence_item;
  rand logic rst;
  rand logic signed [31:0] A;
  rand logic signed [31:0] B;
  rand logic [2:0] opcode;

  logic [31:0] result;
  logic error;

  `uvm_object_utils_begin(alu_sequence_item)
    `uvm_field_int(rst, UVM_ALL_ON)
    `uvm_field_int(A, UVM_ALL_ON)
    `uvm_field_int(B, UVM_ALL_ON)
    `uvm_field_int(opcode, UVM_ALL_ON)
    `uvm_field_int(result, UVM_ALL_ON)
    `uvm_field_int(error, UVM_ALL_ON)
  `uvm_object_utils_end


  function new(string name = "alu_sequence_item");
    super.new(name);
  endfunction
endclass




