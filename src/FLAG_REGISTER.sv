module FLAG_REGISTER(
input logic clk, reset,
input logic FR_read,
input logic carry_flag, zero_flag,
output logic carry_flag_register, zero_flag_register
);
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            carry_flag_register <= 0;
            zero_flag_register <= 0;
        end else begin
            if (FR_read)begin
                carry_flag_register <= carry_flag;
                zero_flag_register <= zero_flag;
            end
        end
    end

endmodule