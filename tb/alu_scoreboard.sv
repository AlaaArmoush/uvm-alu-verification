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
    logic [31:0] expected_result;
    logic        expected_error;
    bit          result_defined;
    bit          mismatch;

    checked_count++;

    if ($isunknown({packet.A, packet.B, packet.opcode})) begin
      mismatch_count++;
      `uvm_error("SB_UNKNOWN_REQUEST", $sformatf("A=0x%08h B=0x%08h opcode=%03b", packet.A,
                                                 packet.B, packet.opcode))
      return;
    end

    alu_rf(packet.A, packet.B, packet.opcode, expected_result, expected_error, result_defined);

    mismatch = (packet.error !== expected_error) ||
      (result_defined && (packet.result !== expected_result));

    if (mismatch) begin
      mismatch_count++;
      `uvm_error(
          "SB_MISMATCH",
          $sformatf(
              "opcode=%03b A=0x%08h B=0x%08h result_defined=%0b expected_result=0x%08h actual_result=0x%08h expected_error=%0b actual_error=%0b",
              packet.opcode, packet.A, packet.B, result_defined, expected_result, packet.result,
              expected_error, packet.error))
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
