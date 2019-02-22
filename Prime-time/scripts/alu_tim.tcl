set PROY_HOME "/mnt/vol_NFS_Zener/WD_ESPEC/moviedo/Flujo_Diseno_Digital-master";
source $PROY_HOME/common_setup.tcl;
source $PROY_HOME/user_setup.tcl;

#Se configuran las bibliotecas de las que se van a utilizar las celdas
set search_path "$PROY_HOME_SYN";# El comando siguente concatena al search path los directorios listados
set search_path [concat $search_path $ADDITIONAL_SEARCH_PATH];
set symbol_library "$SYMBOL_LIBRARY_FILES";
set target_library "$TARGET_LIBRARY_FILES";
set synthetic_library "dw_foundation.sldb";
set link_library "* $target_library $symbol_library $synthetic_library $ADDITIONAL_LINK_LIB_FILES";


# Leer el archivo de verilog obtenido al final de la implementación física (alu_phy.v)
#==========================================================================================================
read_verilog ../back_end/source/alu_phy.v
#==========================================================================================================

#Definir el módulo principal
#==========================================================================================================
current_design top
#==========================================================================================================

#Leer las capacitancias parásitas máximas
#==========================================================================================================
read_parasitics -format SPEF ../back_end/db/alu_phy.spef.max
#==========================================================================================================

#Leer las especificaciones de temporizado
#==========================================================================================================
read_sdc ../back_end/db/alu_phy.sdc
#==========================================================================================================

#Generar reportes de temporizado
#==========================================================================================================
report_timing -from [all_inputs] -to [all_registers -data_pins] -max_paths 40 > reports/entrada_registro.txt
report_timing -from [all_register -clock_pins] -to [all_registers -data_pins] -max_paths 40 > reports/registro_registro.txt
report_timing -from [all_register -clock_pins] -to [all_outputs] -max_paths 40 > reports/registro_salida.txt
#==========================================================================================================

#Leer las capacitancias parásitas mínimas
#read_parasitics -format SPEF ../back_end/db/alu_phy.spef.min

#Generar el reporte de temporizado de registro a registro con el tiempo de transición y la capacitancia
#==========================================================================================================
report_timing -transition_time -capacitance -nets -input_pins -from [all_registers -clock_pins] -to [all_registers -data_pins] > reports/criticas_tran_cap.txt
#==========================================================================================================

