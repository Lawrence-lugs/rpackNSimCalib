`timescale 1ns/1ps

module tb_mac_engine;

parameter int unsigned CLK_PERIOD = 20;

logic clk, nrst;
logic [7:0][3:0] acts;
logic [7:0][7:0] weights;
logic [7:0][3:0] out;

mac_engine UUT(
    .clk(clk),
    .nrst(nrst),
    .act_i(acts),
    .w_i(weights),
    .res_o(out)
);

always
    #(CLK_PERIOD/2) clk = ~clk;

int outs_ref;
logic [3:0] out_ref;
int acts_file;
int weights_file;

int err_cnt;

initial begin
    $vcdplusfile("tb_mac_engine.vpd");
    $vcdpluson;
    $sdf_annotate("../mapped/mac_engine_mapped.sdf", UUT);

    $display("===============");

    outs_ref = $fopen("../tb/outs_b.csv","r");
    acts_file = $fopen("../tb/acts.csv","r");
    weights_file = $fopen("../tb/weights.csv","r");

    err_cnt = 0;
    clk = 0;
    nrst = 0;
    #(CLK_PERIOD * 5)
    nrst = 1;

    for(int l=0;l<50;l++) begin

        #(CLK_PERIOD)

        for(int i=0;i<8;i++) begin
            $fscanf(acts_file,"%d ", acts[i]);
            for(int j=0;j<8;j++) begin
                $fscanf(weights_file,"%d ", weights[i][j]);
            end
        end

        for(int k=0;k<8;k++) begin
            $fscanf(outs_ref,"%d ", out_ref);
            if(out_ref != out[k]) begin
                $display("Error at output (line %d, col %d),%d vs expected %d",l,k,out[k],out_ref);
                err_cnt++;
            end
        end
    end

    #(CLK_PERIOD * 20)

    if(err_cnt)
        $display("%d errors were detected.",err_cnt);
    else
        $display("Simulation success. No errors were detected.");

    $display("===============");
    $finish();

end

endmodule