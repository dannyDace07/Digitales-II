module Testbench;

    // Señales de entrada en Cajero.v
    wire        CLK;
    wire        RESET;
    wire        TARJETA_RECIBIDA;
    wire        DIGITO_STB;
    wire        TIPO_TRANS;
    wire        MONTO_STB;
    wire [15:0] PIN_CORRECTO;
    wire [3:0]  DIGITO;
    wire [63:0] BALANCE_INICIAL;
    wire [31:0] MONTO;

    // Señales de salida
    wire [63:0] BALANCE_ACTUALIZADO;
    wire        ADVERTENCIA;
    wire        BLOQUEO;
    wire        BALANCE_STB;
    wire        ENTREGAR_DINERO;
    wire        PIN_INCORRECTO;
    wire        FONDOS_INSUFICIENTES;

    // Instancia del DUT
    Cajero dut (
        .CLK(CLK),
        .RESET(RESET),
        .TARJETA_RECIBIDA(TARJETA_RECIBIDA),
        .PIN_CORRECTO(PIN_CORRECTO),
        .DIGITO(DIGITO),
        .DIGITO_STB(DIGITO_STB),
        .TIPO_TRANS(TIPO_TRANS),
        .BALANCE_INICIAL(BALANCE_INICIAL),
        .MONTO(MONTO),
        .MONTO_STB(MONTO_STB),
        .BALANCE_ACTUALIZADO(BALANCE_ACTUALIZADO),
        .ADVERTENCIA(ADVERTENCIA),
        .BLOQUEO(BLOQUEO),
        .BALANCE_STB(BALANCE_STB),
        .ENTREGAR_DINERO(ENTREGAR_DINERO),
        .PIN_INCORRECTO(PIN_INCORRECTO),
        .FONDOS_INSUFICIENTES(FONDOS_INSUFICIENTES)
    );

    // Instancia del tester (driver)
    tester driver (
        .CLK(CLK),
        .RESET(RESET),
        .TARJETA_RECIBIDA(TARJETA_RECIBIDA),
        .DIGITO_STB(DIGITO_STB),
        .TIPO_TRANS(TIPO_TRANS),
        .MONTO_STB(MONTO_STB),
        .PIN_CORRECTO(PIN_CORRECTO),
        .DIGITO(DIGITO),
        .BALANCE_INICIAL(BALANCE_INICIAL),
        .MONTO(MONTO)
    );

    // Monitoreo y dumping
    initial begin
        $dumpfile("cajero.vcd");
        $dumpvars(0, Testbench);

        $monitor("T=%0t | PIN=%h | BALANCE_INICIAL=%0d | BALANCE_ACTUALIZADO=%0d | ADVERTENCIA=%b | BLOQUEO=%b | PIN_INCORRECTO=%b | FONDOS_INSUFICIENTES=%b",
                 $time, PIN_CORRECTO, BALANCE_INICIAL, BALANCE_ACTUALIZADO,
                 ADVERTENCIA, BLOQUEO, PIN_INCORRECTO, FONDOS_INSUFICIENTES);
    end

endmodule
