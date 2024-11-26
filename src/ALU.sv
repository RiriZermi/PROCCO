module ALU(
input logic[31:0] register1,register2,
input logic add_op,sub_op,and_op,or_op,xor_op,sll_op,srl_op,not_op, //-to control
output carry_flag,zero_flag,
//bus signals
input logic ALU_write, //-to control
inout tri0[31:0] bus
);
    logic [32:0] result;
    logic [31:0] result_tmp;
    always_comb begin
        
            if (add_op)      result <= register1 + register2;
            else if (sub_op) result <= register1 - register2;
            else if (and_op) result <= register1 & register2;
            else if (or_op)  result <= register1 | register2;
            else if (xor_op) result <= register1 ^ register2;
            else if (srl_op) result <= register1 >> register2;
            else if (sll_op) result <= register1 << register2;
            else if (not_op) result <= ~register1; 
            else result <= register1 + register2;
        
    end
    
    assign carry_flag = result[32];
    assign zero_flag = (result==0) ;
    
    
    assign result_tmp = result [31:0];
    
    assign bus = ALU_write ? result_tmp : 32'hZ;
    
endmodule