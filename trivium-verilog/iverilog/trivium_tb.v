module trivium_tb;

    wire s;
    reg [80:1] key, iv;
    reg rst, clk;

    integer t;

    trivium triv(s, iv, key, rst, clk);

    initial begin
        $dumpfile("test.vcd");
	$dumpvars(0, s);
	$dumpvars(0, clk);
	$dumpvars(0, rst);
        key = 80'b0;
        iv = 80'b0;
        rst = 1;
        clk = 0;
        #1 rst = 0;
    end

    always begin
        #1 clk = ~clk;
    end

    initial begin
        for (t = 1; t <= 32; t = t + 1)
            #1 $display("%d:%d", t, s);
    end
endmodule
