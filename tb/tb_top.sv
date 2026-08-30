`timescale 1ns / 1ps

module tb_top;
  import uvm_pkg::*;

  logic clk;
  logic rst;

  alu_interface intf (
      .clk(clk),
      .rst(rst)
  );

  alu dut (
      .clk   (clk),
      .rst   (rst),
      .A     (intf.A),
      .B     (intf.B),
      .Opcode(intf.opcode),
      .Result(intf.result),
      .Error (intf.error)
  );

  initial begin
    clk = 1'b0;
    forever #5ns clk = ~clk;
  end

  initial begin
    rst = 1'b1;
    repeat (2) @(posedge clk);
    #1ns;
    rst = 1'b0;
  end

  initial begin
    uvm_config_db#(virtual alu_interface)::set(null, "uvm_test_top.environment.agent.*", "vif",
                                               intf);
    run_test();
  end
endmodule
