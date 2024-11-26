module frequency_divider (
    input  logic clk_in,    // Horloge d'entrée
    input  logic reset,     // Signal de reset asynchrone
    output logic clk_out    // Horloge de sortie divisée
);

    // Compteur pour générer l'horloge divisée
    localparam CLK_FREQ = 100_000_000;
    parameter TARGET_FREQ = 50_000_000;
    localparam COUNTER_LIMIT = CLK_FREQ / (2*TARGET_FREQ);
    logic [$clog2(COUNTER_LIMIT)-1:0] counter;

    always_ff @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == (COUNTER_LIMIT - 1)) begin
                counter <= 0;
                clk_out <= ~clk_out; // Bascule l'état de l'horloge de sortie
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
