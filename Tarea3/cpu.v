// ============================================================================
// MÓDULO: CPU - Controlador de CPU
// Descripción: Máquina de estados finita que controla la ejecución de 
//              instrucciones desde ROM y gestiona acceso a RAM
// Diseñado por: [Danny Gutiérrez Campos]
// Carné: C33566
// Curso: IE-0523 Circuitos Digitales II
// ============================================================================

module cpu (
  // ==========================================
  // SEÑALES DE RELOJ Y CONTROL
  // ==========================================
  input  wire clk,              // CLK: Entrada de reloj, flanco activo creciente
  input  wire rst,              // RESET: Entrada de reinicio (1=normal, 0=reset)
                                // Nota: Implementado como reset síncrono activo alto

  // ==========================================
  // INTERFAZ CON ROM 
  // ==========================================
  output reg  request_rom,      // Señal de solicitud de lectura a ROM
  output reg  [11:0] contador,  // PROG_ADDR[11:0]: Contador de programa (dirección en ROM)
  input  wire [15:0] rom_data,  // Instrucción completa desde ROM (16 bits)
                                // Formato: [OPCODE(4)][A/B(1)][LIBRE(3)][OP_ADDR(8)]

  // ==========================================
  // INTERFAZ CON RAM 
  // ==========================================
  output reg  ram_request,      // Señal de solicitud de acceso a RAM
  output reg  mem_control,      // MEM_CONTROL: Control de operación
                                // 0 = Escritura en RAM
                                // 1 = Lectura desde RAM
  output reg  [11:0] address,   // MEM_ADDR[11:0]: Dirección de memoria RAM a acceder
  output reg  [7:0] ram_data_in,   // MEM_DATA[7:0]: Datos a escribir en RAM (salida del CPU)
  input  wire [7:0] ram_data_out,  // MEM_DATA[7:0]: Datos leídos desde RAM (entrada al CPU)

  // ==========================================
  // SEÑALES DE ESTADO Y CONTROL
  // ==========================================
  output reg  equal,                    // EQUAL: Bandera que indica regA == regB
  output reg [2:0] estado,              // Estado actual 
  output reg [2:0] proximo_estado       // Próximo estado 
);

  // ==========================================
  // DEFINICIÓN DE ESTADOS 
  // ==========================================
  localparam BUSCAR               = 3'b000;  // Leer instrucción desde ROM
  localparam DECODIFICAR          = 3'b001;  // Decodificar OPCODE, A/B SELECT, OP_ADDR
  localparam EJECUTAR             = 3'b010;  // Ejecutar la operación correspondiente
  localparam ESPERAR_RAM          = 3'b011;  // Esperar respuesta de RAM (solo LOAD)
  localparam ESCRIBIR             = 3'b100;  // Escribir dato de RAM a registro (solo LOAD)
  localparam INCREMENTAR_CONTADOR = 3'b101;  // Incrementar PROG_ADDR
  localparam DETENER              = 3'b110;  // Detener ejecución (después de EQUAL exitoso)

  // ==========================================
  // REGISTROS INTERNOS DEL CPU
  // ==========================================
  reg [7:0] regA, regB;        // Registros A y B (8 bits)
  reg [3:0]  opcode;           // OPCODE[3:0]: Código de operación de la instrucción actual
  reg        ab_select;        // A/B SELECT: Selector de registro (0=A, 1=B)
  reg [7:0]  op_address;       // OP_ADDR[7:0]: Dirección del operando (para LOAD/STORE)

  // ==========================================
  // FORMATO DE INSTRUCCIÓN DE 16 BITS:
  // [15:12] = OPCODE[3:0]    - Código de operación 
  // [11]    = A/B SELECT     - Selector de registro (0=A, 1=B)
  // [10:8]  = SIN USAR       - Bits no utilizados (se ignoran)
  // [7:0]   = OP_ADDR[7:0]   - Dirección del operando en RAM
  // ==========================================

  // ============================================================================
  // BLOQUE SECUENCIAL: Actualización de estado y registros
  // Se ejecuta en cada flanco positivo del reloj (CLK)
  // ============================================================================
  always @(posedge clk) begin
    if (rst) begin
      // ==========================================
      // RESET: Volver al estado inicial
      // Todas las salidas toman el valor de cero
      // PROG_ADDR regresa a la posición cero
      // ==========================================
      estado       <= BUSCAR;        // Iniciar en estado BUSCAR
      contador     <= 0;             // PROG_ADDR = 0 (primera instrucción)
      regA         <= 0;             // Registro A = 0
      regB         <= 0;             // Registro B = 0
      opcode       <= 0;             // OPCODE = 0
      ab_select    <= 0;             // A/B SELECT = 0
      op_address   <= 0;             // OP_ADDR = 0
      equal        <= 0;             // EQUAL = 0
    end else begin
      estado <= proximo_estado;  // Avanzar al próximo estado

      case (estado)
        // ----------------------------------------
        // ESTADO: DECODIFICAR
        // Separar la instrucción en sus componentes:
        // 1. OPCODE - Código de operación
        // 2. A/B SELECT - Selección de registro
        // 3. OP_ADDR - Dirección de memoria
        // ----------------------------------------
        DECODIFICAR: begin
          opcode      <= rom_data[15:12];  // OPCODE[3:0] = bits 15-12
          ab_select   <= rom_data[11];     // A/B SELECT = bit 11
          op_address  <= rom_data[7:0];    // OP_ADDR[7:0] = bits 7-0
        end

        // ----------------------------------------
        // ESTADO: EJECUTAR
        // Ejecutar operaciones aritméticas y lógicas
        // (solo ADD, SUB, OR, AND, EQUAL)
        // ----------------------------------------
        EJECUTAR: begin
          case (opcode)
            4'b1001: regB <= regA + regB;       // ADD: regB <- regA + regB
            4'b1010: regB <= regA - regB;       // SUB: regB <- regA - regB
            4'b0001: regB <= regA | regB;       // OR:  regB <- regA | regB
            4'b0010: regB <= regA & regB;       // AND: regB <- regA & regB
            4'b0101: equal <= (regA == regB);   // EQUAL: regA igual a regB
            default: ;  
          endcase
        end

        // ----------------------------------------
        // ESTADO: ESCRIBIR
        // Completar operación LOAD:
        // Tomar el valor de MEM_DATA y almacenarlo
        // en el registro indicado por A/B SELECT
        // ----------------------------------------
        ESCRIBIR: begin
          if (ab_select == 1'b0)
            regA <= ram_data_out;  // A/B SELECT=0: escribir en registro A
          else
            regB <= ram_data_out;  // A/B SELECT=1: escribir en registro B
        end

        // ----------------------------------------
        // ESTADO: INCREMENTAR_CONTADOR
        // Incrementar PROG_ADDR para avanzar a la
        // siguiente instrucción en ROM
        // ----------------------------------------
        INCREMENTAR_CONTADOR: begin
          contador <= contador + 1;  
        end
      endcase
    end
  end

  // ============================================================================
  // BLOQUE COMBINACIONAL: Lógica de control y transición de estados
  // Decide el próximo estado y genera las señales de control
  // Se ejecuta cada vez que cambia cualquier señal
  // ============================================================================
  always @(*) begin
    proximo_estado = estado;                  // Por defecto, mantener estado actual
    request_rom    = 0;                       
    ram_request    = 0;                       
    mem_control    = 0;                       
    address        = {4'b0000, op_address};   // MEM_ADDR: expandir OP_ADDR de 8 a 12 bits
    ram_data_in    = 0;                       

    case (estado)
      // ========================================
      // ESTADO: BUSCAR
      // Leer la siguiente instrucción desde ROM
      // El controlador presenta PROG_ADDR a la ROM
      // y espera que devuelva los datos válidos
      // ========================================
      BUSCAR: begin
        request_rom    = 1;              // Solicitar lectura de ROM
        proximo_estado = DECODIFICAR;    
      end

      // ========================================
      // ESTADO: DECODIFICAR
      // La ROM ha devuelto la instrucción
      // Los campos OPCODE, A/B SELECT y OP_ADDR
      // se extraen en el bloque secuencial
      // ========================================
      DECODIFICAR: begin
        request_rom    = 0;              // Desactivar solicitud a ROM
        proximo_estado = EJECUTAR;       
      end

      // ========================================
      // ESTADO: EJECUTAR
      // Ejecutar la instrucción según OPCODE
      // ========================================
      EJECUTAR: begin
        case (opcode)
          // ------------------------------------
          // INSTRUCCIÓN: LOAD
          // Leer posición OP_ADDR de la RAM y
          // almacenar en el registro indicado por A/B SELECT
          // 
          // Pasos:
          // 1. Poner MEM_CONTROL=1 (lectura)
          // 2. Poner OP_ADDR en MEM_ADDR
          // 3. Esperar que dato aparezca en MEM_DATA
          // 4. Almacenar MEM_DATA en registro A o B
          // ------------------------------------
          4'b0011: begin
            ram_request    = 1;                         // Solicitar acceso a RAM
            mem_control    = 1;                         // MEM_CONTROL=1 (lectura)
            address        = {4'b0000, op_address};     // MEM_ADDR <- OP_ADDR
            proximo_estado = ESPERAR_RAM;               
          end

          // ------------------------------------
          // INSTRUCCIÓN: STORE
          // Escribir el contenido del registro
          // (indicado por A/B SELECT) en la posición
          // OP_ADDR de la RAM
          // 
          // Pasos:
          // 1. Poner MEM_CONTROL=0 (escritura)
          // 2. Poner OP_ADDR en MEM_ADDR
          // 3. Poner contenido del registro en MEM_DATA
          // ------------------------------------
          4'b0100: begin
            ram_request    = 1;                         // Solicitar acceso a RAM
            mem_control    = 0;                         // MEM_CONTROL=0 (escritura)
            address        = {4'b0000, op_address};     // MEM_ADDR <- OP_ADDR
            ram_data_in    = (ab_select) ? regB : regA; // MEM_DATA <- reg A o B
            proximo_estado = INCREMENTAR_CONTADOR;      
          end

          // ------------------------------------
          // INSTRUCCIÓN: EQUAL
          // Comparar contenido de registro A con B
          // Si son iguales, terminar programa
          // Si no son iguales, continuar ejecución
          // ------------------------------------
          4'b0101: begin
            if (regA == regB) begin
              proximo_estado = DETENER;               // regA == regB -> DETENER
            end else begin
              proximo_estado = INCREMENTAR_CONTADOR;  // regA != regB -> Continuar
            end
          end

          // ------------------------------------
          // INSTRUCCIONES: ADD, SUB, OR, AND
          // No hacen acceso a memoria
          // Solo operan con registros A y B
          // El resultado se almacena en B
          // La operación se ejecuta en el bloque secuencial
          // ------------------------------------
          4'b1001, 4'b1010, 4'b0001, 4'b0010: begin
            proximo_estado = INCREMENTAR_CONTADOR;    
          end

          // ------------------------------------
          // INSTRUCCIÓN DESCONOCIDA
          // Ignorar y continuar
          // ------------------------------------
          default: begin
            proximo_estado = INCREMENTAR_CONTADOR;    
          end
        endcase
      end

      // ========================================
      // ESTADO: ESPERAR_RAM
      // Mantener las señales de RAM activas
      // mientras la RAM procesa la solicitud de lectura
      // ========================================
      ESPERAR_RAM: begin
        ram_request    = 1;                       // Mantener solicitud de RAM activa
        mem_control    = 1;                       // Mantener MEM_CONTROL=1 (lectura)
        address        = {4'b0000, op_address};   
        proximo_estado = ESCRIBIR;                
      end

      // ========================================
      // ESTADO: ESCRIBIR
      // El dato válido ya está presente en MEM_DATA
      // Almacenarlo en el registro correspondiente
      // (La escritura real ocurre en el bloque secuencial)
      // ========================================
      ESCRIBIR: begin
        ram_request    = 0;                   // Desactivar solicitud a RAM
        mem_control    = 0;                   // MEM_CONTROL=0 (modo escritura por defecto)
        proximo_estado = INCREMENTAR_CONTADOR; 
      end

      // ========================================
      // ESTADO: INCREMENTAR_CONTADOR
      // Incrementar PROG_ADDR (se hace en bloque secuencial)
      // Verificar si se debe detener por EQUAL
      // ========================================
      INCREMENTAR_CONTADOR: begin
        // Si la última instrucción fue EQUAL y los registros son iguales, detener
        if (opcode == 4'b0101 && equal) begin
          proximo_estado = DETENER;           //  DETENER (programa terminado)
        end else begin
          proximo_estado = BUSCAR;            //  BUSCAR siguiente instrucción
        end
      end

      // ========================================
      // ESTADO: DETENER
      // Estado final del programa
      // Alcanzado después de completar una operación EQUAL exitosa
      // La CPU permanece aquí indefinidamente
      // ========================================
      DETENER: begin
        request_rom    = 0;                   // Desactivar ROM
        ram_request    = 0;                   // Desactivar RAM
        mem_control    = 0;                   // MEM_CONTROL=0
        proximo_estado = DETENER;             // Permanecer en DETENER
      end
    endcase
  end
endmodule