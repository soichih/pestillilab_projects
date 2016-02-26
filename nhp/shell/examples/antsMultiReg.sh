#!/bin/bash

## define the paths to files
TOPDIR=/N/dc2/projects/lifebid/Rockefeller/working
SUBJ=michel

## define input images for ANTs
mov=$TOPDIR/$SUBJ/antsAN4_Segmentation0N4.nii.gz
fix=$TOPDIR/$SUBJ/t2.nii.gz

## hardcode some arguments
dim=3
op=$TOPDIR/$SUBJ/test_ants_

## apply iterative transformations all calculated in ANTs for single resampling
antsRegistration -d $dim \
    --initial-moving-transform [$fix,$mov,1] \
    --initialize-transforms-per-stage 1 \
    --use-estimate-learning-rate-once 1 \
    --use-histogram-matching 0 \
    --collapse-output-transforms 1 \
    --output [${op},${op}diff.nii.gz,${op}inv.nii.gz] \
    --metric MI[$fix,$mov,1,32,Regular,0.25] \
    --transform rigid[0.1] \
    --convergence [1000x500x250x100,1.e-7,20] \
    --smoothing-sigmas 4x3x2x1vox \
    --shrink-factors 12x8x4x2 \
    --metric CC[$fix,$mov,1,4] \
    --transform affine[0.1] \
    --convergence [1000x500x250x100,1.e-7,20] \
    --smoothing-sigmas 4x3x2x1vox \
    --shrink-factors 12x8x4x2 \
    --metric CC[$fix,$mov,1,4] \
    --transform SyN[0.1,3.0,0] \
    --convergence [150x150x75x50x20,1e-7,20] \
    --smoothing-sigmas 5x3x2x1x0vox \
    --shrink-factors 10x6x4x2x1 \

# CreateWarpedGridImage $dim ${op}_0InverseWarp.nii.gz ${op}_grid.nii.gz 
# #ConvertToJpg ${op}_grid.nii.gz ${op}_grid.png 
# CreateJacobianDeterminantImage $dim ${op}_0Warp.nii.gz ${op}_jac.nii.gz 0 1
# CreateJacobianDeterminantImage $dim ${op}_0InverseWarp.nii.gz ${op}_jac_inv.nii.gz 0 1
