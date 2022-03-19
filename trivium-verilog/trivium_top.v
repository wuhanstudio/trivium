//////////////////////////////////////////////////////////////////////////////////
// Engineer:         Christian P. Feist
// 
// Create Date:      17:54:27 05/04/2016 
// Design Name:      /
// Module Name:      trivium_top
// Project Name:     Trivium
// Target Devices:   Spartan-6, Zynq
// Tool versions:    ISE 14.7, Vivado v2016.2
// Description:      The top module of the Trivium core. It simply realizes
//                   a state machine that controls the cipher_engine component.
//
// Dependencies:     /
//
// Revision: 
// Revision 0.01 - File Created 
// Revision 0.02 - Modified core for use with AXI-Lite protocol
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
`default_nettype none

module trivium_top(
    /* Module inputs */
    input   wire            clk_i,      /* System clock */
    input   wire            n_rst_i,    /* Asynchronous active low reset */
    input   wire    [31:0]  dat_i,      /* Cipher input data */
    input   wire    [31:0]  ld_dat_i,   /* Key and IV data */
    input   wire    [2:0]   ld_reg_a_i, /* Load value into reg_a */
    input   wire    [2:0]   ld_reg_b_i, /* Load value into reg_b */   
    input   wire            init_i,     /* Initialize the cipher */
    input   wire            proc_i,     /* Process input using current instance */

    /* Module outputs */
    output  reg     [31:0]  dat_o,      /* Current cipher output */
    output  wire            busy_o      /* Busy flag */     
);

//////////////////////////////////////////////////////////////////////////////////
// Signal definitions
//////////////////////////////////////////////////////////////////////////////////
reg     [2:0]   next_state_s;   /* Next state of the FSM */
reg     [2:0]   cur_state_r;    /* Current state of the FSM */
reg     [10:0]  cntr_r;         /* Counter for warm-up and input processing */
reg             cphr_en_r;      /* Cipher enable flag */
reg     [31:0]  dat_r;          /* Buffered version of dat_i */
wire            bit_out_s;      /* Cipher output bit */
integer i;

//////////////////////////////////////////////////////////////////////////////////
// Local parameter definitions
//////////////////////////////////////////////////////////////////////////////////
parameter   IDLE_e = 0, 
            WARMUP_e = 1, 
            WAIT_PROC_e = 2, 
            PROC_e = 3;

//////////////////////////////////////////////////////////////////////////////////
// Module instantiations
//////////////////////////////////////////////////////////////////////////////////
cipher_engine cphr(
    .clk_i(clk_i),
    .n_rst_i(n_rst_i),
    .ce_i(cphr_en_r),
    .ld_dat_i(ld_dat_i),
    .ld_reg_a_i(ld_reg_a_i),
    .ld_reg_b_i(ld_reg_b_i),
    .dat_i(dat_r[0]),
    .dat_o(bit_out_s)
);

//////////////////////////////////////////////////////////////////////////////////
// Initial register values
//////////////////////////////////////////////////////////////////////////////////
assign busy_o = cphr_en_r;
initial begin
    cur_state_r = IDLE_e;
    cntr_r = 0;
    cphr_en_r = 1'b0;
end

//////////////////////////////////////////////////////////////////////////////////
// Next state logic of the FSM
//////////////////////////////////////////////////////////////////////////////////
always @(*) begin
    case (cur_state_r)
        IDLE_e:
            /* Wait until the user initializes the module */
            if (init_i)
                next_state_s = WARMUP_e;
            else
                next_state_s = IDLE_e;
            
        WARMUP_e:
            /* Warm up the cipher */
            if (cntr_r == 1151)
                next_state_s = WAIT_PROC_e;
            else
                next_state_s = WARMUP_e;
            
        WAIT_PROC_e:
            if (proc_i)         /* Calculation for current settings is being started */
                next_state_s = PROC_e;
            else if (init_i)    /* Warmup phase, probably for new key o */
                next_state_s = WARMUP_e;
            else
                next_state_s = WAIT_PROC_e;
            
        PROC_e:
            /* Process all 32 input data bits */
            if (cntr_r == 31)
                next_state_s = WAIT_PROC_e;
            else
                next_state_s = PROC_e;
            
        default:
            next_state_s = cur_state_r;
    endcase
end

//////////////////////////////////////////////////////////////////////////////////
// State save and output logic of the FSM
//////////////////////////////////////////////////////////////////////////////////
always @(posedge clk_i or negedge n_rst_i) begin
    if (!n_rst_i) begin
        /* Reset registers driven here */
        cntr_r <= 0;
        cur_state_r <= IDLE_e;
        cphr_en_r <= 1'b0;
        dat_o <= 0;
        dat_r <= 0;
    end
    else begin
        /* State save logic */
        cur_state_r <= next_state_s;
      
        /* Output logic */
        case (cur_state_r)
            IDLE_e: begin
                if (next_state_s == WARMUP_e) begin
                    /* Enable cipher and initialize */
                    cphr_en_r <= 1'b1;
                end
            end
         
            WARMUP_e: begin
                if (next_state_s == WAIT_PROC_e) begin
                    cntr_r <= 0;
                    cphr_en_r <= 1'b0;
                end
                else begin
                    /* Increment the warm-up phase counter */
                    cntr_r <= cntr_r + 1;
                end
            end
         
            WAIT_PROC_e: begin
                /* Wait until data to encrypt/decrypt is being presented */
                if (next_state_s == PROC_e) begin
                    cphr_en_r <= 1'b1;
                    dat_r <= dat_i;
                end
                else if (next_state_s == WARMUP_e)
                    cphr_en_r <= 1'b1;
            end
         
            PROC_e: begin
                if (next_state_s == WAIT_PROC_e) begin
                    cphr_en_r <= 1'b0;
                    cntr_r <= 0;
                end
                else
                    cntr_r <= cntr_r + 1;
                    
                /* Shift the input data register */
                dat_r <= {1'b0, dat_r[31:1]};
            
                /* Shift the output bits into the output register */
                dat_o <= {bit_out_s, dat_o[31:1]};
            end
         
        endcase
    end
end

endmodule
