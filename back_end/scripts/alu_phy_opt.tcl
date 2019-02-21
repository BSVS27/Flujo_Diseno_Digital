#################################################################################
# Title:		ac97_phy.tcl
# Description:	Script de sintesis fisica para IC Compiler
#				
# Dependencies: Ninguna.
# Project:		RISCV
# Author:		Reinaldo Castro González
# Institution:	Instituto Tecnológico de Costa Rica. DCILab.
# Date:			28 de Marzo de 2018
# Notes:		Basado en los scripts del Dr. Juan Agustín Rodríguez para la
#				integración del proyecto SiRPA. 2014
# Version:		1.1
# Revision:		28/05/2018 Original
#
#                       31/07/2018 ACR
#			Se ajustan directorios y variables para compartir con las usadas para la sintesis logica
#
###############################################################################################################.

#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Remover diseños anteriores
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
remove_design -designs
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Antes de iniciar el diseño es necesario contar con una carpeta milkywave en libs. 
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
source -echo -verbose "$PROY_HOME_PHY/scripts/crear_mw.tcl"
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se inicia el mapeo de saif para las estimaciónes de potencia.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
saif_map -start 
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Define los 1 o 0 logicos
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set mw_logic0_net VSS
set mw_logic1_net VDD
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se abre el archivo generado por DC_compiler guardado en la carpeta db en front end, se abre en formato ddc.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
import_designs -format ddc -top $TOP_MODULE $TOP_FILE_DDC;
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se abre el archivo generado por DC_compiler guardado en la carpeta db en front end, se abre en formato ddc.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
uniquify_fp_mw_cel 
link -force
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Nombra los voltajes de alimentación
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
derive_pg_connection -power_net VDD -power_pin vdd -ground_net VSS -ground_pin gnd
derive_pg_connection -power_net "VDD" -ground_net "VSS" -tie
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Este comando lo que hace es leer los archivos de restricciones de synopsys con los que trabajara.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
read_sdc -version Latest $TOP_FILE_SDC; 
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Para utilzar la infromación del SAIF en la síntesis física y el floorplan
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
reset_switching_activity
read_saif -input "$PROY_HOME/back_end/source/$DESIGN_NAME.saif" \
 -instance_name $TEST_INST_NAME/inst_top -auto_map_names;
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# El para aplicar la estrategia de diseño necesita conocer la unidad mínima de tile. En este caso se le da 
# especificando la tecnología con la que se trabaja hdll. 
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_fp_strategy -unit_tile_name "hdll";
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Activa unas optimizaciones al momento de virtual in-place optimization durante la colocación de celdas.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_fp_placement_strategy -virtual_IPO on
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# El siguiente comando genera el floorplan con la dimensiones indicadas en um.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
create_floorplan -core_utilization 0.7 -left_io2core 30 -bottom_io2core 30 -right_io2core 30 -top_io2core 30;
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Genera el placemente de las celdas. La bandera de timing habilita esta optimización y la otra bandera 
# pide que no se haga jerarquico
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
create_fp_placement -timing_driven -no_hier;
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# La herramienta hace un estudio de donde podrían ocurrir posibles congestiones y reordena las celdas ya colocadas
# para evitarlas.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
refine_placement -congestion_effort low;
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Confirma a la herramienta que este va ser el placement a usar
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
legalize_placement;
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# En esta parte se guarda el diseño logrado hasta el momento.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
save_mw_cel -as floorplan_ends;
copy_mw_cel -from  floorplan_ends -to floorplan_ends1;
close_mw_cel floorplan_ends;
close_mw_cel top;
open_mw_cel floorplan_ends1;
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se redefien los nombres de las fuentes, se hace por seguridad en caso de la que herramienta en algun momento se pierda
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
derive_pg_connection -power_net VDD -power_pin vdd -ground_net VSS -ground_pin gnd
derive_pg_connection -power_net VDD -power_pin vdd -ground_net VSS -ground_pin gnd -tie
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#El próximo comando lo que hace es setear una variable de **IC Compiler** que define el orden en que se hacen los straps. 
#Los straps son las líneas de vdd y tierra en donde se colocan las celdas para su alimentación. 
#Por default la herramienta inicia contruyendolos en capas de metal más externas hacia las más bajas, pero en algunos casos como este es necesario hacerlo de manera inversa. 
#Para ellos solo seteamos en true esta variable.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set pns_commit_lower_layer_first true
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#En los próximos comandos le define las restricciones que tiene la herramienta para generar el mallado de alimentacion
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_fp_rail_constraints -add_layer  -layer METTP -direction horizontal -max_strap 16 -min_strap 4 -min_width 2 -spacing 12
set_fp_rail_constraints -add_layer  -layer METTPL -direction vertical  -max_strap 16 -min_strap 4 -min_width 2 -spacing 12 
set_fp_rail_constraints  -set_ring -horizontal_ring_layer { METTP  } -vertical_ring_layer { METTPL } -extend_strap core_ring
set_fp_rail_constraints -set_global   -no_routing_over_hard_macros -no_routing_over_soft_macros
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#Permite a las standar cells a ser colocadas debajo de los pnets, verificando sus pines para evitar cortos con los pnets
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_pnet_options -partial {METTP METTPL}
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#Este comando alínea los straps de vdd y ground con los rieles de la celda en nivel más bajo de metal. 
#El comando trata de evitar que un strap de vdd caiga sobre un riel de ground de alguna celda o viceversa.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_fp_rail_strategy -align_strap_with_m1_rail true; 
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#Este comando sintetiza el power plan con las restricciones dadas
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
synthesize_fp_rail  -nets { VDD VSS } -voltage_supply 1.8 -synthesize_power_plan -power_budget 1000 -pad_masters { VDD VSS }  \
-use_pins_as_pads -use_strap_ends_as_pads 
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#Este comando confirma que el power nets generado esta bien y se usara.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
commit_fp_rail
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# El primero de estos 3 comandos mueve las vias al centro de las interconexiones de las alimentación hacia el centro,
#Los otros dos comandos conetan las celdas a los anillos y straps de alimentacion
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_preroute_advanced_via_rule -move_via_to_center
preroute_standard_cells -nets VDD -fill_empty_rows -remove_floating_pieces -connect both -extend_to_boundaries_and_generate_pins
preroute_standard_cells -nets VSS -fill_empty_rows -remove_floating_pieces -connect both -extend_to_boundaries_and_generate_pins
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#Se guarda el diseño que se lleva hasta ahora
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
save_mw_cel -as powerplan_rail_ends
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#Al momento de hacer los ruteos de la alimentación la herramienta pudo haber movido algunas celdas de donde estaban. 
#Por lo cual se vuelven a correr los comando de colocación y reordenamiento.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
create_fp_placement -timing_driven -no_hierarchy_gravity -incremental all;
refine_placement -congestion_effort high;
legalize_fp_placement;
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#Al momento de hacer los ruteos de la alimentación la herramienta pudo haber movido algunas celdas de donde estaban. 
#Por lo cual se vuelven a correr los comando de colocación y reordenamiento.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
preroute_standard_cells -nets VDD -fill_empty_rows -remove_floating_pieces -connect both; 
preroute_standard_cells -nets VSS -fill_empty_rows -remove_floating_pieces -connect both; 
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#Este comando ahora invoca la reglas de ruteo para las vías. Y se vuelve a guarda y cerrar el diseño
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_preroute_advanced_via_rule
save_mw_cel -as powerplan_rail_ends
close_mw_cel floorplan_ends1
open_mw_cel powerplan_rail_ends
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
#El primero de estos 3 comandos, crea un prefijo utilizado durante la compilación, el segundo hace un placemente, ruteo y optimización de manera simultanea. 
#Y el último confirma el ordenamiento.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set compile_instance_name_prefix place
place_opt -effort high
legalize_placement -effort medium
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Ahora se generan algunos reportes.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
create_qor_snapshot -timing -constraint -congestion -name Place
report_qor_snapshot  > $PROY_HOME_PHY/reports/place.qor_snapshot.rpt
report_qor > $PROY_HOME_PHY/reports/place.qor
report_constraint -all > $PROY_HOME_PHY/reports/place.con
report_timing -capacitance -transition_time -input_pins -nets -delay_type max > $PROY_HOME_PHY/reports/place.max.tim
report_timing -capacitance -transition_time -input_pins -nets -delay_type min > $PROY_HOME_PHY/reports/place.min.tim
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Ahora se ingresan las celdas de relleno para los espacios vacíos con el fin de dar estabilidad al circuito. 
#Esto se va hacer 2 veces para que al momento de rutear las tenga en consideración 
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
insert_stdcell_filler  -cell_with_metal FEED25HDLL -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED15HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED10HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED7HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal  FEED5HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED3HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED2HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED1HDLL -connect_to_power VDD -connect_to_ground VSS
derive_pg_connection -power_net "VDD" -ground_net "VSS"
derive_pg_connection -power_net "VDD" -ground_net "VSS" -tie
preroute_standard_cells -nets VDD -fill_empty_rows -remove_floating_pieces -connect both;
preroute_standard_cells -nets VSS -fill_empty_rows -remove_floating_pieces -connect both;
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se guarda el diseño
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
save_mw_cel -as place_ends
close_mw_cel powerplan_rail_ends
open_mw_cel place_ends
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Cargado de la s reglas de antenna, dando su ubicanción y instanciandolas en la herramienta
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
source $TECH_ROOT/xh018/synopsys/v6_3/techMW/v6_3_1_1/xh018-synopsys-techMW-v6_3_1_1/xx018.ante.rules
report_antenna_rules
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# En esta parte se le da las opciones al enrutador para que pueda hacer su trabajo. La segunda instruccion hace 
# una estimacion de ruteo del diseño. El tercero hace una optimizaciones en tiempo.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_route_zrt_common_options -plan_group_aware all_routing
route_zrt_global -effort ultra
optimize_fp_timing
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se definen varias opciones del enrutador
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_route_zrt_common_options -default true
set_route_zrt_global_options -timing_driven true
set_route_zrt_global_options -effort high
set_route_zrt_track_options -timing_driven true
set_route_zrt_detail_options -drc_convergence_effort_level high
set_buffer_opt_strategy -effort low
set_route_zrt_detail_options -default_gate_size 0.1
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Ahora se ejecutara la síntesis de arbol de reloj.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_clock_tree_options -clock_trees clk -insert_boundary_cell true -ocv_clustering true -buffer_relocation true -buffer_sizing true -gate_relocation true -gate_sizing true
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# El primer y segundo comando habilitan a la herramienta a revisar el arbol de reloj generado. El tercero ejecuta el ruteo del reloj. 
#Al final se hace un guardado del diseño
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set cts_use_debug_mode true
set cts_do_characterization true
clock_opt -fix_hold_all_clocks
save_mw_cel -as clock_tree_placed
close_mw_cel place_ends
open_mw_cel clock_tree_placed
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# El primer comando le dice a la herramienta que no toque el reloj ya generado para el diseño. Y los siguiente comandos 
#hacen un proceso iterativo para conectar todas las celdas optimizando y liberando las congestiones. Por último
# revisa las reglas de antena.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_dont_touch_network clk
route_zrt_auto -max_detail_route_iterations 40 ; #40
verify_zrt_route
psynopt -congestion
route_zrt_auto -max_detail_route_iterations 40; #40
route_opt -incremental
route_zrt_detail -incremental true -max_number_iterations 40; #40
focal_opt -drc_nets all
remove_zrt_redundant_shapes -report_changed_nets true
verify_zrt_route -antenna true
verify_zrt_route -antenna true  > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_drc_route.txt"
verify_pg_nets > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_pg_nets.txt"
verify_pg_nets -pad_pin_connection all > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_pg_nets_pad_pin_connection.txt"
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se guarda el diseño en verilog
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
write_verilog "$PROY_HOME_PHY/db/$DESIGN_NAME\_phy_sim.v"
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se realizan los pasos de seguridad en caso de que al rutear el diseño hubiera cambiado algo.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
derive_pg_connection -power_net VDD -power_pin vdd -ground_net VSS -ground_pin gnd
derive_pg_connection -power_net VDD -power_pin vdd -ground_net VSS -ground_pin gnd -tie
set_preroute_drc_strategy -max_layer MET1
preroute_standard_cells -nets VDD -fill_empty_rows -remove_floating_pieces -connect both;
preroute_standard_cells -nets VSS -fill_empty_rows -remove_floating_pieces -connect both;
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# En esta parte hace dos rellenos de NWELL en aquellos lugares donde quedaron huecos que lo necesitan.
# y el otro pone rellenos de metal a los metales que incumple con las reglas.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
insert_well_filler -layer NWELL -higher_edge max -lower_edge min
insert_metal_filler -from_metal 2 -to_metal 6
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se vuelve a guardar el diseño
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
save_mw_cel -as routed_cell
close_mw_cel clock_tree_placed
open_mw_cel routed_cell
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se vuelven a colocar las celdas de relleno por si el ruteo removio alguna. Y a correr otros pasos ya ejecutados 
# por motivos de seguridad.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
insert_stdcell_filler  -cell_with_metal FEED25HDLL -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED15HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED10HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED7HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal  FEED5HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED3HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED2HDLL  -connect_to_power VDD -connect_to_ground VSS
insert_stdcell_filler  -cell_with_metal FEED1HDLL -connect_to_power VDD -connect_to_ground VSS
derive_pg_connection -power_net "VDD" -ground_net "VSS"
derive_pg_connection -power_net "VDD" -ground_net "VSS" -tie
preroute_standard_cells -nets VDD -fill_empty_rows -remove_floating_pieces -connect both; 
preroute_standard_cells -nets VSS -fill_empty_rows -remove_floating_pieces -connect both; 
insert_well_filler -layer NWELL -higher_edge max -lower_edge min
insert_metal_filler -from_metal 2 -to_metal 6
derive_pg_connection -power_net VDD -power_pin vdd -ground_net VSS -ground_pin gnd
derive_pg_connection -power_net VDD -power_pin vdd -ground_net VSS -ground_pin gnd -tie
set_preroute_drc_strategy -max_layer MET1
preroute_standard_cells -nets VDD -fill_empty_rows -remove_floating_pieces -connect both;
preroute_standard_cells -nets VSS -fill_empty_rows -remove_floating_pieces -connect both; 
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se hacen verificaciones del diseño y se guarda.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
verify_pg_nets
verify_pg_nets -pad_pin_connection all
check_mv_design -verbose > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_chk_phy.txt"
save_mw_cel routed_cell
save_mw_cel routed_cell.FILL
close_mw_cel top
save_mw_cel -as top
save_mw_cel -as top.FILL
close_mw_cel routed_cell
open_mw_cel -readonly top
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se escribe un verilog del diseño generado.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
write_verilog -pg  \
             -unconnected_ports \
             -no_cover_cells \
             -no_io_pad_cells \
             -no_flip_chip_bump_cells\
             -supply_statement  none $TOP_FILE_PHY
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Sehace la extraccion rc de parasitancias.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
extract_rc
write_parasitics -output $TOP_FILE_PHY_SPEF
write_sdc $TOP_FILE_PHY_SDC
write_sdf $TOP_FILE_PHY_SDF
write_def -output $TOP_FILE_PHY_DEF
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se genera el GDS
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
set_write_stream_options \
             -child_depth 99 \
             -output_filling fill \
             -output_pin {text geometry} \
             -map_layer $TECH_GDS_MAP_FILE \
             -pin_name_mag 0.5 \
             -output_polygon_pin \
             -keep_data_type

current_design top
write_stream  -cells top.CEL -format gds $TOP_FILE_GDS
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
# Se generan los reportes de area y consumo.
#----------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------
report_power -analysis_effort high > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_power.txt"
report_area > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_area.txt"
report_cell > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_cell.txt"
report_qor > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_qor.txt"
report_timing > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_timing.txt"
report_port > "$PROY_HOME_PHY/reports/$DESIGN_NAME\_phy_port.txt"
