`default_nettype none
module trivium(output reg s, input wire [80:1] IV, KEY, input wire rst, clk);

    // declare main shift registers
    reg [92:0]  srs93;
    reg [83:0]  srs84;
    reg [110:0] srs111;

    integer i;
    reg t1, t2, t3;
    reg a1, a2, a3;

    always @(posedge clk) begin
        if (rst) begin
            $display("Initialization.");
            srs93   = {13'b0, KEY};
            srs84   = {4'b0, IV};
            srs111  = {3'b111, 108'b0};
            for(i = 1; i <= 4 * 288; i = i + 1) begin
                t1 = srs93[65] ^ srs93[92];
                t2 = srs84[68] ^ srs84[83];
                t3 = srs111[65] ^ srs111[110];

                s = t1 ^ t2 ^ t3;

                a1 = t1 ^ (srs93[90] & srs93[91]) ^ srs84[77];
                a2 = t2 ^ (srs84[81] & srs84[82]) ^ srs111[86];
                a3 = t3 ^ (srs111[108] & srs111[109]) ^ srs93[68];

                srs93[92:1] = srs93[91:0];
                srs93[0] = a3;
                srs84[83:1] = srs84[82:0];
                srs84[0] = a1;
                srs111[110:1] = srs111[109:0];
                srs111[0] = a2;
            end
            $display("Initialization finished.");
        end
        else begin
            t1 = srs93[65] ^ srs93[92];
            t2 = srs84[68] ^ srs84[83];
            t3 = srs111[65] ^ srs111[110];

            s = t1 ^ t2 ^ t3;

            a1 = t1 ^ (srs93[90] & srs93[91]) ^ srs84[77];
            a2 = t2 ^ (srs84[81] & srs84[82]) ^ srs111[86];
            a3 = t3 ^ (srs111[108] & srs111[109]) ^ srs93[68];

            srs93[92:1] = srs93[91:0];
            srs93[0] = a3;
            srs84[83:1] = srs84[82:0];
            srs84[0] = a1;
            srs111[110:1] = srs111[109:0];
            srs111[0] = a2;
        end
    end

endmodule
