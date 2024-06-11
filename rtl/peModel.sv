module peModel 
#(
    parameter int   nSaRows            = 256,
    parameter int   nRowSaInPE         = 4,
    parameter int   saAdcBit           = 4,
    parameter int   nStagesAdderTree   = $clog2(nRowSaInPE),
    parameter int   nSaCols            = nSaRows,
    parameter int   peRows             = nSaRows * nRowSaInPE,
    parameter int   peDataOutWidth     = nSaCols * (saAdcBit + nStagesAdderTree),
    parameter int   nAdderOutBits      = saAdcBit + nStagesAdderTree,
    parameter int   inputPrecision     = 4,
    parameter int   nColSaInPE         = nRowSaInPE, 
    parameter int   nSaInPE            = nColSaInPE * nRowSaInPE // always square
)
(
    input logic      clk,
    input logic      nrst,
    input logic      valid_i,
    input logic      [peRows-1:0][inputPrecision-1:0] pe_data_i,
    output logic     [nColSaInPE-1:0][nSaCols-1:0][nAdderOutBits-1:0] pe_data_o, // sync_data_transfer
    output logic     done_o
);

    logic [nColSaInPE-1:0][nRowSaInPE-1:0][nSaCols-1:0][saAdcBit-1:0] sa_out;
    logic [nColSaInPE-1:0]                [nSaCols-1:0][nAdderOutBits-1:0] adder_out;
    logic [nColSaInPE-1:0]                [nSaCols-1:0][nAdderOutBits-1:0] output_buffer;
    
    logic [nRowSaInPE-1:0][nSaRows-1:0][inputPrecision-1:0] pe_input_buffer;
    logic [nRowSaInPE-1:0][nSaRows-1:0]    input_bus;

    logic [nColSaInPE-1:0][nRowSaInPE-1:0] sa_done;
    logic [nColSaInPE-1:0][nRowSaInPE-1:0] sa_start; 

    task setValueForAllSa(output logic [nColSaInPE-1:0][nRowSaInPE-1:0] sa_signal, input logic value);
        foreach(sa_signal[saCol])
            foreach(sa_signal[saCol][saRow])
                sa_signal[saCol][saRow] <= value;
    endtask

    // SA calculate start signal
    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            sa_start <= 0;
        end else begin
            if (valid_i) begin
                sa_start <= ~sa_start;
            end else begin
                sa_start <= 0;
            end
        end
    end    

    // Input buffer
    always_ff @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            foreach(pe_input_buffer[peRow])
                pe_input_buffer[peRow] <= 0;
        end else begin
            if(valid_i) begin
                pe_input_buffer <= pe_data_i;
            end else begin
                //shift each time
                foreach(pe_input_buffer[peRow])
                    pe_input_buffer[peRow] <= {pe_input_buffer[peRow][0],pe_input_buffer[peRow][inputPrecision-1:1]};
            end
        end
    end

    // Output buffer
    always @(posedge clk or negedge nrst) begin
        if (!nrst)
            for(int sa = 0; sa < nColSaInPE; sa++)
                for(int col = 0; col < nSaCols; col++)
                    output_buffer [sa][col] <= 0;
        else
            output_buffer <= adder_out;
    end
    assign pe_data_o = output_buffer;

    // Adder tree
    always_comb begin
        int elem, saRow, saCol; 
        for(saCol = 0; saCol < nColSaInPE; saCol = saCol + 1) begin
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
                    .bit_i          (input_bus[h]),
                    .comp_o         (sa_out[j][h]),
                    .done_o         (sa_done[j][h]),
                    .start_i        (sa_start[j][h])   
                );        
            end
        end
    endgenerate

    // SA input addressing workaround
    always_comb begin
        for(int peRow = 0; peRow < nRowSaInPE; peRow++)
            for(int saRow =0; saRow < nSaRows; saRow++)
                input_bus[peRow][saRow] = pe_input_buffer[peRow][saRow][0];
    end
endmodule