module Register_Bank(
input logic clk,reset,
//bus signals
inout tri0[31:0] bus, 
input logic RB_read, //-to_control
input logic[3:0] RB_addr, // 16 register //-to_control
input logic RB_write, //-to_control
//send to alu signals
input logic[3:0] addr_register1_to_ALU,addr_register2_to_ALU, //-to_control
output logic[31:0] register1_to_ALU, register2_to_ALU
);
    logic[31:0] register[16]; //16 register_memory
    
    //bus write or read
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i=0; i<16;i++) register[i]<=0;
        end else begin
            if (RB_read)
                register[RB_addr]<=bus;
                            
        end  
    end
    
    assign bus = RB_write ? register[RB_addr] : 32'hZ;
    
    //register bank to ALU
    always_comb begin
        register1_to_ALU <= register[addr_register1_to_ALU];
        register2_to_ALU <= register[addr_register2_to_ALU];
    end

endmodule