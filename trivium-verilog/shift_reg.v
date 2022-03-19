//////////////////////////////////////////////////////////////////////////////////
// Engineer:         Christian P. Feist
// 
// Create Date:      14:04:57 05/04/2016 
// Design Name:      /
// Module Name:      shift_reg 
// Project Name:     Trivium
// Target Devices:   Spartan-6, Zynq
// Tool versions:    ISE 14.7, Vivado v2016.2
// Description:      A simple shift register that may be pre-loaded. The shift register
//                   incorporates a specified feedback and feedforward path.
//                   This component is designed in such a way that the logic required for
//                   Trivium can be obtained by combining three such register, each with
//                   a specific set of parameters.
//
// Dependencies:     /
//
// Revision: 
// Revision 0.01 - File Created
// Revision 0.02 - Fixed the mandatory reset issue 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
`default_nettype none

module shift_reg #(
    parameter REG_SZ = 93,
    parameter FEED_FWD_IDX = 65,
    parameter FEED_BKWD_IDX = 68
) 
(
    /* Standard control signals */
    input   wire            clk_i,      /* System clock */
    input   wire            n_rst_i,    /* Asynchronous active low reset */
    input   wire            ce_i,       /* Chip enable */
      
   /* Input and output data related signals */
    input   wire    [2:0]   ld_i,       /* Load external value */
    input   wire    [31:0]  ld_dat_i,   /* External input data */
    input   wire            dat_i,      /* Input bit from other register */
    output  wire            dat_o,      /* Output bit  to other register */
    output  wire            z_o         /* Output for the key stream */
);

//////////////////////////////////////////////////////////////////////////////////
// Signal definitions
//////////////////////////////////////////////////////////////////////////////////
reg     [(REG_SZ - 1):0]    dat_r;      /* Shift register contents */
wire                        reg_in_s;   /* Shift register input (feedback value) */

//////////////////////////////////////////////////////////////////////////////////
// Feedback calculation
//////////////////////////////////////////////////////////////////////////////////
assign reg_in_s = dat_i ^ dat_r[FEED_BKWD_IDX];

//////////////////////////////////////////////////////////////////////////////////
// Shift register process
//////////////////////////////////////////////////////////////////////////////////
always @(posedge clk_i or negedge n_rst_i) begin
    if (!n_rst_i)
        dat_r <= 0;
    else begin
        if (ce_i) begin
            /* Shift contents of register */
            dat_r <= {dat_r[(REG_SZ - 2):0], reg_in_s};
        end
        else if (ld_i != 3'b000) begin /* Load external values into register */
            if (ld_i[0])
                dat_r[31:0] <= ld_dat_i;
            else if (ld_i[1])
                dat_r[63:32] <= ld_dat_i;
            else if (ld_i[2])
                dat_r[79:64] <= ld_dat_i[15:0];
         
            /* Set all top bits to zero, except in case of register C */   
            dat_r[(REG_SZ - 1):80] <= 0;
            if (REG_SZ == 111)
                dat_r[(REG_SZ - 1)-:3] <= 3'b111;
        end
    end
end

//////////////////////////////////////////////////////////////////////////////////
// Output calculations
//////////////////////////////////////////////////////////////////////////////////
assign z_o = (dat_r[REG_SZ - 1] ^ dat_r[FEED_FWD_IDX]);
assign dat_o = z_o ^ (dat_r[REG_SZ - 2] & dat_r[REG_SZ - 3]); 

endmodule
