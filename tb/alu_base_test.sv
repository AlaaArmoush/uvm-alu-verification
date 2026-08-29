import uvm_pkg::*;
`include "uvm_macros.svh"

class alu_base_test extends uvm_test;
  `uvm_component_utils(alu_base_test)

  alu_environment environment;

  function new(string name = "alu_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(uvm_active_passive_enum)::set(this, "environment.agent", "is_active",
                                                 UVM_ACTIVE);

    environment = alu_environment::type_id::create("environment", this);
  endfunction : build_phase

  virtual function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    uvm_top.set_timeout(1ms, 1'b1);
  endfunction : start_of_simulation_phase

  virtual task wait_for_last_response();
    @(environment.agent.monitor.vif.cb_mon);
    @(environment.agent.monitor.vif.cb_drv);
  endtask : wait_for_last_response

  virtual function void report_phase(uvm_phase phase);
    uvm_report_server server;

    super.report_phase(phase);
    server = uvm_report_server::get_server();

    if ((server.get_severity_count(
            UVM_ERROR
        ) == 0) && (server.get_severity_count(
            UVM_FATAL
        ) == 0)) begin
      `uvm_info("TEST_PASS", "TEST PASS", UVM_NONE)
    end else begin
      `uvm_error("TEST_FAIL", "TEST FAIL")
    end
  endfunction : report_phase
endclass
