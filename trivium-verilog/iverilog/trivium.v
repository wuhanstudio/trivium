`default_nettype none
module trivium(output reg s, input wire [80:1] IV, KEY, input wire rst, clk);

    // declare main shift registers
    reg [93:1]  srs93;
    reg [84:1]  srs84;
    reg [111:1] srs111;

    integer i;
    reg t1, t2, t3;
    reg a1, a2, a3;

    always @(posedge rst or posedge clk) begin
        if (rst) begin
            $display("Initialization.");
            srs93   = {13'b0, KEY};
            srs84   = {4'b0, IV};
            srs111  = {3'b111, 108'b0};

            for(i = 0; i < 4 * 288; i = i + 1) begin
                t1 = srs93[66] ^ srs93[93];
                t2 = srs84[69] ^ srs84[84];
                t3 = srs111[66] ^ srs111[111];
                s = t1 ^ t2 ^ t3;
                a1 = t1 ^ (srs93[91] & srs93[92]) ^ srs84[78];
                a2 = t2 ^ (srs84[82] & srs84[83]) ^ srs111[87];
                a3 = t3 ^ (srs111[109] & srs111[110]) ^ srs93[69];
                srs93   = {srs93[92:1], a3};
                srs84   = {srs84[83:1], a1};
                srs111  = {srs111[110:1], a2};
            end
            $display("Initialization finished.");
        end
        else begin
            t1 = srs93[66] ^ srs93[93];
            t2 = srs84[69] ^ srs84[84];
            t3 = srs111[66] ^ srs111[111];
            s = t1 ^ t2 ^ t3;
            a1 = t1 ^ (srs93[91] & srs93[92]) ^ srs84[78];
            a2 = t2 ^ (srs84[82] & srs84[83]) ^ srs111[87];
            a3 = t3 ^ (srs111[109] & srs111[110]) ^ srs93[69];
            srs93   = {srs93[92:1], a3};
            srs84   = {srs84[83:1], a1};
            srs111  = {srs111[110:1], a2};
        end
    end

endmodule
