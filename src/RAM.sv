module RAM (
    input logic clk,
    input logic [9:0] addr,      
    input logic RAM_read,RAM_write,      //-to control                
    inout tri0[31:0] bus 
);
//set_param synth.elaboration.rodinMoreOptions "rt::set_parameter var_size_limit 4194304"
    logic[31:0] mem[2**10];

    initial begin
//        `include "../include/RAM.txt"
        // Charger le fichier binaire dans la mémoire
		
		//error : complete your path
        $readmemb("..../DATA_RAM/RAM.bin", mem);
    end
    
//    assign data_out = mem[addr];
    assign bus = RAM_write ? mem[addr] : 32'hZ;
    
    // Écriture asynchrone
    always_ff @(posedge clk) begin
        if (RAM_read) begin
            mem[addr] <= bus;
        end
    end

endmodule