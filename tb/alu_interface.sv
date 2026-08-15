`timescale 1ns / 1ps

interface alu_interface (
    input logic clk,
    input logic rst
);

  logic signed [31:0] A;
  logic signed [31:0] B;
  logic [2:0] opcode;
  logic [31:0] result;
  logic error;

  clocking cb_drv @(negedge clk);
    default input #1step output #0;
    input rst;
    output A;
    output B;
    output opcode;
  endclocking

  clocking cb_mon @(posedge clk);
    default input #0;
    input rst;
    input A;
    input B;
    input opcode;
    input result;
    input error;
  endclocking

  modport drv(clocking cb_drv, input clk);
  modport mon(clocking cb_mon, input clk);
endinterface
