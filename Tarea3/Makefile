# ============================================================================
# Makefile para simulación de CPU con Icarus Verilog y visualización con GTKWave
# Abre automáticamente el archivo Completo.gtkw al finalizar.
# Archivos: rom.v ram.v tester.v testbench.v cpu.v
# ============================================================================

# Nombre del ejecutable temporal
OUT = cpu_sim.vvp

# Archivos fuente del proyecto
SRC = rom.v ram.v tester.v testbench.v cpu.v

# Archivo GTKWave a abrir
GTKW = Completo.gtkw

# Archivo de volcado de valores (debe coincidir con el $dumpfile del testbench)
VCD = cpu_test.vcd

# Compiladores y herramientas
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Opciones de compilación
FLAGS = -Wall -g2012

# ============================================================================
# Reglas principales
# ============================================================================

all:
	@echo "Compilando con Icarus Verilog..."
	$(IVERILOG) $(FLAGS) -o $(OUT) $(SRC)
	@echo "Ejecutando simulación..."
	$(VVP) $(OUT)
	@echo "Abriendo GTKWave con $(GTKW)..."
	$(GTKWAVE) $(GTKW) &

# Solo correr la simulación (sin abrir GTKWave)
run:
	@echo "Ejecutando simulación..."
	$(VVP) $(OUT)

# Solo abrir GTKWave (sin recompilar)
wave:
	@echo "Abriendo GTKWave con $(GTKW)..."
	$(GTKWAVE) $(GTKW) &

# Limpiar archivos generados
clean:
	@echo "Limpiando archivos generados..."
	rm -f $(OUT) $(VCD)
	@echo "Limpieza completa."
