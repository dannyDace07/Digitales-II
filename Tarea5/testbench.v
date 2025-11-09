// testbench.v
`timescale 1ns/1ps

module testbench;

    // --- Señales de Interfaz (16 bits) ---
    reg        CLK; reg        RESET; reg        CKP; reg        CPH;
    wire [15:0] MISO_to_master; 
    wire [15:0] MOSI_from_master; 
    wire       CS_from_master; wire       SCK_from_master;
    reg [15:0] master_data_out; wire [15:0] master_data_in;
    reg        master_start_tx; wire       master_busy;

    // --- Conexiones Daisy Chain ---
    wire [15:0] miso_from_slave1; 
    wire [15:0] data_in_slave1; 
    wire [15:0] data_in_slave2; 
    
    // --- Datos de Configuración (Carné C33566) ---
    localparam MASTER_TX_DATA = 16'h0305; // Master Envía (3 y 5)
    localparam SLAVE_PRELOAD_DATA = 16'h0606;    // Slave Envía (6 y 6)

    // --- Instanciación de Módulos ---
    
    spi_master_simple DUT_Master (
        .CLK(CLK), .RESET(RESET), .CKP(CKP), .CPH(CPH), .MISO(MISO_to_master), .MOSI(MOSI_from_master),
        .CS(CS_from_master), .SCK(SCK_from_master), .data_to_send(master_data_out), .start_tx(master_start_tx),
        .data_received(master_data_in), .tx_busy(master_busy)
    );

    // Slave 1: Recibe 0305, Envía 0606
    spi_slave_simple DUT_Slave1 (
        .SCK(SCK_from_master), .SS(CS_from_master), .MOSI(MOSI_from_master), .MISO(miso_from_slave1), 
        .CKP(CKP), .CPH(CPH), .preload_data(SLAVE_PRELOAD_DATA), .data_in_slave(data_in_slave1)
    );

    // Slave 2: Recibe 0606, Envía 0606
    spi_slave_simple DUT_Slave2 (
        .SCK(SCK_from_master), .SS(CS_from_master), .MOSI(miso_from_slave1), .MISO(MISO_to_master), 
        .CKP(CKP), .CPH(CPH), .preload_data(SLAVE_PRELOAD_DATA), .data_in_slave(data_in_slave2)
    );

    // --- Generador de Reloj (CLK) ---
    initial CLK = 0;
    always #5 CLK = ~CLK; 

    // --- Tarea de Transacción y Verificación Sencilla ---
    task run_mode_test;
        input [1:0] mode;
        begin
            $display("\n--- PRUEBA MODO %d (CKP=%b, CPH=%b) ---", mode, CKP, CPH);
            
            // Transacción: Master inicia el envío de 0305.
            @(negedge CLK);
            master_data_out = MASTER_TX_DATA; // <- Envía el número completo 0305
            master_start_tx = 1;
            @(negedge CLK);
            master_start_tx = 0;
            
            // Espera a que termine la transferencia conceptual
            wait (master_busy == 1);
            wait (master_busy == 0);
            
            #10; 

            // Verificación de Resultados
            $display("  Master TX (0305) | S1 RX: %h (Esperado 0305)", data_in_slave1);
            $display("  S1 TX (0606) | S2 RX: %h (Esperado 0606)", data_in_slave2);
            $display("  S2 TX (0606) | Master RX: %h (Esperado 0606)", master_data_in);
            
            if (master_data_in == SLAVE_PRELOAD_DATA && 
                data_in_slave1 == MASTER_TX_DATA &&
                data_in_slave2 == SLAVE_PRELOAD_DATA) begin
                $display("  --> MODO %d OK: Flujo 0305/0606 completado <--", mode);
            end else begin
                $display("  --> !!! MODO %d FALLIDO !!! <--");
            end
        end
    endtask


    // --- Secuencia de Pruebas Principal ---
    initial begin
        $dumpfile("spi_chain.vcd");
        $dumpvars(0, testbench);

        // Reset inicial
        RESET = 0; #5; RESET = 1; #10;
        
        // Probar los 4 modos con la misma secuencia de datos
        CKP = 0; CPH = 0; run_mode_test(0);
        CKP = 0; CPH = 1; run_mode_test(1);
        CKP = 1; CPH = 0; run_mode_test(2);
        CKP = 1; CPH = 1; run_mode_test(3);
        
        $display("\nSimulación conceptual completada.");
        $finish;
    end

endmodule