module trivium(output s, input [80:1] IV, KEY, input rst, clk);

    // declare main shift registers
    reg [93:1]  srs93;
    reg [84:1]  srs84;
    reg [111:1] srs111;

    integer i;
    wire t1, t2, t3;

    assign t1 = srs93[66] ^ srs93[93];
    assign t2 = srs84[69] ^ srs84[84];
    assign t3 = srs111[66] ^ srs111[111];

    assign s = t1 ^ t2 ^ t3;

    always @(posedge rst or posedge clk) begin
        if (rst) begin
            $display("Initialization.");
            srs93   = {13'b0, KEY};
            srs84   = {4'b0, IV};
            srs111  = {3'b111, 108'b0 };

            for(i = 0; i < 4*288; i = i + 1) begin
                srs93   = {srs93[92:1], (srs111[66] ^ srs111[111] ^ (srs111[109] & srs111[110]) ^ srs93[69])};
                srs84   = {srs84[83:1], (srs93[66] ^ srs93[93] ^ (srs93[91] & srs93[92]) ^ srs84[78])};
                srs111  = {srs111[110:1], (srs84[69] ^ srs84[84] ^ (srs84[82] & srs84[83]) ^ srs111[87])};
            end
            $display("Initialization finished.");
        end
        else begin
            srs93   = {srs93[92:1], (srs111[66] ^ srs111[111] ^ (srs111[109] & srs111[110]) ^ srs93[69])};
            srs84   = {srs84[83:1], (srs93[66] ^ srs93[93] ^ (srs93[91] & srs93[92]) ^ srs84[78])};
            srs111  = {srs111[110:1], (srs84[69] ^ srs84[84] ^ (srs84[82] & srs84[83]) ^ srs111[87])};
        end
    end

endmodule
