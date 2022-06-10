#!/bin/csh -f

cd /home/sandip.mali/AXI_VIP/Development/src

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/home/hitesh.patel/VCS_2020/work/vcs/R-2020.12-SP2/linux64/bin/vcselab $* \
    -o \
    simv \
    -nobanner \

cd -

