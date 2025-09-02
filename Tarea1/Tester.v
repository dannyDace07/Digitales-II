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
        // Inicializacion de senales
        RESET = 0;
        TARJETA_RECIBIDA = 0;
        DIGITO_STB = 0;
        TIPO_TRANS = 0;
        MONTO_STB = 0;
        PIN_CORRECTO = 16'd0;
        DIGITO = 4'd0;
        BALANCE_INICIAL = 64'd0;
        MONTO = 32'd0;

        PIN_CORRECTO = 16'b0011010101100110; // PIN 3566
        BALANCE_INICIAL = 64'd10000;
        MONTO = 32'd0;
        #4;

//-----------------------------INICIO DE PRUEBA DE DEPOSITO EXITOSO------------------------------------------
        #8 RESET = 1; //Se libera sistema
        #4 TARJETA_RECIBIDA = 1; // Se recibe la tarjeta
        #4 TARJETA_RECIBIDA = 0; // Se deja de recibir la tarjeta
        #4 DIGITO = 4'b0011; // Se recibe el primer digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0101; // Se recibe el segundo digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0110; // Se recibe el tercer digito  
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0110; // Se recibe el cuarto digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 TIPO_TRANS = 0; //Deposito
        #4 MONTO = 32'd10000; // Se recibe el monto a depositar
        #4 MONTO_STB = 1; // Se indica que el monto fue recibido
        #4 MONTO_STB = 0; // Se deja de indicar que el monto fue recibido
//-------------------------------FIN PRUEBA DE DEPOSITO EXITOSO-------------------------------------------

//-------------------------------INICIO DE PRUEBA DE RETIRO EXITOSO---------------------------------------        
	    #4 TARJETA_RECIBIDA = 1; // Se recibe la tarjeta
        #4 TARJETA_RECIBIDA = 0; // Se deja de recibir la tarjeta
        #4 DIGITO = 4'b0011; // Se recibe el primer digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0101; // Se recibe el segundo digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0110; // Se recibe el tercer digito  
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0110; // Se recibe el cuarto digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 TIPO_TRANS = 1; //Retiro
        #4 MONTO = 32'd7000; // Se recibe el monto a retirar
        #4 MONTO_STB = 1; // Se indica que el monto fue recibido
        #4 MONTO_STB = 0; // Se deja de indicar que el monto fue recibido
//--------------------------------FIN PRUEBA DE RETIRO EXITOSO------------------------------------------

//--------------------------------PRUEBA DE PIN INCORRECTO----------------------------------------------        
        #6 TARJETA_RECIBIDA = 1; // Se recibe la tarjeta
        #4 TARJETA_RECIBIDA = 0; // Se deja de recibir la tarjeta
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
        #4 RESET = 0; // Se pone Reset en 0
        #4 RESET = 1; // Se pone Reset en 1
        #8 TARJETA_RECIBIDA = 1; // Se regresa a esperar la tarjeta
        #4 TARJETA_RECIBIDA = 0; // Se deja de recibir la tarjeta
        #4 DIGITO = 4'b0011; // Se recibe el primer digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0101; // Se recibe el segundo digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0110; // Se recibe el tercer digito  
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0110; // Se recibe el cuarto digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 TIPO_TRANS = 0; //Deposito
        #4 MONTO = 32'd10000; // Se recibe el monto a depositar
        #4 MONTO_STB = 1; // Se indica que el monto fue recibido
        #4 MONTO_STB = 0; // Se deja de indicar que el monto fue recibido    
//----------------------FIN DE ACCION EN ESTADO DE BLOQUEO--------------------------------------------

//----------------------INICIO DE PRUEBA DE RETIRO FALLIDO--------------------------------------------
        #4 TARJETA_RECIBIDA = 1; // Se recibe la tarjeta
        #4 TARJETA_RECIBIDA = 0; // Se deja de recibir la tarjeta
        #4 DIGITO = 4'b0011; // Se recibe el primer digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0101; // Se recibe el segundo digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0110; // Se recibe el tercer digito  
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 DIGITO = 4'b0110; // Se recibe el cuarto digito
        #4 DIGITO_STB = 1; // Se indica que el digito fue recibido
        #4 DIGITO_STB = 0; // Se deja de indicar que el digito fue recibido
        #4 TIPO_TRANS = 1; //Retiro
        #4 MONTO = 32'd900000; // Se recibe el monto a retirar
        #4 MONTO_STB = 1; // Se indica que el monto fue recibido
        #4 MONTO_STB = 0; // Se deja de indicar que el monto fue recibido
//--------------------------------FIN PRUEBA DE RETIRO FALLIDO-------------------------------------------

        $finish;
    end
endmodule