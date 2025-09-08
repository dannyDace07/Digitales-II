# Nombre del ejecutable temporal
OUT = sim.vvp

# Archivos fuente
SRC = Cajero.v Tester.v Testbench.v

# Regla por defecto
all:
	iverilog -o $(OUT) $(SRC)
	vvp $(OUT)
	gtkwave cajero.vcd &
	
# Limpiar archivos generados
clean:
	rm -f $(OUT) cajero.vcd
