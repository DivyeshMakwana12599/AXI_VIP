#!/bin/csh -f

cd /home/divyesh.makwana1/AXI_VIP/Development/tb

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/home/hitesh.patel/VCS_2020/work/vcs/R-2020.12-SP2/linux64/bin/vcselab $* \
    -o \
    simv \
    -nobanner \

cd -

