// slave.v

module spi_slave_simple (
    input wire       SCK,       
    input wire       SS,        
    input wire [15:0] MOSI,      // Bus de entrada
    output reg [15:0] MISO,      // Bus de salida
    
    input wire       CKP,       
    input wire       CPH,       
    
    // PUERTOS PARA TESTBENCH
    input wire [15:0] preload_data, // Dato de salida (0606)
    output wire [15:0] data_in_slave // Dato de entrada (0305 o 0606)
);

    reg [15:0] rx_reg;
    reg [15:0] tx_reg;
    assign data_in_slave = rx_reg;

    // 1. Pre-carga (se inicializa con el dato de salida 0606)
    always @(preload_data) begin
        tx_reg = preload_data;
    end

    // 2. MISO: Pone el dato de salida (0606) en el bus cuando está activo
    always @(SS, tx_reg) begin
        if (!SS) begin
            MISO = tx_reg;
        end else begin
            MISO = 16'hZ; // Alta impedancia
        end
    end

    // 3. Recepción: El Slave recibe el dato (0305 o 0606) cuando está activo..
    always @(posedge SCK) begin // SCK como pulso de activación
        if (!SS) begin
            rx_reg <= MOSI;
        end
    end

endmodule