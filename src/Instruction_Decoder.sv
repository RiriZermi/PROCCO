
module Instruction_Decoder(
input logic clk,reset,
input logic[31:0] IR_register,
input logic zero_flag_register,carry_flag_register,
//bank register signals
output logic RB_read,
output logic[3:0] RB_addr, // 16 register
output logic RB_write,
//send to alu signals
output logic[3:0] addr_register1_to_ALU,addr_register2_to_ALU,
output logic add_op, sub_op, and_op, or_op, xor_op,sll_op,srl_op,not_op,
output logic ALU_write,

//FR_read
output logic FR_read,
//pc signals
output logic counter_enable,PC_read,PC_write,
// MAR signals
output logic MAR_read,
//RAM signals
output logic RAM_read,RAM_write,
//IR signals
output logic IR_read,
//CIN
input logic cin_done,
output logic cin_get,cin_write,
//OUT 
output logic OUT_read,
output logic OUT_print_load,
//BUS
inout tri0[31:0] bus


);  
    logic cin_done = 0;
    
    typedef enum logic [4:0] {
    NOP  = 5'b00000, // No operation
    ADD  = 5'b00001, // Addition
    SUB  = 5'b00010, // Subtraction
    AND_op  = 5'b00011, // Bitwise AND
    OR_op   = 5'b00100, // Bitwise OR
    XOR_op  = 5'b00101, // Bitwise XOR
    SLL  = 5'b00110, // Shift Left Logical
    SRL  = 5'b00111, // Shift Right Logical
    OUT  = 5'b01000, // Output
    ADDI = 5'b01001, // Addition Immediate
    ANDI = 5'b01010, // AND Immediate
    ORI  = 5'b01011, // OR Immediate
    LW   = 5'b01100, // Load Word
    SW   = 5'b01101, // Store Word
    J    = 5'b01110, // Jump
    JEQ  = 5'b01111, // Jump if Equal
    JNE  = 5'b10000, // Jump if Not Equal
    JCA  = 5'b10001, // Jump if Carry Active
    JNC  = 5'b10010,  // Jump if No Carry
    HALT = 5'b11111,   // Stop the processor
    SUBI = 5'b10011,   //Sub Immediate
    LIS  = 5'b10100,   //Load signed Immediate in register
    LIU  = 5'b10101,   //Load unsigned Immediate
    JZE  = 5'b10110,   //Jump if zero
    JNZ  = 5'b10111,    //Jump if not zero
    CIN  = 5'b11001,    //Wait for user enter value
    NOT_op = 5'b11000,   // Not operation
    J_USER = 5'b11010  //Jump if user confirm
} instruction_t;
    
    //------------signals-----------
    logic ID_write;
    
    instruction_t IR_instruction;
    logic[26:0] IR_data;;
    logic[26:0] imm;
    
    assign IR_instruction = instruction_t'(IR_register[31:27]);
    assign IR_data = IR_register[26:0];
    
    assign bus = ID_write ? 
        ( (imm[22] && IR_instruction==LIS) ? {9'h1FF,imm} : imm) // if signed extension 
        : 32'hZ; //Write
    
    //--
    logic[3:0] rs,rt,rd;
    always_comb begin //rs rt rd
        if ( IR_instruction == JEQ ||
             IR_instruction == JNE ||
             IR_instruction == JCA ||
             IR_instruction == JNC ||
             IR_instruction == J   ||
             IR_instruction == LW  ||
             IR_instruction == SW  ||
             IR_instruction == OUT)begin
             
             rs <= IR_data[26:23];
             rt <= IR_data[22:19];           
        end else begin
            rs <= IR_data[22:19];
            rt <= IR_data[18:15];
            rd <= IR_data[26:23];
        end
             
    end
    
    always_comb begin //imm
        if ( IR_instruction == J ||
             IR_instruction == LIS ||
             IR_instruction == LIU)
             imm <= IR_data[22:0];
        else if (IR_instruction == JCA ||
                 IR_instruction == JNC ||
                 IR_instruction == JZE ||
                 IR_instruction == JNZ )
             imm <= IR_data[26:0];
        else 
             imm <= IR_data[18:0];            
    end

    //--------------------------
    
    //counter_step
    logic reset_counter_step;
    logic incr_counter_step;
    logic[2:0] counter_step;
    
    
    
    //counter step 
    always_ff @(posedge clk or posedge reset) begin
        //synchrone reset to respect timing and avoid metastability
        if (reset || reset_counter_step) begin
            counter_step <= 0;
        end else begin
            if (incr_counter_step) counter_step <= counter_step + 1;
        end
    end
    
    //---comb logic to control signals---
    
    always_comb begin
        //if the signal is not set to 1, he is set to 0
        RB_read <= 0;
        RB_addr <= 0; // 16 register
        RB_write <=0;
        //send to alu signals
        addr_register1_to_ALU <= 0 ;addr_register2_to_ALU <= 0;
        add_op <= 0; sub_op <= 0; and_op <= 0; or_op <= 0; xor_op <= 0; sll_op <= 0; srl_op <= 0;not_op <= 0;
        ALU_write <= 0;
        
        //FR_read
        FR_read <= 0;
        //pc signals
        counter_enable <= 0; 
        PC_read <= 0; 
        PC_write <=0;
        // MAR signals
        MAR_read <= 0;
        //RAM signals
        RAM_read <= 0;
        RAM_write <= 0;
        //IR signals
        IR_read <= 0;
        //OUT
        OUT_read <= 0;
        OUT_print_load <= 0;
        //CIN
        cin_get <= 0;
        cin_write <= 0;
        
        //reset counter_step
        incr_counter_step <= 1;
        reset_counter_step <= 0;
        ID_write <= 0;
    //--------FETCH INSTRUCTION-----
        if(counter_step == 0)begin
            PC_write <= 1;
            MAR_read <= 1;
        end else if (counter_step==1)begin
            RAM_write <= 1;
            IR_read <= 1;
            counter_enable <= 1;
        //----Decode the instruction and control signals
        end else begin
            case (IR_instruction)
                //----NOP------
                NOP:begin
                //do nothing during 16 cycles
                end
               //---------ADD---------------
                ADD :begin 
                    if (counter_step == 2) begin                                             
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= rt;
                        RB_addr <= rd;
                        
                        add_op <= 1;
                        
                        ALU_write <= 1;
                        RB_read <= 1;
                        
                        FR_read <= 1;
                        
                        reset_counter_step <= 1;               
                    end
                end
                
                //---------NOT-------------
                NOT_op : begin
                    if (counter_step == 2)begin
                        addr_register1_to_ALU <= rs;
                        RB_addr <= rd;
                        
                        not_op <= 1;
                        
                        ALU_write <= 1;
                        RB_read <= 1;
                        
                        FR_read <= 1;
                        
                        reset_counter_step <= 1;
                    end
                end
                //-------------SUB-------------
                SUB :begin
                    if (counter_step == 2) begin                                             
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= rt;
                        RB_addr <= rd;
                        
                        sub_op <= 1;
                        
                        ALU_write <= 1;
                        RB_read <= 1;
                        
                        FR_read <= 1;
                        
                        reset_counter_step <= 1;               
                    end 
                    
                end  
                //------------AND------------
                AND_op :begin 
                    if (counter_step == 2) begin                                             
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= rt;
                        RB_addr <= rd;
                        
                        and_op <= 1;
                        
                        ALU_write <= 1;
                        RB_read <= 1;
                        
                        FR_read <= 1;
                        
                        reset_counter_step <= 1;               
                    end 
                    
                end 

                //------------OR------------
                OR_op :begin 
                    if (counter_step == 2) begin                                             
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= rt;
                        RB_addr <= rd;
                        
                        or_op <= 1;
                        
                        ALU_write <= 1;
                        RB_read <= 1;
                        
                        FR_read <= 1;
                        
                        reset_counter_step <= 1;               
                    end 
                    
                end 
                  
                //------------ XOR ------------
                XOR_op :begin 
                    if (counter_step == 2) begin                                             
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= rt;
                        RB_addr <= rd;
                        
                        xor_op <= 1;
                        
                        ALU_write <= 1;
                        RB_read <= 1;
                        
                        FR_read <= 1;
                        
                        reset_counter_step <= 1;               
                    end 
                    
                end 

                //------------ SLL ------------
                SLL :begin 
                    if (counter_step == 2) begin
                        ID_write <= 1; 
                        RB_addr <= 1;
                        RB_read <= 1;
                    end else if (counter_step==3)begin                                             
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= 1;
                        RB_addr <= rd;
                        
                        sll_op <= 1;
                        
                        ALU_write <= 1;
                        RB_read <= 1;
                        
                        FR_read <= 1;
                        
                        reset_counter_step <= 1;               
                    end 
                    
                end  

                //------------ SRL ------------
                SRL :begin 
                    if (counter_step == 2) begin
                        ID_write <= 1; 
                        RB_addr <= 1;
                        RB_read <= 1;
                    end else if (counter_step==3)begin                                             
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= 1;
                        RB_addr <= rd;
                        
                        srl_op <= 1;
                        
                        ALU_write <= 1;
                        RB_read <= 1;
                        
                        FR_read <= 1;
                        
                        reset_counter_step <= 1;               
                    end
                    
                end 

                //------------OUT------------
                OUT :begin 
                    if (counter_step == 2) begin                                             
                        RB_addr <= rs;
                        RB_write <= 1;                                            
                        OUT_read <= 1;
                                           
                        
                        reset_counter_step <= 1;               
                    end 
                    
                end
                
                //------------ADDI------------
                ADDI :begin 
                    if (counter_step == 2) begin                                             
                        ID_write <= 1; //write imm on bus
                        RB_addr <= 1; //R1 is tmp register 
                        RB_read <= 1;                                            
                                       
                    end else if (counter_step == 3) begin
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= 1;
                        add_op <= 1;
                        ALU_write <= 1;
                        RB_read <= 1;
                        RB_addr <= rd;
                        
                        FR_read <= 1;
                        
                        reset_counter_step <= 1;;                                                                 
                    end 
                    
                end 

                //------------SUBI------------
                SUBI :begin 
                    if (counter_step == 2) begin                                             
                        ID_write <= 1; //write imm on bus
                        RB_addr <= 1; //R1 is tmp register 
                        RB_read <= 1;                                            
                                       
                    end else if (counter_step == 3) begin
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= 1;
                        sub_op <= 1;
                        ALU_write <= 1;
                        RB_read <= 1;
                        RB_addr <= rd;
                        
                        FR_read <= 1;
                        
                        reset_counter_step <= 1;;                                                                 
                    end 
                    
                end                 
                 
               
                //------------ORI------------
                ORI :begin 
                    if (counter_step == 2) begin                                             
                        ID_write <= 1; //write imm on bus
                        RB_addr <= 1; //R1 is tmp register                                             
                        RB_read <= 1;               
                    end else if (counter_step == 3) begin
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= 1;
                        or_op <= 1;
                        RB_read <= 1;
                        ALU_write <= 1;
                        RB_addr <= rd; 
                        
                        FR_read <= 1;
                        
                        reset_counter_step <= 1;                                                                
                    end
                    
                end  

                //------------ANDI------------
                ANDI :begin 
                    if (counter_step == 2) begin                                             
                        ID_write <= 1; //write imm on bus
                        RB_read <= 1;
                        RB_addr <= 1; //R1 is tmp register                                             
                                       
                    end else if (counter_step == 3) begin
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= 1;
                        and_op <= 1;
                        RB_read <= 1;
                        ALU_write <= 1;
                        RB_addr <= rd;
                        
                        FR_read <= 1; 
                        
                        reset_counter_step <= 1;                                                                
                    end
                    
                end  
                
                //------------SW------------
                SW :begin 
                    if (counter_step == 2) begin                                             
                        ID_write <= 1; //write imm on bus
                        RB_addr <= 1; //R1 is tmp register                                             
                        RB_read <= 1;               
                    end else if (counter_step == 3) begin
                        addr_register1_to_ALU <= rt;
                        addr_register2_to_ALU <= 1;
                        add_op <= 1;
                        ALU_write <= 1;
                        
                        MAR_read <= 1;                                                                 
                    end else if(counter_step==4) begin
                        RB_addr <= rs;
                        RB_write <= 1;
                        
                        RAM_read <= 1;
                        
                        reset_counter_step <= 1;                       
                    end 
                    
                end 
 
                //------------LW------------
                LW :begin 
                    if (counter_step == 2) begin                                             
                        ID_write <= 1; //write imm on bus
                        RB_addr <= 1; //R1 is tmp register                                             
                        RB_read <= 1;                
                    end else if (counter_step == 3) begin
                        addr_register1_to_ALU <= rt;
                        addr_register2_to_ALU <= 1;
                        add_op <= 1;
                        ALU_write <= 1;
                        
                        MAR_read <= 1;                                                                 
                    end else if(counter_step==4) begin
                        RB_addr <= rs;
                        RB_read <= 1;
                        
                        RAM_write <= 1;
                        
                        reset_counter_step <= 1;                       
                    end 
                    
                end 

                //------------J------------
                J :begin 
                    if (counter_step == 2) begin                                             
                        ID_write <= 1; //write imm on bus
                        RB_addr <= 1; //R1 is tmp register                                             
                        RB_read <= 1;                
                    end else if (counter_step == 3) begin
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= 1;
                        add_op <= 1;
                        ALU_write <= 1;
                        
                        PC_read <= 1;
                        
                        reset_counter_step <= 1;                                                                 
                    end 
                    
                end 
                
                //------------ JEQ ------------
                JEQ :begin 
                    if (counter_step == 2) begin
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= rt;
                        sub_op <= 1;
                        FR_read <= 1;
                    end else if (counter_step == 3) begin
                        reset_counter_step <= 1;
                        if (zero_flag_register)begin                                           
                            ID_write <= 1; //write imm on bus
                            PC_read <= 1; 
                        end   
                                                                                                          
                    end 
                    
                end 

                //------------ JNE ------------
                JNE :begin 
                    if (counter_step == 2) begin
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= rt;
                        sub_op <= 1;
                        FR_read <= 1;
                    end else if (counter_step == 3) begin
                        reset_counter_step <= 1;
                        if (!zero_flag_register)begin                                           
                            ID_write <= 1; //write imm on bus
                            PC_read <= 1; 
                        end   
                                                                                                          
                    end 
                    
                end                           

                //------------ JCA ------------
                JCA :begin 
                    if (counter_step == 2) begin
                        if(carry_flag_register)begin
                            ID_write <= 1; // write imm on bus
                            PC_read <= 1;
                        end                      
                        reset_counter_step <= 1;                                                                                                          
                    end 
                    
                end 
                
                //------------ JNC ------------
                JNC :begin 
                    if (counter_step == 2) begin
                        if(!carry_flag_register)begin
                            ID_write <= 1; // write imm on bus
                            PC_read <= 1;
                        end                      
                        reset_counter_step <= 1;                                                                                                          
                    end 
                    
                end 

                //------------ JZE ------------
                JZE :begin 
                    if (counter_step == 2) begin
                        if(zero_flag_register)begin
                            ID_write <= 1; // write imm on bus
                            PC_read <= 1;
                        end                      
                        reset_counter_step <= 1;                                                                                                          
                    end 
                    
                end                 

                //------------ JNZ ------------
                JNZ :begin 
                    if (counter_step == 2) begin
                        if(!zero_flag_register)begin
                            ID_write <= 1; // write imm on bus
                            PC_read <= 1;
                        end                      
                        reset_counter_step <= 1;                                                                                                          
                    end 
                    
                end                                
                //--------LIS--------------------
                LIS : begin
                    if (counter_step == 2)begin
                        ID_write <= 1;
                        RB_addr <= rd;
                        RB_read  <= 1;
                        
                        reset_counter_step <= 1;
                    end
                end
                

                //--------LIU--------------------
                LIU : begin
                    if (counter_step == 2)begin
                        ID_write <= 1;
                        RB_addr <= rd;
                        RB_read  <= 1;
                        
                        reset_counter_step <= 1;
                    end
                end
                
                //---------CIN-------------------
                CIN : begin
                    if(counter_step == 2)begin
                        cin_get <= 1;
                        OUT_print_load <= 1;
                        //wait user for value
                        if (!cin_done) 
                            incr_counter_step <= 0;
                        else
                            incr_counter_step <= 1;
                             
                    end else if (counter_step == 3)begin
                        RB_addr <= rd;
                        RB_read <= 1;
                        cin_write <= 1;
                        
                        reset_counter_step <= 1;
                    end
                end
                
                //-------JUMP_USER---------------------
                J_USER :begin 
                    if (counter_step == 2)begin
                        cin_get <= 1;
                        //wait user for value
                        if (!cin_done) 
                            incr_counter_step <= 0;
                        else
                            incr_counter_step <= 1;
                                
                    end else if (counter_step == 3) begin                                             
                        ID_write <= 1; //write imm on bus
                        RB_addr <= 1; //R1 is tmp register                                             
                        RB_read <= 1;                
                    end else if (counter_step == 4) begin
                        addr_register1_to_ALU <= rs;
                        addr_register2_to_ALU <= 1;
                        add_op <= 1;
                        ALU_write <= 1;
                        
                        PC_read <= 1;
                        
                        reset_counter_step <= 1;                                                                 
                    end 
                    
                end              
                //--------HALT---------------------
                HALT:begin
                    incr_counter_step <= 0;
                end
                //--------NOP----------------
                default : begin
                    //do nothing
                    
                end                                                            
                                 
            endcase
        end
    end
    
    
    
    

endmodule