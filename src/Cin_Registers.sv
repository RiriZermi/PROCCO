`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2024 15:09:01
// Design Name: 
// Module Name: Cin_Register
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


module Cin(
input logic clk, reset,
inout tri0[31:0] bus,
input logic[15:0] value,
input logic confirm_value,
input logic cin_get, //-to control
output logic cin_done, 
input logic cin_write
    );
    
    logic[15:0] cin_registers;
    
    logic tmp_d, tmp_d2;
    
    //cin_done = 1 only rising edge of confirm value
    always_ff @(posedge clk) begin
        if (reset) begin
            tmp_d <= 0;
            tmp_d2 <= 0;
        end else begin
            tmp_d <= confirm_value;
            tmp_d2 <= tmp_d; //copie tmp_d ave un cycle de restard
        end
    end
    
    always_ff @(posedge clk) begin
        if (reset) begin
            cin_done <= 0;
        end else begin
            // Quand un front montant est détecté sur ready, active done pendant un cycle
            if (tmp_d2 == 0 && tmp_d == 1) begin
                cin_done <= 1;
            end else begin
                cin_done <= 0;
            end
        end
     end
     
     //------   
    
    always_ff @(posedge clk)begin
        if (reset) begin
            cin_registers <= 0;
        end else begin
            if (cin_done && cin_get)begin
                cin_registers <= value;
            end              
        end
    end
    
    assign bus = cin_write ? cin_registers : 32'hZ; 
    
   
endmodule
