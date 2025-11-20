/* ============================================================================
 * Archivo: pcs_cg_defs.vh
 * Descripción:
 *   Definición de constantes para los *code-groups* (CGs) utilizados en 
 *   la codificación 8b/10b. Incluye tanto los códigos de datos (D) como 
 *   los códigos especiales (K) con sus respectivas representaciones de 
 *   disparidad positiva y negativa.
 * 
 * Uso:
 *   Se incluye en los módulos Verilog que implementan transmisores,
 *   receptores y sincronizadores para facilitar la referencia a CGs.
 * ============================================================================
 */

`ifndef code_groups
`define code_groups

    // =========================================================================
    // Definiciones de bytes de datos (D0 a D9) en formato 8b
    // =========================================================================
    `define D0_0_byte       8'b000_00000
    `define D1_0_byte       8'b000_00001
    `define D2_0_byte       8'b000_00010
    `define D3_0_byte       8'b000_00011
    `define D4_0_byte       8'b000_00100
    `define D5_0_byte       8'b000_00101
    `define D6_0_byte       8'b000_00110
    `define D7_0_byte       8'b000_00111
    `define D8_0_byte       8'b000_01000
    `define D9_0_byte       8'b000_01001

    // =========================================================================
    // Definiciones de code-groups de datos (D0 a D9) con disparidad negativa
    // =========================================================================
    `define D0_0_decmenos   10'b100111_0100
    `define D1_0_decmenos   10'b011101_0100
    `define D2_0_decmenos   10'b101101_0100
    `define D3_0_decmenos   10'b110001_1011
    `define D4_0_decmenos   10'b110101_0100
    `define D5_0_decmenos   10'b101001_1011
    `define D6_0_decmenos   10'b011001_1011
    `define D7_0_decmenos   10'b111000_1011
    `define D8_0_decmenos   10'b111001_0100
    `define D9_0_decmenos   10'b100101_1011

    // =========================================================================
    // Definiciones de code-groups de datos (D0 a D9) con disparidad positiva
    // =========================================================================
    `define D0_0_decmas     10'b011000_1011
    `define D1_0_decmas     10'b100010_1011
    `define D2_0_decmas     10'b010010_1011
    `define D3_0_decmas     10'b110001_0100
    `define D4_0_decmas     10'b001010_1011
    `define D5_0_decmas     10'b101001_0100
    `define D6_0_decmas     10'b011001_0100
    `define D7_0_decmas     10'b000111_0100
    `define D8_0_decmas     10'b000110_1011
    `define D9_0_decmas     10'b100101_0100

    // =========================================================================
    // Definiciones para CGs especiales usados en la sincronización
    // =========================================================================
    `define D16_2_byte      8'b010_10000
    `define D5_6_byte       8'b110_00101

    `define D16_2_decmenos  10'b011011_0101
    `define D5_6_decmenos   10'b101001_0110

    `define D16_2_decmas    10'b100100_0101
    `define D5_6_decmas     10'b101001_0110

    // =========================================================================
    // Definiciones para caracteres de control (K28.5)
    // =========================================================================
    `define K28_5_byte      8'b101_11100
    `define K28_5_decmenos  10'b001111_1010
    `define K28_5_decmas    10'b110000_0101

`endif