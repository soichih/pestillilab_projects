#!/bin/bash

dim=3
mov=t1_rotate.nii.gz
fix=t2.nii.gz
op=test02_

## apply iterative transformations all calculated in ANTs for single resampling
antsRegistration -d $dim \
    --initial-moving-transform [$fix,$mov,1] \
    --use-estimate-learning-rate-once 1 \
    --use-histogram-matching 0 \
    --collapse-output-transforms 1 \
    --output [${op},${op}diff.nii.gz,${op}inv.nii.gz] \
    --metric mattes[$fix,$mov,1,32,regular,0.1] \
    --transform affine[0.1] \
    --convergence [1000x500x250x100,1.e-8,20] \
    --smoothing-sigmas 4x3x2x1vox \
    --shrink-factors 12x8x4x2 \
    --metric CC[$fix,$mov,1,4] \
    --transform SyN[0.1,3.0,0] \
    --convergence [150x150x150,1e-7,10] \
    --smoothing-sigmas 2x1x0vox \
    --shrink-factors 3x2x1 \

# CreateWarpedGridImage $dim ${op}_0InverseWarp.nii.gz ${op}_grid.nii.gz 
# #ConvertToJpg ${op}_grid.nii.gz ${op}_grid.png 
# CreateJacobianDeterminantImage $dim ${op}_0Warp.nii.gz ${op}_jac.nii.gz 0 1
# CreateJacobianDeterminantImage $dim ${op}_0InverseWarp.nii.gz ${op}_jac_inv.nii.gz 0 1

##
## move wm mask and activation maps
##

## NEED NEAREST NEIGHBOR INTERPOLATION?

#antsApplyTransforms -d 3 -i wm_rotate.nii.gz -r t2.nii.gz -o ants_warp_wm.nii.gz -t ants_regtest_1Warp.nii.gz ants_regtest_0GenericAffine.mat

#antsApplyTransforms -d 3 -i tmap_right_left_rotate.nii.gz -r t2.nii.gz -o ants_warp_lr.nii.gz -t ants_regtest_1Warp.nii.gz ants_regtest_0GenericAffine.mat

#antsApplyTransforms -d 3 -i tmap_stim_fix_rotate.nii.gz -r t2.nii.gz -o ants_warp_stim.nii.gz -t ants_regtest_1Warp.nii.gz ants_regtest_0GenericAffine.mat




## original parameters
# antsRegistration -d $dim \
#     --initial-moving-transform [$fix,$mov,1] \
#     --metric mattes[$fix,$mov,1,32,regular,0.1] \
#     --transform affine[0.1] \
#     --convergence [500x500x50,1.e-8,20] \
#     --smoothing-sigmas 4x2x1vox \
#     --shrink-factors 3x2x1 \
#     --metric CC[$fix,$mov,1,4] \
#     --transform SyN[0.1,3.0,0] \
#     --convergence [150x150x150,1e-7,10] \
#     --smoothing-sigmas 2x1x0vox \
#     --shrink-factors 3x2x1 \
#     --use-estimate-learning-rate-once 1 \
#     --use-histogram-matching 0 \
#     --collapse-output-transforms 1 \
#     --output [${op},${op}diff.nii.gz,${op}inv.nii.gz]