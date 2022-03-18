module trivium_tb;

    wire s;
    reg [80:1] key, iv;
    reg rst, clk;

    integer t;

    trivium triv(s, iv, key, rst, clk);

    initial begin
        $dumpfile("test.vcd");
	$dumpvars(0, s);
        key = 80'b0;
        iv = 80'b0;
        rst = 1;
        clk = 0;
        #2 rst = 0;
    end

    always
        #2 clk = ~clk;

    initial begin
        for (t = 1; t <= 32; t = t + 1)
            #2 $display("%d:%d", t, s);
    end
endmodule
