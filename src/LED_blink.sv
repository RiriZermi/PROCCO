module led_blinker (
    input logic clk,           
    input logic reset,        
    input logic control,      
    output logic  led    
);
    // Paramètres
    localparam integer CLK_FREQ = 100_000_000;
    localparam integer COUNTER_LIMIT = CLK_FREQ/2; 
    
    // Registres internes
    logic [$clog2(COUNTER_LIMIT)-1:0] counter; 
    logic toggle;                       

    // Bloc séquentiel
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            toggle <= 0;
        end else begin
            if (counter == COUNTER_LIMIT - 1) begin
                counter <= 0;
                toggle <= ~toggle; 
            end else begin
                counter <= counter + 1;
            end
        end
    end

    // Contrôle des LEDs
    always_comb begin
        if (control)
            led <= toggle; 
        else
            led <= 0; 
    end
endmodule
