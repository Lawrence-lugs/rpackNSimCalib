module peModel 
#(
    parameter int   nSaRows            = 256,
    parameter int   nRowSaInPE         = 4,
    parameter int   saAdcBit           = 4,
    parameter int   nStagesAdderTree   = $clog2(nRowSaInPE),
    parameter int   nSaCols            = nSaRows,
    parameter int   peRows      = nSaRows * nRowSaInPE,
    parameter int   peDataOutWidth     = nSaCols * (saAdcBit + nStagesAdderTree),
    parameter int   nAdderOutBits      = saAdcBit + nStagesAdderTree,
    parameter int   inputPrecision     = 4,
    parameter int   nColSaInPE         = nRowSaInPE, 
    parameter int   nSaInPE            = nColSaInPE * nRowSaInPE // always square
)
(
    input logic      clk,
    input logic      nrst,
    input logic      valid,
    input logic      [inputPrecision-1:0] pe_data_i [peRows-1:0],
    output logic     [saAdcBit-1:0] pe_data_o [nSaCols-1:0],
    output logic     done_o
);

    logic [nSaCols-1:0][saAdcBit-1:0] sa_out [nColSaInPE][nRowSaInPE];
    logic [nAdderOutBits-1:0] adder_out [nColSaInPE][nSaCols];
    logic [nAdderOutBits-1:0] output_buffer [nSaCols];
    
    logic [inputPrecision-1:0] pe_input_buffer [peRows];
    logic [peRows-1:0] input_bus;

    logic [nColSaInPE-1:0][nRowSaInPE-1:0] sa_done;

    // Input buffer
    always @(posedge clk or negedge nrst) begin
        if (!nrst)
            foreach(pe_input_buffer[peRow])
                pe_input_buffer[peRow] <= 0;
        else
            if(valid)
                pe_input_buffer <= pe_data_i;
            else
                //shift each time
                foreach(pe_input_buffer[peRow])
                    pe_input_buffer[peRow] <= {pe_input_buffer[peRow][0],pe_input_buffer[peRow][inputPrecision-1:1]};
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
        int elem, saRow, saCol; 
        for(saCol = 0; saCol < nColSaInPE; saCol++) begin
            foreach(adder_out[saCol][elem]) begin
                adder_out[saCol][elem] = 0;
                foreach(sa_out[saCol][saRow])
                    adder_out[saCol][elem] = adder_out[saCol][elem] + sa_out[saCol][saRow][elem];
            end
        end
    end

    // Compute element
    genvar h, j;
    generate
        for (j=0; j<nColSaInPE; j++) begin : sa_instances_col
            for (h = 0 ; h < nRowSaInPE ; h++ ) begin : sa_instances_row
                saModel #(
                    .nSaRows        (nSaRows),
                    .nSaCols        (nSaCols),
                    .bitAdc         (saAdcBit)
                ) pe_saModel (
                    .clk            (clk),
                    .nrst           (nrst),
                    .bit_i          (input_bus[nSaRows*h+nSaRows-1 : nSaRows*h]),
                    .comp_o         (sa_out[j][h]),
                    .done_o         (sa_done[j][h])
                );        
            end
        end
    endgenerate

    // SA input addressing workaround
    always_comb begin
        foreach(pe_input_buffer[peRow])
            for(int i=0;i< inputPrecision;i++) begin
                input_bus[peRow] = pe_input_buffer[peRow][0];
            end
    end

    assign pe_data_o = output_buffer;
endmodule