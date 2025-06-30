`timescale 1ns / 1ps


module mips_32(
    input clk, reset,  
    output[31:0] result
    );
    
// define all the wires here. You need to define more wires than the ones you did in Lab2
    
    //IF Wires
    
    wire [9:0] branch_address, jump_address;
    wire branch_taken, jump;
    
    // IF/ID Wires
    
    wire [31:0] instr, if_id_instr; // I/O for IF/ID Register
    wire [9:0] pc_plus4, if_id_pc_plus4;   
    wire en;
    wire flush;
    
    // ID Wires
    
    wire [4:0] mem_wb_write_reg_addr;
    wire Data_Hazard;
    wire Control_Hazard;
    
    // ID/EX Wires
    wire [31:0] id_ex_instr;
    wire [31:0] imm_value, id_ex_imm_value;
    wire [1:0] alu_op, id_ex_alu_op;
    wire [31:0] reg1, id_ex_reg1;
    wire [31:0] reg2, id_ex_reg2;
    wire [4:0] destination_reg, id_ex_destination_reg;
    wire alu_src, id_ex_alu_src;
    wire mem_read, id_ex_mem_read;
    wire mem_to_reg, id_ex_mem_to_reg;
    wire mem_write, id_ex_mem_write;
    wire reg_write, id_ex_reg_write;
    
    
    //EX Wires
    wire [1:0] Forward_A, Forward_B;

    // EX/MEM Wires
    wire [4:0] ex_mem_destination_reg, ex_mem_write_reg_addr;
    wire ex_mem_mem_to_reg;
    wire ex_mem_mem_read;
    wire ex_mem_mem_write;
    wire ex_mem_reg_write;
    wire [31:0] ex_mem_instr;
    wire [31:0] alu_in2_out, ex_mem_alu_in2_out;
    wire [31:0] alu_result, ex_mem_alu_result;
    
    
    // MEM/WB Wires
    wire [31:0] mem_wb_alu_result;
    wire mem_wb_mem_to_reg;
    wire mem_wb_reg_write;
    wire [4:0] mem_wb_destination_reg;
    wire [31:0] mem_read_data, mem_wb_mem_read_data;
    wire [31:0] write_back_data;



    assign result = write_back_data;
    assign en = Data_Hazard;
// Build the pipeline as indicated in the lab manual

///////////////////////////// Instruction Fetch    
    // Complete your code here      
    IF_pipe_stage IF_instant(
        .clk(clk),
        .reset(reset),
        .en(en),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .jump(jump),
        .pc_plus4(pc_plus4),
        .instr(instr));
    
        
///////////////////////////// IF/ID registers
    // Complete your code here
    
    pipe_reg_en #(32) instr_ff(
        .clk(clk),
        .reset(reset),
        .en(en),
        .flush(flush),
        .d(instr),
        .q(if_id_instr));
    
    pipe_reg_en #(10) pc_ff(
        .clk(clk),
        .reset(reset),
        .en(en),
        .flush(flush),
        .d(pc_plus4),
        .q(if_id_pc_plus4));   
   
///////////////////////////// Instruction Decode 
	// Complete your code here
    ID_pipe_stage ID_instant(
        .clk(clk),
        .reset(reset),
        .pc_plus4(if_id_pc_plus4),
        .instr(if_id_instr),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg),
        .mem_wb_write_back_data(write_back_data),
        .Data_Hazard(Data_Hazard),
        .Control_Hazard(flush),
        .reg1(reg1),
        .reg2(reg2),
        .imm_value(imm_value),
        .branch_address(branch_address),
        .jump_address(jump_address),
        .branch_taken(branch_taken),
        .destination_reg(destination_reg),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump(jump));
  
///////////////////////////// ID/EX registers 
	// Complete your code here

    pipe_reg #(32) reg1_ff(
        .clk(clk),
        .reset(reset),
        .d(reg1),
        .q(id_ex_reg1));
    
    pipe_reg #(32) reg2_ff(
        .clk(clk),
        .reset(reset),
        .d(reg2),
        .q(id_ex_reg2));
    
    pipe_reg #(32) imm_value_ff(
        .clk(clk),
        .reset(reset),
        .d(imm_value),
        .q(id_ex_imm_value));
    
    pipe_reg #(32) id_ex_instr_ff(
        .clk(clk),
        .reset(reset),
        .d(if_id_instr),
        .q(id_ex_instr));   
    
    pipe_reg #(5) destination_reg_ff(
        .clk(clk),
        .reset(reset),
        .d(destination_reg),
        .q(id_ex_destination_reg));
    
    pipe_reg #(1) mem_to_reg_ff(
        .clk(clk),
        .reset(reset),
        .d(mem_to_reg),
        .q(id_ex_mem_to_reg));
    
    pipe_reg #(2) alu_op_ff(
        .clk(clk),
        .reset(reset),
        .d(alu_op),
        .q(id_ex_alu_op));
    
    pipe_reg #(1) mem_read_ff(
        .clk(clk),
        .reset(reset),
        .d(mem_read),
        .q(id_ex_mem_read));
    
    pipe_reg #(1) mem_write_ff(
        .clk(clk),
        .reset(reset),
        .d(mem_write),
        .q(id_ex_mem_write));
    
    pipe_reg #(1) alu_src_ff(
        .clk(clk),
        .reset(reset),
        .d(alu_src),
        .q(id_ex_alu_src));
    
    pipe_reg #(1) reg_write_ff(
        .clk(clk),
        .reset(reset),
        .d(reg_write),
        .q(id_ex_reg_write));
    

    

///////////////////////////// Hazard_detection unit
	// Complete your code here    
    Hazard_detection hd_instant(
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_destination_reg(id_ex_destination_reg),
        .if_id_rs(if_id_instr[25:21]),
        .if_id_rt(if_id_instr[20:16]),
        .branch_taken(branch_taken),
        .jump(jump),
        .Data_Hazard(Data_Hazard),
        .IF_Flush(flush));       
         
///////////////////////////// Execution    
	// Complete your code here
	EX_pipe_stage ex_instant(
	    .id_ex_instr(id_ex_instr),
	    .reg1(id_ex_reg1),
	    .reg2(id_ex_reg2),
	    .id_ex_imm_value(id_ex_imm_value),
	    .ex_mem_alu_result(ex_mem_alu_result),
	    .mem_wb_write_back_result(write_back_data),
	    .id_ex_alu_src(id_ex_alu_src),
	    .id_ex_alu_op(id_ex_alu_op),
	    .Forward_A(Forward_A),
	    .Forward_B(Forward_B),
	    .alu_in2_out(alu_in2_out),
	    .alu_result(alu_result));

        
///////////////////////////// Forwarding unit
	// Complete your code here 
    EX_Forwarding_unit ef_instant(
        .ex_mem_reg_write(ex_mem_reg_write),
        .ex_mem_write_reg_addr(ex_mem_destination_reg),
        .id_ex_instr_rs(id_ex_instr[25:21]),
        .id_ex_instr_rt(id_ex_instr[20:16]),
        .mem_wb_reg_write(mem_wb_reg_write),
        .mem_wb_write_reg_addr(mem_wb_destination_reg),
        .Forward_A(Forward_A),
        .Forward_B(Forward_B));
        
     
///////////////////////////// EX/MEM registers
	// Complete your code here 
    
    pipe_reg #(5) ex_mem_destination_reg_ff(
        .clk(clk),
        .reset(reset),
        .d(id_ex_destination_reg),
        .q(ex_mem_destination_reg));

    pipe_reg #(1) ex_mem_mem_to_reg_ff(
        .clk(clk),
        .reset(reset),
        .d(id_ex_mem_to_reg),
        .q(ex_mem_mem_to_reg));
    
    pipe_reg #(1) ex_mem_mem_read_ff(
        .clk(clk),
        .reset(reset),
        .d(id_ex_mem_read),
        .q(ex_mem_mem_read));
    
    pipe_reg #(1) ex_mem_mem_write_ff(
        .clk(clk),
        .reset(reset),
        .d(id_ex_mem_write),
        .q(ex_mem_mem_write));
    
    pipe_reg #(1) ex_mem_reg_write_ff(
        .clk(clk),
        .reset(reset),
        .d(id_ex_reg_write),
        .q(ex_mem_reg_write));
    
    pipe_reg #(32) ex_mem_instr_ff(
        .clk(clk),
        .reset(reset),
        .d(id_ex_instr),
        .q(ex_mem_instr));
   
   pipe_reg #(32) ex_mem_alu_in2_out_ff(
        .clk(clk),
        .reset(reset),
        .d(alu_in2_out),
        .q(ex_mem_alu_in2_out));

    pipe_reg #(32) ex_mem_alu_result_ff(
        .clk(clk),
        .reset(reset),
        .d(alu_result),
        .q(ex_mem_alu_result));


    
///////////////////////////// memory    
	// Complete your code here
    data_memory data_mem(
        .clk(clk),
        .mem_access_addr(ex_mem_alu_result),
        .mem_write_data(ex_mem_alu_in2_out),
        .mem_write_en(ex_mem_mem_write),
        .mem_read_en(ex_mem_mem_read),
        .mem_read_data(mem_read_data)
);


///////////////////////////// MEM/WB registers  
	// Complete your code here
    
    pipe_reg #(32) mem_wb_alu_result_ff(
        .clk(clk),
        .reset(reset),
        .d(ex_mem_alu_result),
        .q(mem_wb_alu_result));
    
    pipe_reg #(1) mem_wb_mem_to_reg_ff(
        .clk(clk),
        .reset(reset),
        .d(ex_mem_mem_to_reg),
        .q(mem_wb_mem_to_reg));
    
    pipe_reg #(1) mem_wb_reg_write_ff(
        .clk(clk),
        .reset(reset),
        .d(ex_mem_reg_write),
        .q(mem_wb_reg_write));
    
    pipe_reg #(5) mem_wb_destination_reg_ff(
        .clk(clk),
        .reset(reset),
        .d(ex_mem_destination_reg),
        .q(mem_wb_destination_reg));
    
    pipe_reg #(32) mem_read_data_ff(
        .clk(clk),
        .reset(reset),
        .d(mem_read_data),
        .q(mem_wb_mem_read_data));

///////////////////////////// writeback    
	// Complete your code here
    
    mux2 #(32) writeback_mux(
        .a(mem_wb_alu_result),
        .b(mem_wb_mem_read_data),
        .sel(mem_wb_mem_to_reg),
        .y(write_back_data));

endmodule
