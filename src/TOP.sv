`timescale 1ns / 1ps
//`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.11.2024 14:39:11
// Design Name: 
// Module Name: TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Procco(
input logic clk ,reset_n,
input logic[15:0] value,
input logic user_confirm,
output logic[6:0] SEG,
output logic[7:0] AN,
output logic LED
    );
    //------PARAM--------
    localparam MAR_register_size = 10;
    localparam RAM_adress_size = 2 ** MAR_register_size;
    //signals
    
    logic reset;
    
    //------------controls signals------------
    //---bank register signals
    logic RB_read,RB_write;
    logic[3:0] RB_addr,addr_register1_to_ALU,addr_register2_to_ALU;
    //---------ALU signals
    logic ALU_write;
    logic add_op,sub_op, and_op, xor_op, or_op,sll_op,srl_op,not_op;
    //---- Flag register
    logic FR_read;
    //-------PC signals
    logic counter_enable,PC_read,PC_write;
    //---MAR signals
    logic MAR_read;
    //RAM signals
    logic RAM_read,RAM_write;
    //IR signals
    logic IR_read,IR_write;
    logic [9:0] MAR_register;
    //OUT
    logic OUT_read;
    logic OUT_print_load;
    //CIN
    logic cin_get,cin_done,cin_write;
    //-------tier signals
    logic [31:0] register1_to_ALU,register2_to_ALU;
    logic carry_flag_register, zero_flag_register;
    logic[31:0] IR_register;
    
    //ALU->carry_flag
    logic carry_flag,zero_flag;
    

    
    assign reset = !reset_n;
    //---------------------------------------------
    tri0[31:0] bus_nets;

    
    //--------Bank Register---------------------------
    Register_Bank bank(.clk(clk),
        .reset(reset), 
        .bus(bus_nets),
        .RB_read(RB_read),//-to control
        .RB_write(RB_write),//-to control
        .RB_addr(RB_addr),//-to control
        .addr_register1_to_ALU(addr_register1_to_ALU),//-to control
        .addr_register2_to_ALU(addr_register2_to_ALU),//-to control
        .register1_to_ALU(register1_to_ALU),
        .register2_to_ALU(register2_to_ALU)
        );
        
     //--------------ALU------------------------
     ALU alu_i(.register1(register1_to_ALU),
     .register2(register2_to_ALU),
     .add_op(add_op),//-to control
     .sub_op(sub_op),//-to control
     .and_op(and_op),//-to control
     .or_op(or_op),//-to control
     .xor_op(xor_op),//-to control
     .sll_op(sll_op),//-to control
     .srl_op(srl_op),//-to control
     .not_op(not_op), //-to control
     .ALU_write(ALU_write),//-to control
     .bus(bus_nets),
     .zero_flag(zero_flag),
     .carry_flag(carry_flag));
     
     //---------------FLAG REGISTER-----------------------
     FLAG_REGISTER FR_i(.clk(clk),
     .reset(reset),
     .FR_read(FR_read), //-to control
     .carry_flag(carry_flag),
     .zero_flag(zero_flag),
     .carry_flag_register(carry_flag_register),
     .zero_flag_register(zero_flag_register));
     
     //-------------PROGRAM COUNTER--------------------------
     Program_Counter PC_i(.clk(clk),
     .reset(reset),
     .counter_enable(counter_enable),//-to control
     .PC_read(PC_read),//-to control
     .PC_write(PC_write),//-to control
     .bus(bus_nets));
     
     
     //---------------MEMORY ADRESS REGISTER---------------------------
     Memory_Adress_Register #(.MAR_register_size(MAR_register_size))MAR_i(.clk(clk),
     .reset(reset),
     .MAR_read(MAR_read),//-to control
     .MAR_register(MAR_register),
     .bus(bus_nets));
     
     //---------------- RAM ( data + instruction) -------------------
     RAM #(.RAM_adress_size(RAM_adress_size))ram_i(
     .clk(clk),
     .addr(MAR_register),
     .RAM_read(RAM_read),//-to control
     .RAM_write(RAM_write),//-to control
     .bus(bus_nets));
     
     //------------Instruction Register-----------------------

     Instructions_Register IR_i(.clk(clk),
     .reset(reset),
     .IR_read(IR_read),
     .bus(bus_nets),
     .IR_register(IR_register));
     
//     -----------OUPUT ON SEGMENT DISPLAY---------------------
     Output_SEG OUT_i(.clk(clk),
     .reset(reset),
     .OUT_read(OUT_read),
     .bus(bus_nets),
     .SEG(SEG),
     .print_load(OUT_print_load),
     .AN(AN));
     
////     --------------If control is ON make LED blink ( blink when user need to do something)-----------
     led_blinker Blinker_i(.clk(clk),
     .reset(reset),
     .control(cin_get),
     .led(LED));
     
//     ------------ CIN interact with user ----------------
     Cin Cin_i(.clk(clk),
     .reset(reset),
     .confirm_value(user_confirm),
     .value(value),
     .cin_write(cin_write),
     .cin_get(cin_get),
     .cin_done(cin_done),
     .bus(bus_nets)
     );
     
     //------------Instruction Decoder + control logic----------------
     Instruction_Decoder ID_i(
         .clk(clk),
         .reset(reset),
         .bus(bus_nets),
         .IR_register(IR_register),
         .zero_flag_register(zero_flag_register),
         .carry_flag_register(carry_flag_register),
         //bank signals
         .RB_read(RB_read),
         .RB_write(RB_write),
         .RB_addr(RB_addr),
         .addr_register1_to_ALU(addr_register1_to_ALU),
         .addr_register2_to_ALU(addr_register2_to_ALU),
         //ALu signals
         .add_op(add_op),
         .sub_op(sub_op),
         .and_op(and_op),
         .or_op(or_op),
         .xor_op(xor_op),
         .not_op(not_op),
         .sll_op(sll_op),
         .srl_op(srl_op),
         .ALU_write(ALU_write),
         //flag
         .FR_read(FR_read),
         //PC signals
         .counter_enable(counter_enable),
         .PC_read(PC_read),
         .PC_write(PC_write),
         //MAR signals
         .MAR_read(MAR_read),
         //RAM signals
         .RAM_read(RAM_read),
         .RAM_write(RAM_write),
         //IR signals
         .IR_read(IR_read),
         //OUT
         .OUT_read(OUT_read),
         .OUT_print_load(OUT_print_load),
         //CIN
         .cin_write(cin_write),
         .cin_get(cin_get),
         .cin_done(cin_done)
         );
       
    
    
endmodule
