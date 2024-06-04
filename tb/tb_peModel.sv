`timescale 1ns/1ps

module tb_peModel;

parameter int unsigned CLK_PERIOD = 20;
parameter int nSaRows = 256;
parameter int nRowSaInPE = 4;
parameter int nStagesAdderTree = 4;
parameter int saAdcBit = 4;
parameter int peSize = nRowSaInPE*nSaRows;
parameter int inputPrecision = 4;

logic clk, nrst, valid;
logic [nSaRows * nRowSaInPE - 1:0] data_in;
logic [nSaRows + nStagesAdderTree - 1:0] data_out;
logic [nSaRows * nRowSaInPE - 1:0][inputPrecision-1:0] acts_buffer;

// Instantiate the peModel
peModel dut (
    .clk(clk),
    .nrst(nrst),
    .valid(valid),
    .data_in(data_in),
    .data_out(data_out)
);

always
    #(CLK_PERIOD/2) clk = ~clk;

int acts_file;

task calculateComp(
    input logic [nSaRows * nRowSaInPE - 1:0][inputPrecision-1:0] acts_buffer
);

    valid = 1;
    data_in = acts_buffer[0];
    #(CLK_PERIOD);
    data_in = acts_buffer[1];
    #(CLK_PERIOD);
    data_in = acts_buffer[2];
    #(CLK_PERIOD);
    data_in = acts_buffer[3];
    #(CLK_PERIOD);

endtask

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


    for(int l=0;l<50;l++) begin

        // Load acts buffer
        for(int i=0;i<peSize;i++) begin
            $fscanf(acts_file,"%d ", acts_buffer[i]);
        end         

        #(CLK_PERIOD);
        calculateComp(acts_buffer);

    end

    #(CLK_PERIOD * 20);

    $display("===============");
    $finish();

end

endmodule