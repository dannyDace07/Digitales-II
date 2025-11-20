/* ================================================================
 * Módulo: synchronizer_tb
 * Descripción:
 *   Testbench simple que instancia el Synchronizer y el tester.
 *   Genera archivo VCD para visualización en GTKWave.
 * ================================================================
 */
 
module synchronizer_tb;

    wire reset, clk;
    wire rx_even_out;
    wire code_sync_status;
    wire [9:0] rx_code_group_in, rx_code_group_out;

    initial begin
        $dumpfile("synchronizer_waveform.vcd");
        $dumpvars(0, synchronizer_tb);
        $dumpvars(0, dut);
    end

    Synchronizer dut(
        .rx_clk(clk),
        .reset(reset),
        .rx_code_group(rx_code_group_in),
        .SUDI({rx_even_out, rx_code_group_out}),
        .sync_status(code_sync_status)
    );

    synchronizer_tester dut_p (
        .reset(reset),
        .clk(clk),
        .rx_code_group_in(rx_code_group_in),
        .rx_code_group_out(rx_code_group_out),
        .rx_even_out(rx_even_out),
        .code_sync_status(code_sync_status)
    );

endmodule