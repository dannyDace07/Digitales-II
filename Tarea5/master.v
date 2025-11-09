// master.v

module spi_master_simple (
    input wire       CLK,       
    input wire       RESET,     
    
    // Controles de modo SPI
    input wire       CKP,       
    input wire       CPH,       
    
    // Interfaz de datos (Bus Paralelo de 16 bits)
    input wire [15:0] MISO,      
    output reg [15:0] MOSI,      
    
    // Salidas de control
    output reg       CS,        
    output reg       SCK,       // Reloj (solo para simular actividad)

    input wire [15:0] data_to_send,    
    input wire        start_tx,        
    output reg [15:0] data_received,   
    output reg        tx_busy          
);

    reg [1:0]  state;
    localparam IDLE = 0;
    localparam TRANSFER = 1;
    localparam STOP_TX = 2;

    // Lógica del Reloj SCK (para simulación visual)
    always @(posedge CLK or negedge RESET) begin
        if (!RESET) begin
            SCK <= CKP;
        end else begin
            // Simula una señal activa durante la transferencia
            SCK <= (state == TRANSFER) ? ~SCK : CKP; 
        end
    end
    
    // Lógica de la FSM (Controla la transacción paralela)
    always @(posedge CLK or negedge RESET) begin
        if (!RESET) begin
            state <= IDLE; CS <= 1'b1; tx_busy <= 1'b0; MOSI <= 16'h0000; data_received <= 16'h0000;
        end else begin
            
            case (state)
                IDLE: begin
                    tx_busy <= 1'b0;
                    if (start_tx) begin
                        state <= TRANSFER;
                        tx_busy <= 1'b1;
                        CS <= 1'b0; // Activar Chip Select
                        
                        // Si CPH=0, el dato se envía inmediatamente (Transferencia "temprana")
                        if (CPH == 0) begin
                            MOSI <= data_to_send;
                        end
                    end
                end
                
                TRANSFER: begin
                    // Si CPH=1, el dato se envía en el ciclo de transferencia (Transferencia "tardía")
                    if (CPH == 1) begin
                        MOSI <= data_to_send;
                    end
                    
                    // La recepción (MISO) siempre ocurre un ciclo después de que MOSI fue activado.
                    // Esto modela que el Slave ya puso su dato en el bus.
                    data_received <= MISO;
                    state <= STOP_TX;
                end

                STOP_TX: begin
                    CS <= 1'b1;
                    tx_busy <= 1'b0;
                    MOSI <= 16'h0000;
                    state <= IDLE;
                end
                
            endcase
        end
    end

endmodule