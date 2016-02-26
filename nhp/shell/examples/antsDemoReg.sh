#!/bin/bash

TOPDIR=/N/u/bcmcpher/Karst/nhp_reg
dim=3
m=bias2dwi.nii.gz 
f=t2.nii.gz

its=[15x50x15,1e-6,10]
smth=2x1x0
down=3x2x1

antsRegistration -d $dim  \
    --metric CC[$f,$m,1,4] \
    --transform SyN[0.1,3.0,0] \
    --convergence $its  \
    --smoothing-sigmas $smth  \
    --shrink-factors $down \
    --use-histogram-matching 0 \
    --write-composite-transform 0 --output [antsDemo_,antsDemo_diff.nii.gz,antsDemo_diff_inv.nii.gz] 

CreateWarpedGridImage $dim antsDemo_0InverseWarp.nii.gz antsDemo_grid.nii.gz 
#ConvertToJpg antsDemo_grid.nii.gz antsDemo_grid.png 
CreateJacobianDeterminantImage $dim antsDemo_0Warp.nii.gz antsDemo_jac.nii.gz 0 1
CreateJacobianDeterminantImage $dim antsDemo_0InverseWarp.nii.gz antsDemo_jac_inv.nii.gz 0 1
