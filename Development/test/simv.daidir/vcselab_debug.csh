#!/bin/csh -f

cd /home/jaspal.singh/systemverilog/sv_project/AXI_VIP/Development/test

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/home/hitesh.patel/VCS_2020/work/vcs/R-2020.12-SP2/linux64/bin/vcselab $* \
    -o \
    simv \
    -nobanner \

cd -

