module Program_Counter(
input logic clk,reset,
input logic counter_enable, //-to control
input logic PC_read, PC_write, //-to control
inout tri0[31:0] bus

);
    logic[31:0] PC;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 0;
        end else begin
            if (counter_enable)
                PC <= PC + 1;
            else if (PC_read)
                PC <= bus;
        end
    end 
    
    assign bus = PC_write ? PC : 32'hZ;
    
endmodule