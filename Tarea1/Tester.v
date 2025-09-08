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
    output reg [31:0] MONTO
);

    initial CLK = 0;
    always #2 CLK = ~CLK;

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
        #8 RESET = 1;           // Se activa el sistema del cajero
        #4 TARJETA_RECIBIDA = 1; // La tarjeta es insertada
        #20 TARJETA_RECIBIDA = 0; // Finaliza la lectura de la tarjeta
        #4 DIGITO = 4'b0011;    // Primer dígito del PIN ingresado
        #1 DIGITO_STB = 1;      // Se marca que el dígito está disponible
        #3 DIGITO_STB = 0;      // Se desmarca la señal de dígito recibido
        #4 DIGITO = 4'b0101;    // Segundo dígito del PIN
        #1 DIGITO_STB = 1;      // Confirmación de entrada del segundo dígito
        #3 DIGITO_STB = 0;      // Señal de confirmación vuelve a cero
        #4 DIGITO = 4'b0110;    // Tercer dígito del PIN
        #1 DIGITO_STB = 1;      // Se valida la entrada del tercer dígito
        #3 DIGITO_STB = 0;      // La validación se apaga
        #4 DIGITO = 4'b0110;    // Cuarto dígito del PIN
        #1 DIGITO_STB = 1;      // Se confirma la llegada del cuarto dígito
        #3 DIGITO_STB = 0;      // Fin de la confirmación
        #2 TIPO_TRANS = 0;      // Selección de tipo de transacción: Depósito
        #4 MONTO = 32'd10000;   // Se introduce el monto: 10,000
        #2 MONTO_STB = 1;       // El monto queda registrado
        #4 MONTO_STB = 0;       // La señal de registro del monto se apaga
//-------------------------------FIN PRUEBA DE DEPOSITO EXITOSO-------------------------------------------


//-------------------------------INICIO DE PRUEBA DE RETIRO EXITOSO---------------------------------------        
	#4 TARJETA_RECIBIDA = 1;   // Señal de inserción de tarjeta -> activa
        #20 TARJETA_RECIBIDA = 0;  // Fin de la detección de tarjeta -> señal baja
        #4 DIGITO = 4'b0011;       // Entrada del primer dígito del PIN (valor binario 3)
        #4 DIGITO_STB = 1;         // Se confirma que el primer dígito está listo
        #4 DIGITO_STB = 0;         // Fin para el primer dígito
        #4 DIGITO = 4'b0101;       // Entrada del segundo dígito del PIN (valor binario 5)
        #4 DIGITO_STB = 1;         // Se confirma que el primer dígito está listo
        #4 DIGITO_STB = 0;         // Fin para el segundo dígito
        #4 DIGITO = 4'b0110;       // Entrada del tercer dígito del PIN (valor binario 6)
        #4 DIGITO_STB = 1;         // Se confirma que el tercer dígito está listo
        #4 DIGITO_STB = 0;         // Fin para el tercer digito
        #4 DIGITO = 4'b0110;       // Entrada del cuarto dígito del PIN (valor binario 6)
        #4 DIGITO_STB = 1;         // Se confirma que el cuarto dígito está listo
        #4 DIGITO_STB = 0;         // Fin para el cuarto digito 
        #4 TIPO_TRANS = 1;         // Selección del tipo de transacción: Retiro (1)
        #4 MONTO = 32'd7000;       // Se coloca el monto de la transacción
        #4 MONTO_STB = 1;          // Monto capturado por el sistema
        #4 MONTO_STB = 0;          // Fin de la señal de captura de monto
//--------------------------------FIN PRUEBA DE RETIRO EXITOSO------------------------------------------

//--------------------------------PRUEBA DE PIN INCORRECTO----------------------------------------------        
        #4 TARJETA_RECIBIDA = 1; // Se recibe la tarjeta
        #20 TARJETA_RECIBIDA = 0; // Se deja de recibir la tarjeta
        #4 DIGITO = 4'b0011; // Se recibe el primer digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0101; // Se recibe el segundo digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido     
        #4 DIGITO = 4'b0110; // Se recibe el tercer digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0001; // Se recibe el cuarto digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0001; // Se recibe el primer digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0001; // Se recibe el segundo digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido     
        #4 DIGITO = 4'b0001; // Se recibe el tercer digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0001; // Se recibe el cuarto digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido  
        #4 DIGITO = 4'b0001; // Se recibe el primer digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0101; // Se recibe el segundo digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido     
        #4 DIGITO = 4'b0011; // Se recibe el tercer digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0100; // Se recibe el cuarto digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido  
//-------------------------------FIN PRUEBA PIN INCORRECTO----------------------------------------------

//------------------------------SALIR DEL ESTADO DE BLOQUEO -------------------------
        #20 RESET = 0;        // Señal de reset activa en bajo (sistema en reinicio)
        #8  RESET = 1;        // Reset desactivado, el sistema comienza la operación normal
        #8  TARJETA_RECIBIDA = 1;  // Pulso de inserción de tarjeta (señal en alto)
        #4  TARJETA_RECIBIDA = 0;  // Fin de la detección de tarjeta
        #4  DIGITO = 4'b0011;      // Se coloca el primer dígito del PIN (3)
        #4  DIGITO_STB = 1;        // Confirma el registro del dígito
        #4  DIGITO_STB = 0;        // Fin de la confirmación
        #4  DIGITO = 4'b0101;      // Segundo dígito del PIN (5)
        #4  DIGITO_STB = 1;        // Validación del segundo dígito
        #4  DIGITO_STB = 0;        // Fin del pulso de validación
        #4  DIGITO = 4'b0110;      // Tercer dígito del PIN (6)
        #4  DIGITO_STB = 1;        // Confirma la entrada del dígito
        #4  DIGITO_STB = 0;        // Señal vuelve a bajo
        #4  DIGITO = 4'b0110;      // Cuarto dígito del PIN (6)
        #4  DIGITO_STB = 1;        // Confirmación del cuarto dígito
        #4  DIGITO_STB = 0;        // Fin de la confirmación
        #4  TIPO_TRANS = 0;        // Selección de transacción: 0 = Depósito
        #4  MONTO = 32'd10000;     // Se asigna el valor de la transacción (10 000)
        #4  MONTO_STB = 1;         // El monto queda registrado
        #4  MONTO_STB = 0;         // Fin de la señal de registro de monto    
//----------------------FIN DE ACCION EN ESTADO DE BLOQUEO--------------------------------------------

//----------------------INICIO DE PRUEBA DE RETIRO FALLIDO--------------------------------------------
        #10  TARJETA_RECIBIDA = 1;   // Pulso en alto: se detecta la inserción de tarjeta
        #20  TARJETA_RECIBIDA = 0;   // Fin del pulso de tarjeta, vuelve a bajo
        #4  DIGITO = 4'b0011;       // Primer dígito del PIN = 3
        #4  DIGITO_STB = 1;         // Confirma la captura del primer dígito
        #4  DIGITO_STB = 0;         // Fin de la confirmación
        #4  DIGITO = 4'b0101;       // Segundo dígito del PIN = 5
        #4  DIGITO_STB = 1;         // Pulso de validación del segundo dígito
        #4  DIGITO_STB = 0;         // Termina el pulso
        #4  DIGITO = 4'b0110;       // Tercer dígito del PIN = 6
        #4  DIGITO_STB = 1;         // Confirmación de entrada del tercer dígito
        #4  DIGITO_STB = 0;         // Señal baja, fin de validación
        #4  DIGITO = 4'b0110;       // Cuarto dígito del PIN = 6
        #4  DIGITO_STB = 1;         // Confirma el cuarto dígito
        #4  DIGITO_STB = 0;         // Pulso de confirmación finalizado
        #4  TIPO_TRANS = 1;         // Selección de transacción: 1 = Retiro
        #4  MONTO = 32'd900000;     // Se asigna monto de la transacción = 900000
        #4  MONTO_STB = 1;          // Confirma el registro del monto
        #4  MONTO_STB = 0;          // Fin del pulso
//--------------------------------FIN PRUEBA DE RETIRO FALLIDO-------------------------------------------

        #25 $finish;
    end
endmodule
