set_app_var search_path "$search_path mapped lib cons rtl"

set_app_var target_library /cad/tools/libraries/dwc_logic_in_gf22fdx_sc7p5t_116cpp_base_csc20l/GF22FDX_SC7P5T_116CPP_BASE_CSC20L_FDK_RELV02R80/model/timing/db/GF22FDX_SC7P5T_116CPP_BASE_CSC20L_TT_0P80V_0P00V_0P00V_0P00V_25C.db

set_app_var link_library "* $target_library"

analyze -format sverilog ../rtl/mac_engine.sv

elaborate mac_engine

link

source timing.con
check_timing
compile_ultra -no_autoungroup

report_area > reports/area.txt
report_timing > reports/timing.txt
report_power > reports/power.txt
report_constraint -all_violators > reports/constraint.txt

change_names -rules verilog -hierarchy
write_file -format verilog -hierarchy -output ../mapped/mac_engine_mapped.v
write_file -format ddc -hierarchy -output ../mapped/mac_engine_mapped.ddc
write_sdf ../mapped/mac_engine_mapped.sdf
write_sdc ../mapped/mac_engine_mapped.sdc