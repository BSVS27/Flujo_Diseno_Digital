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
link > reports/link.txt;

# Revisar el disenno
check_design > reports/check_dsgn.txt;

foreach_in_collection net [get_nets -hierarchical -of_objects [get_cells -hierarchical -regexp "inst_ffcarryout"]] {set_dont_touch [get_attribute $net name] true;}

foreach_in_collection net [get_nets -hierarchical -of_objects [get_cells -hierarchical -regexp "inst_CSK"]] {set_dont_touch [get_attribute $net name] true;}
foreach_in_collection net [get_nets -hierarchical -of_objects [get_cells -hierarchical -regexp "inst_BS"]] {set_dont_touch [get_attribute $net name] true;}
foreach_in_collection net [get_nets -hierarchical -of_objects [get_cells -hierarchical -regexp "inst_ffA"]] {set_dont_touch [get_attribute $net name] true;}
foreach_in_collection net [get_nets -hierarchical -of_objects [get_cells -hierarchical -regexp "inst_ffB"]] {set_dont_touch [get_attribute $net name] true;}
foreach_in_collection net [get_nets -hierarchical -of_objects [get_cells -hierarchical -regexp "inst_ffcntrl"]] {set_dont_touch [get_attribute $net name] true;}
foreach_in_collection net [get_nets -hierarchical -of_objects [get_cells -hierarchical -regexp "inst_ffcin"]] {set_dont_touch [get_attribute $net name] true;}
foreach_in_collection net [get_nets -hierarchical -of_objects [get_cells -hierarchical -regexp "inst_ffzero"]] {set_dont_touch [get_attribute $net name] true;}
foreach_in_collection net [get_nets -hierarchical -of_objects [get_cells -hierarchical -regexp "inst_ffoverflow"]] {set_dont_touch [get_attribute $net name] true;}
foreach_in_collection net [get_nets -hierarchical -of_objects [get_cells -hierarchical -regexp "inst_ffnegative"]] {set_dont_touch [get_attribute $net name] true;}
foreach_in_collection net [get_nets -hierarchical -of_objects [get_cells -hierarchical -regexp "inst_ffout"]] {set_dont_touch [get_attribute $net name] true;}


# set_ungroup [get_cells {u12 u13 u14 u15 u16}] false; 
# Ignorar, el comando anterior, se uso a modo de exploracion para no romper la jerarquia.
# Cosa que se puede hacer con un interruptor del comando compile_ultra

write -hierarchy -format ddc -output "$PROY_HOME_SYN/db/$DESIGN_NAME\_pre_compile.ddc";
# La ruta anterior debe existir!

#------------------------------------------------------------------------------
# Cargar las restricciones de disenno
#------------------------------------------------------------------------------
#source ./scripts/alu_constraints.tcl;
source -verbose -echo "$PROY_HOME_SYN/scripts/$DESIGN_NAME\_constraints.tcl";
propagate_constraints;

# El siguiente comando controla si la compilacion agrega logica extra al disenno para garantizar que
# no hayan avances (feedthroughs) o que no hay dos puertos de salida conectados a la misma red en 
# ningun nivel de jerarquia los interruptores -feedthroughs y -buffer_constants; respectivamente, 
# insertan bufers para: aislar los puertos de entrada de los puertos de salida en todos los niveles
# de la jerarquia, y para las constantes logicas en lugar de duplicarlas

set_fix_multiple_port_nets -feedthroughs -buffer_constants; # Para este ejemplo en particular

set_fix_multiple_port_nets -all -

#------------------------------------------------------------------------------
#				Activar el analisis del factor de actividad
#------------------------------------------------------------------------------

if {[shell_is_in_topographical_mode]} {
#	saif_map -start; 			
#	set_power_prediction; 		
} else {
#	propagate_switching_activity; # Este comando no se recomienda usar mas. Quedara obsoleto pronto 
	# Se usaba con el constraint de set_switching_activity
}

#------------------------------------------------------------------------------
#								Compilacion
#------------------------------------------------------------------------------

# El interruptor en el comando de compilacion indica que se preservan los niveles jerarquicos en el 
# disenno. Ello permite que luego se pueda hacer una exploracion de planos de grupo y las jerarquias
#  se implementen como bloques de unidades funcionales (FUBs) en la implementacion fisica con ICC.



compile_ultra -no_auto_ungroup -exact_map > reports/compile.txt; 


remove_unconnected_ports [get_cells -regexp "inst_BS"];
remove_unconnected_ports [get_cells -regexp "inst_ALU/inst_BS"];
remove_unconnected_ports [get_cells -regexp "inst_ALU/inst_CSK"];
remove_unconnected_ports [get_cells -regexp "inst_ALU"];

# Lectura del saif, unicamente funcional en el modo topografico
if {[shell_is_in_topographical_mode]} {
#	read_saif -input "$PROY_HOME/front_end/$DESIGN_NAME.saif" \
 -instance_name $TEST_INST_NAME/$UUT_INST_NAME -target_instance $UUT_INST_NAME;
#Escribir la lista de nodos a nivel de compuertas (Gate Level Netlist) que se utiliza para:
#- Verificar el funcionamiento lógico del sistema digital después de la Síntesis RTL.
#- Como una de las entradas para el sintetizador físico (IC Compiler).

#read_saif -input top.saif -instance_name test_top -auto_map_names
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

#report_power -analysis_effort high > "$PROY_HOME_SYN/reports/$DESIGN_NAME\_syn_power.txt";
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
#write -format ddc -output "$TOP_FILE_DDC";
#write -format verilog -output "$TOP_FILE_SYN";
#Guardamos info de restricciones para leerlo en ICC

write_sdc "$TOP_FILE_SDC";

#Guardamos info de temporizado en sdf para simulaciones 

write_sdf "$TOP_FILE_SDF";

puts "RM-Info: Completed script [info script]\n";
