`timescale 1ns/1ps

// vcs -full64 -sverilog -debug_pp ../tb/tb_peModel.sv ../rtl/*.sv

module tb_peModel;

parameter int unsigned CLK_PERIOD = 20;
parameter int nSaRows = 256;
parameter int nRowSaInPE = 4;
parameter int nStagesAdderTree = 4;
parameter int saAdcBit = 4;
parameter int peSize = nRowSaInPE*nSaRows;
parameter int inputPrecision = 4;

logic clk, nrst, valid;
logic [peSize - 1:0] data_in;
logic [nSaRows + nStagesAdderTree - 1:0] data_out;
logic [peSize - 1:0][inputPrecision-1:0] acts_buffer;

logic done;

// Instantiate the peModel
peModel dut (
    .clk(clk),
    .nrst(nrst),
    .valid(valid),
    .pe_data_i(data_in),
    .pe_data_o(data_out),
    .done_o(done)
);

always
    #(CLK_PERIOD/2) clk = ~clk;

int acts_file;

task calculateComp(
    input logic [peSize - 1:0][inputPrecision-1:0] acts_buffer
);

    #(CLK_PERIOD);
    valid = 1;
    foreach(acts_buffer[i])
        data_in[i] = acts_buffer[i];
    #(CLK_PERIOD*3);
    valid = 0;

endtask

int fout;

initial begin
    $vcdplusfile("tb_peModel.vpd");
    $vcdpluson;

    `ifdef SYNTHESIS
    $sdf_annotate("../mapped/peModel_mapped.sdf", UUT);
    `endif 

    $display("===============");
    acts_file = $fopen("../tb/acts.csv","r");

    clk = 0;
    valid = 0;
    nrst = 0;
    #(CLK_PERIOD * 5)
    nrst = 1;
    #(CLK_PERIOD)

    for(int l=0;l<50;l++) begin

        // Load acts buffer
        for(int i=0;i<peSize;i++) begin
            fout = $fscanf(acts_file,"%d ", acts_buffer[i]);
        end         
        calculateComp(acts_buffer);

    end

    #(CLK_PERIOD * 20);

    $display("===============");
    $finish();

end

endmodule