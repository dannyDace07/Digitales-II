/* ============================================================================
 * Archivo: pcs_defs.vh
 * Descripción:
 *   Definición de constantes y parámetros utilizados en los módulos 
 *   principales de la capa PCS (Physical Coding Sublayer). Incluye:
 *   - Estados lógicos generales
 *   - Parámetros para disparidad (8b/10b)
 *   - Definición de CGs especiales de control y datos
 * ============================================================================
 */

`ifndef PCS_DEFS
`define PCS_DEFS

    // =========================================================================
    // Definiciones de estados lógicos
    // =========================================================================
    `define TRUE 1'b1        // Valor lógico verdadero
    `define FALSE 1'b0       // Valor lógico falso

    // =========================================================================
    // Disparidad para la codificación 8b/10b
    // =========================================================================
    `define POSITIVE 1'b1    // Disparidad positiva
    `define NEGATIVE 1'b0    // Disparidad negativa

    // =========================================================================
    // Ordered Sets utilizados por el transmisor
    // =========================================================================
    `define COMMA_o_set     8'hBC   // Comma (/K28.5/)
    `define IDLE_o_set      `COMMA_o_set // IDLE es equivalente al comma
    `define CE_o_set        8'hF7   // Carrier Extend
    `define SPD_o_set       8'hFB   // Start of Packet Delimiter
    `define EPD_o_set       8'hFD   // End of Packet Delimiter

    // =========================================================================
    // Estados de operación (XMIT)
    // =========================================================================
    `define CONFIGURATION 3'd1  // Configuración
    `define DATA          3'd2  // Transmisión de datos
    `define IDLE          3'd4  // Estado de reposo

    // =========================================================================
    // Definición de caracteres de control (K) y datos (D)
    // =========================================================================

    // Caracteres especiales de control (K)
    `define K28_5         8'b10111100
    `define K28_5_RDN     10'b0011111010 // K28.5 disparidad negativa
    `define K28_5_RDP     10'b1100000101 // K28.5 disparidad positiva

    `define K27_7         8'b11111011
    `define K27_7_RDN     10'b1101101000 // Start of Packet
    `define K27_7_RDP     10'b0010010111

    `define K23_7         8'b11110111
    `define K23_7_RDN     10'b1110101000 // Carrier Extend
    `define K23_7_RDP     10'b0001010111

    `define K29_7         8'b11111101
    `define K29_7_RDN     10'b1011101000 // End of Packet
    `define K29_7_RDP     10'b0100010111

    `define D             8'b11111111 // Datos (placeholder)

    // Bytes de datos (D0-D9) y sus CGs asociados
    `define D0_0          8'b00000000 
    `define D0_0_RDN      10'b1001110100
    `define D0_0_RDP      10'b0110001011

    `define D1_0          8'b00000001
    `define D1_0_RDN      10'b0111010100
    `define D1_0_RDP      10'b1000101011

    `define D2_0          8'b00000010
    `define D2_0_RDN      10'b1011010100
    `define D2_0_RDP      10'b0100101011

    `define D3_0          8'b00000011
    `define D3_0_RDN      10'b1100011011
    `define D3_0_RDP      10'b1100010100

    `define D4_0          8'b00000100
    `define D4_0_RDN      10'b1101010100
    `define D4_0_RDP      10'b0010101011

    `define D5_0          8'b00000101
    `define D5_0_RDN      10'b1010011011
    `define D5_0_RDP      10'b1010010100

    `define D6_0          8'b00000110
    `define D6_0_RDN      10'b0110011011
    `define D6_0_RDP      10'b0110010100

    `define D7_0          8'b00000111
    `define D7_0_RDN      10'b1110001011
    `define D7_0_RDP      10'b0001110100

    `define D8_0          8'b00001000
    `define D8_0_RDN      10'b1110010100
    `define D8_0_RDP      10'b0001101011

    `define D9_0          8'b00001001
    `define D9_0_RDN      10'b1001011011
    `define D9_0_RDP      10'b1001010100

    // CGs especiales
    `define D16_2         8'b01010000
    `define D16_2_RDN     10'b0110110101
    `define D16_2_RDP     10'b1001000101

`endif