/* ================================================================
 * Módulo: synchronizer_tester — Versión con pruebas independientes
 * ================================================================
 */

`include "pcs_cg_defs.vh"
`include "pcs_defs.vh"

module synchronizer_tester(
    output reg clk,
    output reg reset,
    output reg [9:0] rx_code_group_in,
    input [9:0] rx_code_group_out,
    input rx_even_out,
    input code_sync_status
);

    // ====================================================
    // Configuración: activar/desactivar pruebas aquí
    // ====================================================
    reg enable_test1 = 1;
    reg enable_test2 = 0;
    reg enable_test3 = 0;
    reg enable_test4 = 0;
    reg enable_test5 = 0;
    reg enable_test6 = 0;
    reg enable_test7 = 0;
    reg enable_test8 = 0;
    reg enable_test9 = 0;

    // Variables
    reg [9:0] test_vectors [0:31];
    reg [80:1] cg_names [0:31];
    integer num_vectors;
    integer errors;
    integer test_count;
    integer i, j;
    reg found;

    initial begin
        $display("========================================");
        $display("  TESTBENCH VECTORIZADO - Sincronizador PCS");
        $display("========================================\n");

        clk = 0;
        reset = 1;
        rx_code_group_in = 10'b0000000000;
        errors = 0;
        test_count = 0;

        load_test_vectors();

        // Reset
        $display("[T=%0t] Aplicando reset...", $time);
        #10 reset = 0;
        #20 reset = 1;
        #10;

        // ======================
        if (enable_test1) begin
        $display("\n========================================");
        $display("TEST 1: Sincronización inicial");
        $display("========================================");
        send_sequence("K28.5-", "D16.2-");
        send_sequence("K28.5-", "D16.2+");
        send_sequence("K28.5-", "D5.6+");
        check_sync(1, "después de 3 commas");
        end

        // ======================
        if (enable_test2) begin
        $display("\n========================================");
        $display("TEST 2: Mantenimiento con IDLE");
        $display("========================================");
        repeat(5) begin
            send_sequence("K28.5+", "D16.2-");
        end
        check_sync(1, "tras IDLEs");
        end

        // ======================
        if (enable_test3) begin
        $display("\n========================================");
        $display("TEST 3: Todos los code-groups D0.0-D9.0");
        $display("========================================");
        for (i = 0; i < 10; i = i + 1)
            send_cg_by_name(cg_names[i]);
        check_sync(1, "tras D0-D9 RD-");
        for (i = 10; i < 20; i = i + 1)
            send_cg_by_name(cg_names[i]);
        check_sync(1, "tras D0-D9 RD+");
        end

        // ======================
        if (enable_test4) begin
        $display("\n========================================");
        $display("TEST 4: Code-groups especiales");
        $display("========================================");
        send_cg_by_name("D5.6-");
        send_cg_by_name("D5.6+");
        send_cg_by_name("D16.2-");
        send_cg_by_name("D16.2+");
        check_sync(1, "tras D5.6 y D16.2");
        end

        // ======================
        if (enable_test5) begin
        $display("\n========================================");
        $display("TEST 5: Un error + recuperación");
        $display("========================================");
        send_invalid("Error 1");
        check_sync(1, "tras 1 error");
        send_cg_by_name("D0.0+");
        send_cg_by_name("D1.0-");
        send_cg_by_name("D2.0+");
        send_cg_by_name("D3.0-");
        check_sync(1, "tras recuperación");
        end

        // ======================
        if (enable_test6) begin
        $display("\n========================================");
        $display("TEST 6: Comma en posición IMPAR");
        $display("========================================");
        send_cg_by_name("D16.2+");
        send_cg_by_name("K28.5+");
        send_cg_by_name("D4.0-");
        send_cg_by_name("D5.0+");
        send_cg_by_name("D6.0-");
        send_cg_by_name("D7.0+");
        end

        // ======================
        if (enable_test7) begin
        $display("\n========================================");
        $display("TEST 7: Pérdida de sincronización");
        $display("========================================");
        send_invalid("Error 1");
        send_invalid("Error 2");
        send_invalid("Error 3");
        send_invalid("Error 4");
        check_sync(0, "tras 4 errores");
        end

        // ======================
        if (enable_test8) begin
        $display("\n========================================");
        $display("TEST 8: Re-sincronización");
        $display("========================================");
        send_cg_by_name("D9.0-");
        send_cg_by_name("D8.0+");
        send_sequence("K28.5+", "D5.6+");
        send_sequence("K28.5+", "D16.2-");
        send_sequence("K28.5+", "D16.2+");
        check_sync(1, "tras re-sincronización");
        end

        // ======================
        if (enable_test9) begin
        $display("\n========================================");
        $display("TEST 9: Alternancia de RD");
        $display("========================================");
        send_sequence("K28.5-", "D16.2+");
        send_sequence("K28.5+", "D5.6-");
        send_sequence("K28.5-", "D16.2+");
        send_sequence("K28.5+", "D5.6-");
        end

        #40;
        $display("\n========================================");
        $display("  RESUMEN DE PRUEBAS");
        $display("========================================");
        $display("  Tests ejecutados: %0d", test_count);
        $display("  Errores encontrados: %0d", errors);
        if (errors == 0)
            $display("  ✓ TODAS LAS PRUEBAS PASARON");
        else
            $display("  ✗ ALGUNAS PRUEBAS FALLARON");
        $display("========================================\n");

        $finish;
    end

    // ====================================================
    // LOAD VECTORS
    // ====================================================
    task load_test_vectors;
        begin
            $display("Cargando vectores de prueba...");
            
            test_vectors[0] = 10'b1001110100; cg_names[0] = "D0.0-";
            test_vectors[1] = 10'b0111010100; cg_names[1] = "D1.0-";
            test_vectors[2] = 10'b1011010100; cg_names[2] = "D2.0-";
            test_vectors[3] = 10'b1100011011; cg_names[3] = "D3.0-";
            test_vectors[4] = 10'b1101010100; cg_names[4] = "D4.0-";
            test_vectors[5] = 10'b1010011011; cg_names[5] = "D5.0-";
            test_vectors[6] = 10'b0110011011; cg_names[6] = "D6.0-";
            test_vectors[7] = 10'b1110001011; cg_names[7] = "D7.0-";
            test_vectors[8] = 10'b1110010100; cg_names[8] = "D8.0-";
            test_vectors[9] = 10'b1001011011; cg_names[9] = "D9.0-";

            test_vectors[10] = 10'b0110001011; cg_names[10] = "D0.0+";
            test_vectors[11] = 10'b1000101011; cg_names[11] = "D1.0+";
            test_vectors[12] = 10'b0100101011; cg_names[12] = "D2.0+";
            test_vectors[13] = 10'b1100010100; cg_names[13] = "D3.0+";
            test_vectors[14] = 10'b0010101011; cg_names[14] = "D4.0+";
            test_vectors[15] = 10'b1010010100; cg_names[15] = "D5.0+";
            test_vectors[16] = 10'b0110010100; cg_names[16] = "D6.0+";
            test_vectors[17] = 10'b0001110100; cg_names[17] = "D7.0+";
            test_vectors[18] = 10'b0001101011; cg_names[18] = "D8.0+";
            test_vectors[19] = 10'b1001010100; cg_names[19] = "D9.0+";

            test_vectors[20] = 10'b0110110101; cg_names[20] = "D16.2-";
            test_vectors[21] = 10'b1010010110; cg_names[21] = "D5.6-";
            test_vectors[22] = 10'b1001000101; cg_names[22] = "D16.2+";
            test_vectors[23] = 10'b1010010110; cg_names[23] = "D5.6+";

            test_vectors[24] = 10'b0011111010; cg_names[24] = "K28.5-";
            test_vectors[25] = 10'b1100000101; cg_names[25] = "K28.5+";
            
            num_vectors = 26;
            $display("  ✓ %0d vectores cargados\n", num_vectors);
        end
    endtask

    // ====================================================
    // SEND TASKS
    // ====================================================
    task send_cg_by_name(input [80:1] name);
        begin
            found = 0;
            for (j = 0; j < num_vectors; j = j + 1) begin
                if (cg_names[j] == name) begin
                    send_cg(test_vectors[j], name);
                    found = 1;
                    j = num_vectors;
                end
            end
            if (!found) begin
                $display("  ✗ ERROR: Code-group '%0s' no encontrado", name);
                errors = errors + 1;
            end
        end
    endtask

    task send_sequence(input [80:1] name1, input [80:1] name2);
        begin
            send_cg_by_name(name1);
            send_cg_by_name(name2);
        end
    endtask

    task send_cg(input [9:0] cg, input [80:1] description);
        begin
            @(posedge clk);
            rx_code_group_in = cg;
            test_count = test_count + 1;
            #1;
            $display("  [%0d] TX: %-10s (0x%h) | rx_even=%b | sync=%b",
                    test_count, description, cg, rx_even_out, code_sync_status);
        end
    endtask

    task send_invalid(input [80:1] label);
        begin
            @(posedge clk);
            rx_code_group_in = 10'b0000000000;
            test_count = test_count + 1;
            #1;
            $display("  [%0d] TX: INVALID     | %s", test_count, label);
        end
    endtask

    // ====================================================
    // CHECK
    // ====================================================
    task check_sync(input expected, input [200*8:1] label);
        begin
            #1;
            if (code_sync_status == expected)
                $display("  ✓ PASS: sync_status=%b %s", code_sync_status, label);
            else begin
                $display("  ✗ FAIL: sync_status=%b (esperado %b) %s",
                         code_sync_status, expected, label);
                errors = errors + 1;
            end
        end
    endtask

    // Reloj
    always #4 clk = ~clk;

endmodule
