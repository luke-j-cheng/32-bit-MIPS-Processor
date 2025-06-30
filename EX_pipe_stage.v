`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    wire [3:0] ALU_Control;
    wire [31:0] ALU1, ALU2temp, ALU2;
    
    // Write your code here
    
    assign alu_in2_out = ALU2temp;
    
    ALUControl alu_control_inst(
        .ALUOp(id_ex_alu_op),
        .Function(id_ex_instr[5:0]),
        .ALU_Control(ALU_Control)
    );
    
    mux4 #(32) reg1mux(
        .a(reg1),
        .c(ex_mem_alu_result),
        .b(mem_wb_write_back_result),
        .d(32'b0),
        .sel(Forward_A),
        .y(ALU1));
    
    mux4 #(32) reg2mux(
        .a(reg2),
        .c(ex_mem_alu_result),
        .b(mem_wb_write_back_result),
        .d(32'b0),
        .sel(Forward_B),
        .y(ALU2temp));
    
    mux2 #(32) alumux(
        .a(ALU2temp),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        .y(ALU2));
   
    ALU     alu(
        .a(ALU1),
        .b(ALU2),
        .alu_control(ALU_Control),
        .alu_result(alu_result));
       
endmodule
