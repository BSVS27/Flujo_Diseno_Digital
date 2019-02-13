# TCL para DRC, LVS

set_physical_signoff_options -exec_cmd {icv} -drc_runset "$TECH_RUNSET_FILE" -mapfile "$TECH_GDS_MAP_FILE" -dp_hosts {zener1 zener2} -num_cpus 2
signoff_drc -show_stream_error_environment false -run_dir "$PROY_HOME_PHY/db/signoff_drc_run" -max_errors_per_rule 1000 -read_cel_views {*} -user_defined_options {-I /mnt/vol_NFS_Zener/tools/synopsys/pdks/xh018-ams/XFAB_snps_CustomDesigner_kit_v2_1_0/xh018/synopsys/v7_0/ICValidator/v7_0_3}
#set_physical_signoff_options -exec_cmd {icv} -drc_runset "$PROY_HOME_PHY/db/signoff_drc_run/xh018_1143_DRC_MET4_METMID_METTHK.rs" -mapfile "$PROY_HOME_PHY/db/signoff_drc_run/xh018_out.map" -dp_hosts {zener1 zener2} -num_cpus 2


# Para ver errores en celdas desconectadas

verify_pg_nets -error_cell error_power_plan
gui_set_pref_value -category layout -key enableEditingDRC -value {true}



#Corregir celdas o puertos desconectados con enrutado ECO

set_route_zrt_global_options -crosstalk_driven false -timing_driven falseset_route_zrt_track_options -crosstalk_driven false -timing_driven falseset_route_zrt_detail_options -timing_driven false

route_zrt_eco -max_detail_route_iterations 30

