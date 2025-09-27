# Nombre del ejecutable temporal
OUT = sim.vvp

# Archivos fuente
#SRC = Cajero_synth_1.v Tester.v Testbench.v
#SRC = Cajero_rtlil_1.v Tester_original.v Testbench.v
SRC = Cajero.v Tester_original.v Testbench.v

# Regla por defecto
all:
	iverilog -o $(OUT) $(SRC)
	vvp $(OUT)
	# gtkwave Deposito.gtkw &
	# gtkwave Retiro.gtkw &
	# gtkwave Bloqueo.gtkw &
	# gtkwave Fondos.gtkw &
	gtkwave Completo.gtkw &
# Para probar comente y descomente la sección superior según cada caso
	
# Limpiar archivos generados
clean:
	rm -f $(OUT) cajero.vcd
