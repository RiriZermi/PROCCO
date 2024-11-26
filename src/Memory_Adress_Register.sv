
module Memory_Adress_Register(
input logic clk, reset,
input logic MAR_read, //-to control
output logic[9:0] MAR_register,
inout tri[31:0] bus
    );

    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            MAR_register <= 0;
        end else begin
            if (MAR_read)
                MAR_register <= bus;
        end    
    end
    
    
endmodule
