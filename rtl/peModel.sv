module peModel 
#(
    parameter int   nSaRows            = 256,
    parameter int   nRowSaInPE         = 4,
    parameter int   nStagesAdderTree   = 4,
    parameter int   saAdcBit           = 4,
    parameter int   peDataInWidth      = nSaRows * nRowSaInPE,
    parameter int   peDataOutWidth     = nSaRows + nStagesAdderTree,
    parameter int   nSaCols            = nSaRows
)
(
    input wire       clk,
    input wire       nrst,
    input logic      valid,
    input wire       [peDataInWidth-1:0] data_in,
    output wire      [peDataOutWidth-1:0] data_out
);

    logic [nSaCols-1:0][saAdcBit-1:0] sa_out [nRowSaInPE-1:0];
    logic [peDataOutWidth-1:0] adder_out;
    logic [peDataOutWidth-1:0] output_buffer;
    logic [peDataInWidth-1:0] input_buffer;

    // Input buffer
    always @(posedge clk or negedge nrst) begin
        if (!nrst)
            input_buffer <= 8'h00;
        else
            if(valid)
                input_buffer <= data_in;
            else
                input_buffer <= input_buffer;
    end

    // Output buffer
    always @(posedge clk or negedge nrst) begin
        if (!nrst)
            output_buffer <= 8'h00;
        else
            output_buffer <= adder_out;
    end

    // Adder tree
    always_comb begin
        for (int k = 0 ; k < nRowSaInPE ; k++ ) begin
            adder_out = adder_out + sa_out[k];
        end
    end

    // Compute element
    genvar h;
    generate
        for (h = 0 ; h < nRowSaInPE ; h++ ) begin : sa_instances
            saModel #(
                .nElemIn        (nSaRows),
                .nElemOut       (nSaCols),
                .bitAdc         (saAdcBit)
            ) pe_saModel (
                .clk            (clk),
                .nrst           (nrst),
                .bit_i          (input_buffer[nSaRows*(h+1)-1:nSaRows*h]),
                .comp_o         (sa_out[h])
            );        
        end
    endgenerate

    assign data_out = output_buffer;
endmodule

