#!/bin/bash

## define working directories
TOPDIR=/N/dc2/projects/lifebid/Rockefeller/working
SUBJ=michel

## define file names based on file name stem
DWI=$TOPDIR/$SUBJ/dwi/dwi9_60dirs.nii.gz
ANAT=$TOPDIR/$SUBJ/t2.nii.gz
MASK=$TOPDIR/$SUBJ/t2_mask.nii.gz

BVALS=$TOPDIR/$SUBJ/bvals
BVECS=$TOPDIR/$SUBJ/bvecs

##
## FSL Anatomical Processing
##

## create generous t2 brain mask
#fslmaths t2.nii.gz -thr 300 -bin -kernel gauss 3 -fmean -thr 0.4 -bin -fillh t2_mask

## fit tensors
dtifit --data=$DWI --out=$TOPDIR/$SUBJ/fslfit --mask=$MASK --bvecs=$BVECS --bvals=$BVALS

