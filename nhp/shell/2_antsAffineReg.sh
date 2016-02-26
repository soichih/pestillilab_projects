#!/bin/bash


## define the paths to files
TOPDIR=/N/dc2/projects/lifebid/Rockefeller/working
SUBJ=quincy #michel

## Check how rotated is the T1 (anatomical space) with respect to the T2 (diffusion psace)
## You migh need to manually rotate antsAN4_Segmentation0N4.nii.gz, as ants migh not be able to adjust extreme rotations

## michel angle rotations (freeview)
# 180 degreez Z

## quincy angle rotations (freeview)
# 90 degrees X
# 25 degrees Z

## make a copy of t1 for manual reorientation
cp $TOPDIR/$SUBJ/antsAN4_Segmentation0N4.nii.gz $TOPDIR/$SUBJ/t1_rotate.nii.gz
cp $TOPDIR/$SUBJ/wm.nii.gz $TOPDIR/$SUBJ/wm_rotate.nii.gz

echo ""
echo "Make sure the T1 is in the same rough orientation as the T2."
echo "Be sure to rotate any images in T1 space you want in T2 space the same way."
echo ""

## open freeview to check rough orientation of images, save file if you apply any rotation
freeview -v t1_rotate.nii.gz -v wm_rotate.nii.gz -v t2.nii.gz

## define input images for ANTs
## For Michel mov needed to be rotated manually to match t2 orientation
#mov=$TOPDIR/$SUBJ/antsAN4_Segmentation0N4.nii.gz
mov=$TOPDIR/$SUBJ/t1_rotate.nii.gz
fix=$TOPDIR/$SUBJ/t2.nii.gz

## hardcode some arguments
dim=3
op=$TOPDIR/$SUBJ/ants_bias2dwi_

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

CreateWarpedGridImage $dim ${op}1InverseWarp.nii.gz ${op}grid.nii.gz 
ConvertToJpg ${op}_grid.nii.gz ${op}_grid.png 
CreateJacobianDeterminantImage $dim ${op}1Warp.nii.gz ${op}jac.nii.gz 0 1
CreateJacobianDeterminantImage $dim ${op}1InverseWarp.nii.gz ${op}jac_inv.nii.gz 0 1

## example of applying ANTs transform to an image 
antsApplyTransforms -d 3 -i $TOPDIR/$SUBJ/wm_rotate.nii.gz -r $TOPDIR/$SUBJ/t2.nii.gz -o $TOPDIR/$SUBJ/ants_warp_wm.nii.gz -t ${op}1Warp.nii.gz ${op}0GenericAffine.mat -n NearestNeighbor #try with and without, maybe better without




