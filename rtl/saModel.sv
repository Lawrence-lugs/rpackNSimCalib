module saModel
// Models the subArrays in NeuroSIM
#(
    parameter int   nElemIn   = 256,
    parameter int   nElemOut  = 256,
    parameter int   bitAdc    = 4,
    parameter int   nBitInput = 4
)   
( 
    input clk,
    input nrst,
    input logic [nElemIn-1:0] bit_i,
    // input logic [nElemOut-1:0] wr_data_i,
    // input logic [$clog2(nElemIn)-1:0] wr_sel_i,
    output logic [nElemOut-1:0][bitAdc-1:0] comp_o
);

logic [nElemIn-1:0][nBitInput-1:0] act;

// Get 1 bit of activation per cycle
always_ff @ (posedge clk) begin : activationFeeding
    if (!nrst)
        for(int k=0;k<nElemIn;k=k+1)
            act[k][3:0] <= 0;
    else
        for(int k=0;k<nElemIn;k=k+1)
            act[k][3:0] <= {act[k][2:0],bit_i}; // Shift in bit_i
end

// Surrogate operation : +1
always_ff @ (posedge clk) begin : outputSide
    if (!nrst)
        for(int k=0;k<nElemOut;k=k+1)
            comp_o[k] <= 0;
    else
        for(int k=0;k<nElemOut;k=k+1)
            comp_o[k] <= act[k] + 1;
end

endmodule