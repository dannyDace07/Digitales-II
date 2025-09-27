module tester(
    output reg CLK,
    output reg RESET,
    output reg TARJETA_RECIBIDA,
    output reg DIGITO_STB,
    output reg TIPO_TRANS,
    output reg MONTO_STB,
    output reg [15:0] PIN_CORRECTO,
    output reg [3:0] DIGITO,
    output reg [63:0] BALANCE_INICIAL,
    output reg [31:0] MONTO,
    output reg [15:0] PIN_ACTUAL,
    output reg [2:0] estado,
    output reg [1:0] cantidad_digitos
);

    initial CLK = 0;
    always #12 CLK = ~CLK;

    initial begin
        // Inicializacion de señales
        RESET = 0;
        TARJETA_RECIBIDA = 0;
        DIGITO_STB = 0;
        TIPO_TRANS = 0;
        MONTO_STB = 0;
        DIGITO = 4'd0;
        BALANCE_INICIAL = 64'd0;
        MONTO = 32'd0;
        PIN_CORRECTO = 16'b0011010101100110; // PIN 3566



//-----------------------------INICIO DE PRUEBA DE DEPOSITO EXITOSO------------------------------------------
        #24 RESET = 1;           // Se activa el sistema del cajero
        #24 TARJETA_RECIBIDA = 1; // La tarjeta es insertada
        #48 TARJETA_RECIBIDA = 0; // Finaliza la lectura de la tarjeta
        #24 DIGITO = 4'b0011;    // Primer dígito del PIN ingresado
        #24 DIGITO_STB = 1;      // Se marca que el dígito está disponible
        #24 DIGITO_STB = 0;      // Se desmarca la señal de dígito recibido
        #24 DIGITO = 4'b0101;    // Segundo dígito del PIN
        #24 DIGITO_STB = 1;      // Confirmación de entrada del segundo dígito
        #24 DIGITO_STB = 0;      // Señal de confirmación vuelve a cero
        #24 DIGITO = 4'b0110;    // Tercer dígito del PIN
        #24 DIGITO_STB = 1;      // Se valida la entrada del tercer dígito
        #24 DIGITO_STB = 0;      // La validación se apaga
        #24 DIGITO = 4'b0110;    // Cuarto dígito del PIN
        #24 DIGITO_STB = 1;      // Se confirma la llegada del cuarto dígito
        #24 DIGITO_STB = 0;      // Fin de la confirmación
        #24 TIPO_TRANS = 0;      // Selección de tipo de transacción: Depósito
        #24 MONTO = 32'd10000;   // Se introduce el monto: 10,000
        #24 MONTO_STB = 1;       // El monto queda registrado
        #24 MONTO_STB = 0;       // La señal de registro del monto se apaga
//-------------------------------FIN PRUEBA DE DEPOSITO EXITOSO-------------------------------------------



//-------------------------------INICIO DE PRUEBA DE RETIRO EXITOSO---------------------------------------        
	#24 TARJETA_RECIBIDA = 1;   // Señal de inserción de tarjeta -> activa
        #24 TARJETA_RECIBIDA = 0;  // Fin de la detección de tarjeta -> señal baja
        #24 DIGITO = 4'b0011;       // Entrada del primer dígito del PIN (valor binario 3)
        #24 DIGITO_STB = 1;         // Se confirma que el primer dígito está listo
        #24 DIGITO_STB = 0;         // Fin para el primer dígito
        #24 DIGITO = 4'b0101;       // Entrada del segundo dígito del PIN (valor binario 5)
        #24 DIGITO_STB = 1;         // Se confirma que el primer dígito está listo
        #24 DIGITO_STB = 0;         // Fin para el segundo dígito
        #24 DIGITO = 4'b0110;       // Entrada del tercer dígito del PIN (valor binario 6)
        #24 DIGITO_STB = 1;         // Se confirma que el tercer dígito está listo
        #24 DIGITO_STB = 0;         // Fin para el tercer digito
        #24 DIGITO = 4'b0110;       // Entrada del cuarto dígito del PIN (valor binario 6)
        #24 DIGITO_STB = 1;         // Se confirma que el cuarto dígito está listo
        #24 DIGITO_STB = 0;         // Fin para el cuarto digito 
        #24 TIPO_TRANS = 1;         // Selección del tipo de transacción: Retiro (1)
        #24 MONTO = 32'd7000;       // Se coloca el monto de la transacción
        #24 MONTO_STB = 1;          // Monto capturado por el sistema
        #24 MONTO_STB = 0;          // Fin de la señal de captura de monto
//--------------------------------FIN PRUEBA DE RETIRO EXITOSO------------------------------------------


//--------------------------------PRUEBA DE PIN INCORRECTO----------------------------------------------        
        #24 TARJETA_RECIBIDA = 1; // Se recibe la tarjeta
        #24 TARJETA_RECIBIDA = 0; // Se deja de recibir la tarjeta
        #24 DIGITO = 4'b0011; // Se recibe el primer digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #24 DIGITO = 4'b0101; // Se recibe el segundo digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido     
        #24 DIGITO = 4'b0110; // Se recibe el tercer digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #24 DIGITO = 4'b0001; // Se recibe el cuarto digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #24 DIGITO = 4'b0001; // Se recibe el primer digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #24 DIGITO = 4'b0001; // Se recibe el segundo digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido     
        #24 DIGITO = 4'b0001; // Se recibe el tercer digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #24 DIGITO = 4'b0001; // Se recibe el cuarto digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido  
        #24 DIGITO = 4'b0001; // Se recibe el primer digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #24 DIGITO = 4'b0101; // Se recibe el segundo digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido     
        #24 DIGITO = 4'b0011; // Se recibe el tercer digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #24 DIGITO = 4'b0100; // Se recibe el cuarto digito
        #24 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #24 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido  
//-------------------------------FIN PRUEBA PIN INCORRECTO----------------------------------------------



//------------------------------SALIR DEL ESTADO DE BLOQUEO -------------------------
        #48 RESET = 0;        // Señal de reset activa en bajo (sistema en reinicio)
        #48 RESET = 1;        // Reset desactivado, el sistema comienza la operación normal   
//----------------------FIN DE ACCION EN ESTADO DE BLOQUEO--------------------------------------------



//----------------------INICIO DE PRUEBA DE RETIRO FALLIDO--------------------------------------------
        #60  TARJETA_RECIBIDA = 1;   // Pulso en alto: se detecta la inserción de tarjeta
        #120  TARJETA_RECIBIDA = 0;   // Fin del pulso de tarjeta, vuelve a bajo
        #24  DIGITO = 4'b0011;       // Primer dígito del PIN = 3
        #24  DIGITO_STB = 1;         // Confirma la captura del primer dígito
        #24  DIGITO_STB = 0;         // Fin de la confirmación
        #24  DIGITO = 4'b0101;       // Segundo dígito del PIN = 5
        #24  DIGITO_STB = 1;         // Pulso de validación del segundo dígito
        #24  DIGITO_STB = 0;         // Termina el pulso
        #24  DIGITO = 4'b0110;       // Tercer dígito del PIN = 6
        #24  DIGITO_STB = 1;         // Confirmación de entrada del tercer dígito
        #24  DIGITO_STB = 0;         // Señal baja, fin de validación
        #24  DIGITO = 4'b0110;       // Cuarto dígito del PIN = 6
        #24  DIGITO_STB = 1;         // Confirma el cuarto dígito
        #24  DIGITO_STB = 0;         // Pulso de confirmación finalizado
        #24  TIPO_TRANS = 1;         // Selección de transacción: 1 = Retiro
        #24  MONTO = 32'd900000;     // Se asigna monto de la transacción = 900000
        #24  MONTO_STB = 1;          // Confirma el registro del monto
        #24  MONTO_STB = 0;          // Fin del pulso
//--------------------------------FIN PRUEBA DE RETIRO FALLIDO-------------------------------------------

        #90 $finish;
    end
endmodule
