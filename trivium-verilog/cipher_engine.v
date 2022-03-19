//////////////////////////////////////////////////////////////////////////////////
// Engineer:         Christian P. Feist
// 
// Create Date:      16:06:43 05/04/2016 
// Design Name:      /
// Module Name:      cipher_engine
// Project Name:     Trivium
// Target Devices:   Spartan-6, Zynq
// Tool versions:    ISE 14.7, Vivado v2016.2
// Description:      This component realizes the actual Trivium architecture. It
//                   consists of three unique shift registers (see shift_reg) that
//                   are combined to form the key stream generation logic.
//                   This module can be interfaced to preload keys, IVs and input
//                   plaintext bits to obtain the corresponding ciphertext bits.
//
// Dependencies:     /
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Minor modification to initialize register C 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
`default_nettype none

module cipher_engine(
    /* Standard control signals */
    input   wire            clk_i,      /* System clock */
    input   wire            n_rst_i,    /* Asynchronous active low reset */
    input   wire            ce_i,       /* Chip enable */
    
    /* Data related signals */
    input   wire    [31:0]  ld_dat_i,   /* External data */
    input   wire    [2:0]   ld_reg_a_i, /* Load external value into A */
    input   wire    [2:0]   ld_reg_b_i, /* Load external value into B */
    input   wire            dat_i,      /* Input bit */
    output  wire            dat_o       /* Output bit */
);

//////////////////////////////////////////////////////////////////////////////////
// Signal definitions
//////////////////////////////////////////////////////////////////////////////////
wire    reg_a_out_s;    /* reg_a output */
wire    reg_b_out_s;    /* reg_b output */
wire    reg_c_out_s;    /* reg_c output */
wire    z_a_s;          /* Partial key stream output from reg_a */
wire    z_b_s;          /* Partial key stream output from reg_b */
wire    z_c_s;          /* Partial key stream output from reg_c */
wire    key_stream_s;   /* Key stream bit */

//////////////////////////////////////////////////////////////////////////////////
// Module instantiations
//////////////////////////////////////////////////////////////////////////////////
shift_reg #(
        .REG_SZ(93),
        .FEED_FWD_IDX(65),
        .FEED_BKWD_IDX(68)
    ) 
    reg_a(
        .clk_i(clk_i),
        .n_rst_i(n_rst_i),
        .ce_i(ce_i),
        .ld_i(ld_reg_a_i),
        .ld_dat_i(ld_dat_i),
        .dat_i(reg_c_out_s),
        .dat_o(reg_a_out_s),
        .z_o(z_a_s)
    );
   
shift_reg #(
        .REG_SZ(84),
        .FEED_FWD_IDX(68),
        .FEED_BKWD_IDX(77)
    ) 
    reg_b(
        .clk_i(clk_i),
        .n_rst_i(n_rst_i),
        .ce_i(ce_i),
        .ld_i(ld_reg_b_i),
        .ld_dat_i(ld_dat_i),
        .dat_i(reg_a_out_s),
        .dat_o(reg_b_out_s),
        .z_o(z_b_s)
    );
   
shift_reg #(
        .REG_SZ(111),
        .FEED_FWD_IDX(65),
        .FEED_BKWD_IDX(86)
    ) 
    reg_c(
        .clk_i(clk_i),
        .n_rst_i(n_rst_i),
        .ce_i(ce_i),
        .ld_i(ld_reg_b_i),    /* This is only necessary s.t. the reg will contain 1110000...00 */
        .ld_dat_i(0),
        .dat_i(reg_b_out_s),
        .dat_o(reg_c_out_s),
        .z_o(z_c_s)
    );
   
//////////////////////////////////////////////////////////////////////////////////
// Output calculations
//////////////////////////////////////////////////////////////////////////////////
assign key_stream_s = z_a_s ^ z_b_s ^ z_c_s;
assign dat_o = dat_i ^ key_stream_s;

endmodule
