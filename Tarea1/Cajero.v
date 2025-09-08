module Cajero (
    input CLK,
    input RESET,
    input TARJETA_RECIBIDA,
    input [15:0] PIN_CORRECTO, 
    input [3:0] DIGITO,
    input DIGITO_STB,
    input TIPO_TRANS,
    input [31:0] MONTO,
    input MONTO_STB,
    input [63:0] BALANCE_INICIAL,

    output reg [63:0] BALANCE_ACTUALIZADO,
    output reg BALANCE_STB,
    output reg ENTREGAR_DINERO,
    output reg FONDOS_INSUFICIENTES,
    output reg PIN_INCORRECTO,
    output reg ADVERTENCIA,
    output reg BLOQUEO
    );

    reg [1:0] intentos_fallidos;
    reg [15:0] PIN_ACTUAL;
    reg [2:0] estado;
    reg [1:0] cantidad_digitos;
    reg casi_bloqueado;


    localparam ESPERANDO_TARJETA      = 3'b000, // Esperando Tarjeta
               INGRESANDO_PIN         = 3'b001, // EL usuario esta ingresando el PIN 
               ANALIZANDO_PIN         = 3'b010, // Se verifica si el PIN es correcto
               DETERMINAR_TRANSACCION = 3'b011, // El usuario elige entre retiro o depósito
               PROCESANDO_DEPOSITO    = 3'b100, // Se procesa depósito
               PROCESANDO_RETIRO      = 3'b101, // Se procesa retiro
               FIN                    = 3'b110, // Finaliza transacción
               BLOQUEADO              = 3'b111; // Tarjeta bloqueda por intentos fallidos

    always @(posedge CLK) begin
        if (!RESET) begin // si reset = 0 se inicializan todas las variables
            estado                  <= ESPERANDO_TARJETA;
	        cantidad_digitos        <= 0;
	        PIN_ACTUAL              <= 0;
	        intentos_fallidos       <= 0;
            PIN_INCORRECTO          <= 0;
            ADVERTENCIA             <= 0;
            BLOQUEO                 <= 0;
            BALANCE_STB             <= 0;
            FONDOS_INSUFICIENTES    <= 0;
            ENTREGAR_DINERO         <= 0;

         
        end else begin // si reset = 1
            case (estado)
                // El sistema está esperando la tarjeta
		        ESPERANDO_TARJETA: begin
    		    // Si la señal TARJETA_RECIBIDA está activa
    		    // Cambiar al estado de INGRESANDO_PIN
    		        if (TARJETA_RECIBIDA) begin
        		        estado <= INGRESANDO_PIN;
    		        end else begin
                    // Si no hay tarjeta, permanecer en ESPERANDO_TARJETA
        		        estado <= ESPERANDO_TARJETA;
    	            end
		        end

                INGRESANDO_PIN: begin
                    // si hay un intento fallido se pone en alto PIN_INCORRECTO
                    if (intentos_fallidos == 2'd1) begin
                        PIN_INCORRECTO <= 1;
                    end else if (intentos_fallidos == 2'd2) begin
                    // si hay dos intentos fallidos se pone en alto ADVERTENCIA
                        ADVERTENCIA <= 1;
                        PIN_INCORRECTO <= 0;
                    // si hay 3 intentos fallidos se bloquea
                    end else if (intentos_fallidos == 2'd3) begin
                    	// se pasa ADVERTENCIA a 0, BLOQUEO a 1 y se cambia de estado a BLOQUEADO
                        ADVERTENCIA <= 0;
                        BLOQUEO <= 1;
                        estado <= BLOQUEADO;
                    end else begin
                    	// si no sucede, se mantiene ADVERTENCIA en cero
                        ADVERTENCIA <= 0;
                    end
                    
                    // Si DIGITO_STB = 1 e intentos fallidos es menor a 3
                    if (DIGITO_STB && (intentos_fallidos < 3)) begin
                        // cantidad_digitos funciona como un contador que indica cuántos dígitos del PIN ya se han ingresado.
                        case (cantidad_digitos) 
                            // Si cantidad_digitos es 2'b00 (o sea, 0 en decimal), ejecuta lo que está en el bloque
                            2'b00: begin
                                PIN_ACTUAL[15:12] <= DIGITO;
                                // Se actualiza cantidad_digitos
                                cantidad_digitos <= cantidad_digitos + 1;
                            end
                            2'b01: begin
                                PIN_ACTUAL[11:8] <= DIGITO;
                                cantidad_digitos <= cantidad_digitos + 1;
                            end
                            2'b10: begin
                                PIN_ACTUAL[7:4] <= DIGITO;
                                cantidad_digitos <= cantidad_digitos + 1;
                            end
                            2'b11: begin
                                PIN_ACTUAL[3:0] <= DIGITO;
                                cantidad_digitos <= 0;
                                estado <= ANALIZANDO_PIN;
                            end
                        endcase
                    end else if (intentos_fallidos < 3) begin
                        estado <= INGRESANDO_PIN;
                    end
                end

                ANALIZANDO_PIN: begin
                    // Si el pin es incorrecto entonces se activa PIN_INCORRECTO
                    if (PIN_ACTUAL != PIN_CORRECTO) begin
                    	// Se suma un intento a intentos_fallidos
                        intentos_fallidos <= intentos_fallidos + 1;
                        PIN_INCORRECTO <= 1;
                        // Se devuelve al estado de INGRESANDO_PIN
                        estado <= INGRESANDO_PIN;
                        if (intentos_fallidos < 3) begin
                            estado <= INGRESANDO_PIN;
                        end else begin
                            estado <= BLOQUEADO;
                        end
                    end else begin
                        estado <= DETERMINAR_TRANSACCION;
                    end
                end

                DETERMINAR_TRANSACCION: begin
                    // Si TIPO_TRANS es 0 se pasa al estado de PROCESANDO_DEPOSITO
                    if (TIPO_TRANS == 0) begin
                       estado <= PROCESANDO_DEPOSITO;
                    end else if (TIPO_TRANS == 1) begin
                    // Si TIPO_TRANS es 1 se pasa al estado de PROCESANDO_RETIRO
                       estado <= PROCESANDO_RETIRO;
                    end else begin
                    	// Si TIPO_TRANS es distinto de 0 o 1 se devuelve a ESPERANDO_TARJETA	
                       estado <= ESPERANDO_TARJETA;
                    end
                end

                PROCESANDO_DEPOSITO: begin
                    if (MONTO_STB) begin
                        BALANCE_ACTUALIZADO <= BALANCE_INICIAL + MONTO;
                        BALANCE_STB <= 1;
                        estado <= FIN;
                    end else begin
                        estado <= PROCESANDO_DEPOSITO;
                    end
                end

                PROCESANDO_RETIRO: begin
                    if (MONTO_STB) begin
                        // Se verifica si MONTO es mayor a BALANCE_ACTUALIZADO
                        if (MONTO > BALANCE_ACTUALIZADO) begin
                            FONDOS_INSUFICIENTES <= 1;
                            BALANCE_STB <= 1;
                            estado <= FIN;
                        end else begin
                            BALANCE_ACTUALIZADO  <= BALANCE_ACTUALIZADO - MONTO;
                            BALANCE_STB <= 1;
                            ENTREGAR_DINERO <= 1;
                            estado <= FIN;
                        end
                    end else begin
                        estado <= PROCESANDO_RETIRO;
                    end
                end

                FIN: begin
                    if (BALANCE_STB) begin
                        cantidad_digitos        <= 0;
                        intentos_fallidos       <= 0;
                        PIN_ACTUAL              <= 0;
                        estado                  <= ESPERANDO_TARJETA;
                        ADVERTENCIA             <= 0;
                        BLOQUEO                 <= 0;
                        BALANCE_STB             <= 0;
                        ENTREGAR_DINERO         <= 0;
                        PIN_INCORRECTO          <= 0;
                        FONDOS_INSUFICIENTES    <= 0;
                    
                    end else begin
                        estado <= FIN;
                    end
                end
                    
                // Mantiene el sistema bloqueado hasta obtener RESET = 0 y RESET = 1
                BLOQUEADO: begin
                    if (!RESET) begin
                        estado <= ESPERANDO_TARJETA;
                    end else begin
                    	estado <= BLOQUEADO;
                    end 
                end
            endcase
        end
    end

endmodule