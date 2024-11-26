module Instructions_Register(
input logic clk,reset,
inout tri0[31:0] bus,
input logic IR_read, //-to control
output logic[31:0] IR_register
);
    
    always_ff @(posedge clk or posedge reset)begin
        if (reset) begin
            IR_register <= 0;
        end else begin
            if (IR_read)
                IR_register <= bus;
        end
    end

endmodule