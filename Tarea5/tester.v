// tester.v - Controlador de pruebas SPI
// Carné: C33566
// INSTRUCCIONES: Descomenta el modo que quieres probar (solo uno a la vez)

`timescale 1ns/1ps

module tester (
    output wire CLK,
    output reg RESET,
    output reg CKP,
    output reg CPH,
    output reg [7:0] master_tx_data,
    output reg master_tx_start,
    input wire master_cs,
    input wire master_sck,
    input wire master_mosi,
    input wire master_miso,
    input wire master_tx_busy,
    input wire [7:0] master_rx_data,
    input wire master_rx_ready,
    output reg [7:0] slave1_tx_data,
    input wire slave1_miso,
    input wire [7:0] slave1_rx_data,
    input wire slave1_rx_ready,
    output reg [7:0] slave2_tx_data,
    input wire slave2_miso,
    input wire [7:0] slave2_rx_data,
    input wire slave2_rx_ready
);

    // ========================================
    // SELECCIÓN DE MODO
    // Descomenta SOLO UNO de los siguientes:
    // ========================================
    
    `define TEST_MODE_0   // Modo 0: CKP=0, CPH=0
    //`define TEST_MODE_1   // Modo 1: CKP=0, CPH=1
    //`define TEST_MODE_2   // Modo 2: CKP=1, CPH=0
    //`define TEST_MODE_3   // Modo 3: CKP=1, CPH=1
    
    // ========================================
    

    initial begin
        forever #5 CLK = ~CLK;  // Periodo = 10ns
    end


    // Configuración automática del modo
    initial begin
        `ifdef TEST_MODE_0
            CKP = 0; CPH = 0;
        `elsif TEST_MODE_1
            CKP = 0; CPH = 1;
        `elsif TEST_MODE_2
            CKP = 1; CPH = 0;
        `elsif TEST_MODE_3
            CKP = 1; CPH = 1;
        `else
            $display("ERROR: Debes definir un TEST_MODE!");
            $finish;
        `endif
    end
    
    // Acceso a señales internas
    wire [7:0] master_byte1 = testbench.u_master.rx_data_byte1;
    wire [7:0] master_byte2 = testbench.u_master.rx_data_byte2;
    wire [7:0] slave1_byte1 = testbench.u_slave1.rx_data_byte1;
    wire [7:0] slave1_byte2 = testbench.u_slave1.rx_data_byte2;
    wire [7:0] slave2_byte1 = testbench.u_slave2.rx_data_byte1;
    wire [7:0] slave2_byte2 = testbench.u_slave2.rx_data_byte2;
    wire [3:0] master_bits = testbench.u_master.bit_count;
    wire [3:0] slave1_bits = testbench.u_slave1.bit_count;
    wire [3:0] slave2_bits = testbench.u_slave2.bit_count;
    
    // Monitor de flancos SCK (muestra actividad bit a bit)
    always @(posedge master_sck or negedge master_sck) begin
        if (master_cs == 1'b0) begin
            if ((CKP == 0 && master_sck == 1) || (CKP == 1 && master_sck == 0)) begin
                $display("    [Edge1] MOSI=%b S1_MISO=%b S2_MISO=%b | bits: M=%0d S1=%0d S2=%0d", 
                         master_mosi, slave1_miso, slave2_miso, master_bits, slave1_bits, slave2_bits);
            end else begin
                $display("    [Edge2] MOSI=%b S1_MISO=%b S2_MISO=%b | bits: M=%0d S1=%0d S2=%0d", 
                         master_mosi, slave1_miso, slave2_miso, master_bits, slave1_bits, slave2_bits);
            end
        end
    end
    
    // Proceso de pruebas
    initial begin
        // Configurar VCD
        $dumpfile("spi_test.vcd");
        $dumpvars(0, testbench);
        
        // Encabezado
        $display("\n╔════════════════════════════════════════════════╗");
        $display("║   SPI Daisy Chain Test - Carné C33566         ║");
        `ifdef TEST_MODE_0
            $display("║   MODO 0: CKP=0, CPH=0                         ║");
            $display("║   Idle: SCK=0 | Captura: Rising | Cambio: Falling ║");
        `elsif TEST_MODE_1
            $display("║   MODO 1: CKP=0, CPH=1                         ║");
            $display("║   Idle: SCK=0 | Cambio: Rising | Captura: Falling ║");
        `elsif TEST_MODE_2
            $display("║   MODO 2: CKP=1, CPH=0                         ║");
            $display("║   Idle: SCK=1 | Captura: Falling | Cambio: Rising ║");
        `elsif TEST_MODE_3
            $display("║   MODO 3: CKP=1, CPH=1                         ║");
            $display("║   Idle: SCK=1 | Cambio: Falling | Captura: Rising ║");
        `endif
        $display("║   Master TX: 3, 5 | Slaves TX: 6, 6           ║");
        $display("╚════════════════════════════════════════════════╝\n");
        
        // Inicialización
        RESET = 0;
        master_tx_start = 0;
        master_tx_data = 8'h00;
        slave1_tx_data = 8'h06;  // Slave1 siempre envía 6
        slave2_tx_data = 8'h06;  // Slave2 siempre envía 6
        
        #100;
        RESET = 1;
        #100;
        
        // ============================================
        // TRANSACCIÓN 1: Master envía 3
        // ============================================
        $display("┌────────────────────────────────────────────────┐");
        $display("│ TRANSACCIÓN 1: Byte 1                          │");
        $display("└────────────────────────────────────────────────┘");
        $display("  Master MOSI → 0x03 (00000011)");
        $display("  Slave1 MISO → 0x06 (00000110)");
        $display("  Slave2 MISO → 0x06 (00000110)");
        $display("");
        
        master_tx_data = 8'h03;
        master_tx_start = 1;
        #20;
        master_tx_start = 0;
        
        wait(master_rx_ready);
        #200;
        
        $display("");
        $display("  Resultados:");
        $display("    Master RX: 0x%02h (esperado: 0x06) %s", master_rx_data, 
                 (master_rx_data == 8'h06) ? "✓" : "✗");
        $display("    Slave1 RX: 0x%02h (esperado: 0x03) %s", slave1_rx_data,
                 (slave1_rx_data == 8'h03) ? "✓" : "✗");
        $display("    Slave2 RX: 0x%02h (esperado: 0x06) %s", slave2_rx_data,
                 (slave2_rx_data == 8'h06) ? "✓" : "✗");
        $display("");
        $display("  Registros internos:");
        $display("    Master: [0x%02h, 0x%02h]", master_byte1, master_byte2);
        $display("    Slave1: [0x%02h, 0x%02h] (esperado: [03, 00])", slave1_byte1, slave1_byte2);
        $display("    Slave2: [0x%02h, 0x%02h] (esperado: [06, 00])", slave2_byte1, slave2_byte2);
        
        if (master_rx_data == 8'h06 && slave1_rx_data == 8'h03 && slave2_rx_data == 8'h06)
            $display("\n  ✓✓✓ Transacción 1 EXITOSA ✓✓✓\n");
        else
            $display("\n  ✗✗✗ Transacción 1 FALLÓ ✗✗✗\n");
        
        #1000;
        
        // ============================================
        // TRANSACCIÓN 2: Master envía 5
        // ============================================
        $display("┌────────────────────────────────────────────────┐");
        $display("│ TRANSACCIÓN 2: Byte 2                          │");
        $display("└────────────────────────────────────────────────┘");
        $display("  Master MOSI → 0x05 (00000101)");
        $display("  Slave1 MISO → 0x06 (00000110)");
        $display("  Slave2 MISO → 0x06 (00000110)");
        $display("");
        
        master_tx_data = 8'h05;
        master_tx_start = 1;
        #20;
        master_tx_start = 0;
        
        wait(master_rx_ready);
        #200;
        
        $display("");
        $display("  Resultados:");
        $display("    Master RX: 0x%02h (esperado: 0x06) %s", master_rx_data,
                 (master_rx_data == 8'h06) ? "✓" : "✗");
        $display("    Slave1 RX: 0x%02h (esperado: 0x05) %s", slave1_rx_data,
                 (slave1_rx_data == 8'h05) ? "✓" : "✗");
        $display("    Slave2 RX: 0x%02h (esperado: 0x06) %s", slave2_rx_data,
                 (slave2_rx_data == 8'h06) ? "✓" : "✗");
        $display("");
        $display("  Registros internos FINALES:");
        $display("    Master: [0x%02h, 0x%02h] (esperado: [06, 06])", master_byte1, master_byte2);
        $display("    Slave1: [0x%02h, 0x%02h] (esperado: [03, 05])", slave1_byte1, slave1_byte2);
        $display("    Slave2: [0x%02h, 0x%02h] (esperado: [06, 06])", slave2_byte1, slave2_byte2);
        
        if (master_rx_data == 8'h06 && slave1_rx_data == 8'h05 && slave2_rx_data == 8'h06)
            $display("\n  ✓✓✓ Transacción 2 EXITOSA ✓✓✓\n");
        else
            $display("\n  ✗✗✗ Transacción 2 FALLÓ ✗✗✗\n");
        
        #500;
        
        // ============================================
        // VERIFICACIÓN COMPLETA
        // ============================================
        $display("┌────────────────────────────────────────────────┐");
        $display("│ VERIFICACIÓN FINAL                             │");
        $display("└────────────────────────────────────────────────┘");
        
        if (master_byte1 == 8'h06 && master_byte2 == 8'h06)
            $display("  ✓ Master: [06, 06] CORRECTO");
        else
            $display("  ✗ Master: [%02h, %02h] INCORRECTO", master_byte1, master_byte2);
            
        if (slave1_byte1 == 8'h03 && slave1_byte2 == 8'h05)
            $display("  ✓ Slave1: [03, 05] CORRECTO");
        else
            $display("  ✗ Slave1: [%02h, %02h] INCORRECTO", slave1_byte1, slave1_byte2);
            
        if (slave2_byte1 == 8'h06 && slave2_byte2 == 8'h06)
            $display("  ✓ Slave2: [06, 06] CORRECTO");
        else
            $display("  ✗ Slave2: [%02h, %02h] INCORRECTO", slave2_byte1, slave2_byte2);
        
        #500;
        
        // ============================================
        // PRUEBA DE RESET
        // ============================================
        $display("\n┌────────────────────────────────────────────────┐");
        $display("│ PRUEBA DE RESET                                │");
        $display("└────────────────────────────────────────────────┘");
        
        RESET = 0;
        #200;
        RESET = 1;
        #100;
        
        if (master_cs == 1 && master_tx_busy == 0)
            $display("  ✓ RESET correcto (CS=1, busy=0)\n");
        else
            $display("  ✗ RESET incorrecto\n");
        
        #500;
        
        // Resumen
        $display("╔════════════════════════════════════════════════╗");
        `ifdef TEST_MODE_0
            $display("║   MODO 0 COMPLETADO                            ║");
        `elsif TEST_MODE_1
            $display("║   MODO 1 COMPLETADO                            ║");
        `elsif TEST_MODE_2
            $display("║   MODO 2 COMPLETADO                            ║");
        `elsif TEST_MODE_3
            $display("║   MODO 3 COMPLETADO                            ║");
        `endif
        $display("║   Ver forma de onda: gtkwave spi_test.vcd      ║");
        $display("╚════════════════════════════════════════════════╝\n");
        
        $finish;
    end
    
    // Timeout
    initial begin
        #500000;
        $display("\n✗✗✗ TIMEOUT - Simulación abortada ✗✗✗\n");
        $finish;
    end

endmodule