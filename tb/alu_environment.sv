import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_environment extends uvm_env;
  `uvm_component_utils(alu_environment)

  alu_agent      agent;
  alu_scoreboard scoreboard;
  alu_coverage   coverage;

  function new(string name = "alu_environment", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent      = alu_agent::type_id::create("agent", this);
    scoreboard = alu_scoreboard::type_id::create("scoreboard", this);
    coverage   = alu_coverage::type_id::create("coverage", this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.port.connect(scoreboard.analysis_imp);
    // coverage.analysis_export is inherited from uvm_subscriber.
    // Despite its name, it is an analysis_imp that calls coverage.write().
    agent.monitor.port.connect(coverage.analysis_export);
  endfunction : connect_phase
endclass










