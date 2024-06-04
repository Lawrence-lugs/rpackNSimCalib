#SYNOPSYS Environment Variables
#License
export LM_LICENSE_FILE=27020@10.158.16.12
#VCS
export VCS_HOME=/cad/tools/synopsys/vcs/T-2022.06-SP2
export VCS_BIN=/cad/tools/synopsys/vcs/T-2022.06-SP2/bin
#SYN
export SYN_BIN=/cad/tools/synopsys/syn/U-2022.12/bin
#LC
export SYNOPSYS_LC_ROOT=/cad/tools/synopsys/lc/T-2022.03-SP5
export LC_BIN=/cad/tools/synopsys/lc/T-2022.03-SP5/bin
#PT
export PT_BIN=/cad/tools/synopsys/prime/U-2022.12/bin
#ICC2
export ICC_BIN=/cad/tools/synopsys/icc2/T-2022.03-SP5/bin
#Path
export PATH=${PATH}:${VCS_BIN}:${SYN_BIN}:${LC_BIN}:${PT_BIN}:${ICC_BIN}

#LD library path
export LD_LIBRARY_PATH=~/miniforge3/envs/lawenv/lib:$LD_LIBRARY_PATH