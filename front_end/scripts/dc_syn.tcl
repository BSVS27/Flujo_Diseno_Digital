##################################################################################
# Title:        dc_syn.tcl
# Description:	Flujo de sintesis logica en Design Compiler
# Dependencies: Ninguna.
# Library:	XFAB-180nm xh018 High Density Low Leakage
# Project:	RISC-V
# Author:	Reinaldo Castro Gonzalez
# Institution:	Instituto Tecnologico de Costa Rica. DCILab.
# Date:		23 de Mayo de 2018
# Notes:	Basado en los scripts del Dr. Juan Agustin Rodriguez para la
#		integración del proyecto SiRPA. 2014
# Version:	1.01 
# Revision:	30-07-18 ACR
#
###################################################################################

puts "RM-Info: Running script [info script]\n"



# Se suprimen algunos mensajes de alarmas los cuales se considera, pueden dejarse pasar.
# para ver mas detalles sobre los mensajes suprimidos, se recomienda ejecutar el comando:
# man <CODIGO>

suppress_message {VER-130 LINT-1 LINT-28 LINT-29 LINT-31 LINT-33 LINT-52 OPT-112 TIM-134\
				 PWR-6 PWR-410 PWR-428 PWR-412 UID-401};

#------------------------------------------------------------------------------
# Cargar los archivos fuente y elaborar el disenno
#------------------------------------------------------------------------------
#source -verbose "$PROY_HOME/scripts/analyze_rtl.tcl";

# Vincular el disenno
link > reports/link.txt; # Vincular los diseños

# Revisar el disenno
check_design > reports/check_dsgn.txt;
# set_ungroup [get_cells {u12 u13 u14 u15 u16}] false; 
# Ignorar, el comando anterior, se uso a modo de exploracion para no romper la jerarquia.
# Cosa que se puede hacer con un interruptor del comando compile_ultra

write -hierarchy -format ddc -output "$PROY_HOME_SYN/db/$DESIGN_NAME\_pre_compile.ddc";
# La ruta anterior debe existir!

#------------------------------------------------------------------------------
# Cargar las restricciones de disenno
#------------------------------------------------------------------------------
#En esta parte se correran los constraints 
#------------------------------------------------------------------------------

source -verbose -echo "$PROY_HOME_SYN/scripts/$DESIGN_NAME\_constraints.tcl";
propagate_constraints;


#------------------------------------------------------------------------------
#				Da permisos de poner buffer donde los necesite
#------------------------------------------------------------------------------
#set_fix_multiple_port_nets -feedthroughs -buffer_constants

#------------------------------------------------------------------------------
#				Activar el analisis del factor de actividad
#------------------------------------------------------------------------------
# En esta parte se selecciona el tipo de analsis para estimación de potencia que se va hacer
# si se utiliza topográfico el analisis se hara por saif file.
#------------------------------------------------------------------------------
if {[shell_is_in_topographical_mode]} {
	saif_map -start; 			
	set_power_prediction; 		
} else {
	propagate_switching_activity; 
}

#------------------------------------------------------------------------------
#								Compilacion
#------------------------------------------------------------------------------
#Compile ultra sintetiza el modulo para llevarlo a nivel de compuertas.
#------------------------------------------------------------------------------
compile_ultra -no_auto_ungroup -exact_map > reports/compile.txt; 



#------------------------------------------------------------------------------
#								Lectura saif
#------------------------------------------------------------------------------
# Lectura del saif, unicamente funcional en el modo topográfico
# read saif:Esta instruccion lee el saif 
#instance_name: Buscan la instancia dentro del saif.
#target_instance: busca la instancia dentro del diseño para matchearla con el saif.
#-------------------------------------------------------------------------------
if {[shell_is_in_topographical_mode]} {
	read_saif -input "$PROY_HOME/front_end/source/$DESIGN_NAME.saif" \
 -instance_name $TEST_INST_NAME/inst_top -auto_map_names;
}

set verilogout_no_tri true
change_names -hierarchy -rules verilog 

#------------------------------------------------------------------------------
#						Insersion de los pads de I/O
#------------------------------------------------------------------------------

#source -verbose -echo $PROY_HOME/front_end/scripts/pad_insertion.tcl;

#------------------------------------------------------------------------------
# 							Generacion de Reportes
#------------------------------------------------------------------------------

# Las rutas de los archivos de salida deben existir

report_power -analysis_effort high > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_power.txt";
report_area >  "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_area.txt";
report_qor > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_qor.txt";
report_timing > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_timing.txt";
report_port > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_port.txt";

#------------------------------------------------------------------------------
# 						Generacion de archivos de salida
#------------------------------------------------------------------------------
# Guardamos un formato ddc para leerlo mas rapido de vuelta en el ICC
write -hierarchy -format ddc -output "$TOP_FILE_DDC";
write -format verilog -hierarchy -output "$TOP_FILE_SYN";

#Guardamos info de restricciones para leerlo en ICC
write_sdc "$TOP_FILE_SDC";

#Guardamos info de temporizado en sdf para simulaciones 
write_sdf "$TOP_FILE_SDF";
puts "RM-Info: Completed script [info script]\n";
