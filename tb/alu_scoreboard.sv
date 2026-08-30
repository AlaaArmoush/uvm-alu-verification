import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(alu_scoreboard)

  uvm_analysis_imp #(alu_sequence_item, alu_scoreboard) analysis_imp;
  alu_sequence_item packetQueue[$];

  int unsigned checked_count = 0;
  int unsigned mismatch_count = 0;

  function new(string name = "alu_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_imp = new("analysis_imp", this);
  endfunction : build_phase

  function void write(alu_sequence_item req);
    packetQueue.push_back(req);
  endfunction : write

  virtual task run_phase(uvm_phase phase);
    alu_sequence_item packet;

    forever begin
      wait (packetQueue.size() > 0);
      packet = packetQueue.pop_front();
      check_packet(packet);
    end
  endtask : run_phase

  function automatic string operation_name(input logic [2:0] opcode);
    case (opcode)
      3'b000:  operation_name = "ADD";
      3'b001:  operation_name = "SUB";
      3'b010:  operation_name = "AND";
      3'b011:  operation_name = "OR";
      3'b100:  operation_name = "XOR";
      default: operation_name = "INVALID";
    endcase
  endfunction : operation_name

  function automatic void alu_rf(input logic signed [31:0] A, input logic signed [31:0] B,
                                 input logic [2:0] opcode, output logic [31:0] expected_result,
                                 output logic expected_error, output bit result_defined);
    logic signed [32:0] wide_result;

    expected_result = '0;
    expected_error  = 1'b0;
    result_defined  = 1'b1;
    wide_result     = '0;

    case (opcode)
      3'b000: begin
        wide_result = $signed({A[31], A}) + $signed({B[31], B});
        expected_result = wide_result[31:0];
        expected_error = wide_result[32] ^ wide_result[31];
      end

      3'b001: begin
        wide_result = $signed({A[31], A}) - $signed({B[31], B});
        expected_result = wide_result[31:0];
        expected_error = wide_result[32] ^ wide_result[31];
      end

      3'b010: expected_result = A & B;
      3'b011: expected_result = A | B;
      3'b100: expected_result = A ^ B;

      default: begin
        result_defined = 1'b0;
        expected_error = 1'b1;
      end
    endcase
  endfunction : alu_rf

  function void check_packet(alu_sequence_item packet);
    logic  [31:0] expected_result;
    logic         expected_error;
    bit           result_defined;
    bit           result_mismatch;
    bit           error_mismatch;
    string        failed_fields;
    string        expected_result_text;

    checked_count++;

    if ($isunknown({packet.A, packet.B, packet.opcode})) begin
      mismatch_count++;

      `uvm_error("SB_UNKNOWN_REQUEST",
                 $sformatf({"Transaction %0d contains unknown request values\n",
                            "Operation : %s (opcode %03b)\n", "A         : 0x%08h\n",
                            "B         : 0x%08h"}, checked_count, operation_name(packet.opcode),
                             packet.opcode, packet.A, packet.B))

      return;
    end

    alu_rf(packet.A, packet.B, packet.opcode, expected_result, expected_error, result_defined);

    result_mismatch = result_defined && (packet.result !== expected_result);
    error_mismatch  = packet.error !== expected_error;

    if (result_mismatch) failed_fields = "RESULT";

    if (error_mismatch) begin
      if (failed_fields.len() > 0) failed_fields = {failed_fields, ", ERROR"};
      else failed_fields = "ERROR";
    end

    if (result_defined)
      expected_result_text = $sformatf("%0d (0x%08h)", $signed(expected_result), expected_result);
    else expected_result_text = "not checked: undefined by contract";

    if (result_mismatch || error_mismatch) begin
      mismatch_count++;

      `uvm_error("SB_MISMATCH",
                 $sformatf({"Transaction %0d FAILED\n", "Operation : %s (opcode %03b)\n",
                            "A         : %0d (0x%08h)\n", "B         : %0d (0x%08h)\n",
                            "Result    : expected=%s\n", "            actual  =%0d (0x%08h)\n",
                            "Error     : expected=%0b actual=%0b\n", "Failed fields: %s"},
                             checked_count, operation_name(packet.opcode), packet.opcode,
                             $signed(packet.A), packet.A, $signed(packet.B), packet.B,
                             expected_result_text, $signed(packet.result), packet.result,
                             expected_error, packet.error, failed_fields))
    end
  endfunction : check_packet

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    if (checked_count == 0) begin
      `uvm_error("SB_FAIL", "SCOREBOARD FAIL: no transactions were checked")
    end else if ((mismatch_count == 0) && (packetQueue.size() == 0)) begin
      `uvm_info("SB_PASS", $sformatf("SCOREBOARD PASS: checked=%0d mismatches=0", checked_count),
                UVM_NONE)
    end else begin
      `uvm_error("SB_FAIL", $sformatf(
                 "SCOREBOARD FAIL: checked=%0d mismatches=%0d queued=%0d",
                 checked_count,
                 mismatch_count,
                 packetQueue.size()
                 ))
    end
  endfunction : report_phase
endclass
