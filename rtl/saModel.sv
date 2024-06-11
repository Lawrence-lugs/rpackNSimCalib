module saModel
// Models the subArrays in NeuroSIM
#(
    parameter int   nSaRows   = 256,
    parameter int   nSaCols  = 256,
    parameter int   bitAdc    = 4,
    parameter int   inputPrecision = 4
)   
( 
    input clk,
    input nrst,
    input start_i,
    input logic [nSaRows-1:0] bit_i,
    // input logic [nSaCols-1:0] wr_data_i,
    // input logic [$clog2(nSaRows)-1:0] wr_sel_i,
    output logic [nSaCols-1:0][bitAdc-1:0] comp_o,
    output logic done_o
);

logic [nSaRows-1:0][inputPrecision-1:0] acc;
logic [$clog2(inputPrecision)-1:0] ctr;

// Get 1 bit of activation per cycle
always_ff @ (posedge clk) begin : activationFeeding
    if (!nrst)
        for(int row=0;row<nSaRows;row=row+1)
            acc[row][3:0] <= 0;
    else
        for(int row=0;row<nSaRows;row=row+1)
            acc[row][3:0] <= {bit_i[row],acc[row][3:1]}; // Shift in bit_i
end

// Surrogate operation : +1
// we expect the output of the SA to come out the cycle after the last bit is placed.
always_comb begin
    foreach(comp_o[row])
        comp_o[row] = acc[row] + 1;
end

// Need to communicate to the outside that we're done and that the data is valid.
always_ff @(posedge clk or negedge nrst) begin
    if (!nrst) begin
        ctr <= 0;
    end else begin
        if (!start_i & (ctr == 0)) begin
            ctr <= 0;
        end else begin
            ctr <= ctr + 1;
        end
    end
end
always_comb begin
    done_o <= (ctr == 3);
end

endmodule