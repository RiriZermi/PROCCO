
module Memory_Adress_Register #(parameter MAR_register_size = 10)(
input logic clk, reset,
input logic MAR_read, //-to control
output logic[MAR_register_size-1:0] MAR_register,
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
