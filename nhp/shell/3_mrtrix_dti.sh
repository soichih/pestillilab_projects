#!/bin/bash

########### EDIT #####################
## define working directories
TOPDIR=/N/dc2/projects/lifebid/Rockefeller/working
SUBJ=quincy
MRTTRY=$TOPDIR/$SUBJ/mrtrix

## NEEDS:
## 1. dwi.mif
## 2. grads.b
## 3. mask.mif
## 4. wm_mask.mif

## convert files for MRTrix
mrconvert $TOPDIR/$SUBJ/dwi.nii.gz $MRTTRY/dwi.mif
mrconvert $TOPDIR/$SUBJ/wm.nii.gz $MRTTRY/wm.mif
mrconvert $TOPDIR/$SUBJt2_mask.nii.gz $MRTTRY/mask.mif

## fit diffusion model
dwi2tensor $MRTTRY/dwi.mif -grad $MRTTRY/grads.b $MRTTRY/dt.mif

## create FA image
tensor2FA $MRTTRY/dt.mif - | mrmult - $MRTTRY/mask.mif $MRTTRY/fa.mif

## create single fiber mask
erode $MRTTRY/mask.mif -npass 3 - | mrmult $MRTTRY/fa.mif - - | threshold - -abs 0.7 $MRTTRY/sf.mif

## create response numbers for CSD fit
estimate_response $MRTTRY/dwi.mif $MRTTRY/sf.mif -grad $MRTTRY/grads.b -lmax 8 $MRTTRY/response.txt

## fit csd model
csdeconv $MRTTRY/dwi.mif $MRTTRY/response.txt $MRTTRY/csd8.mif -grad $MRTTRY/grads.b -lmax 8 -mask $MRTTRY/mask.mif

# ## track a whole brain of fibers
# streamtrack SD_PROB $MRTTRY/csd8.mif $MRTTRY/mrtrix_csd8_curv-1_wholeBrain.tck \
#             -seed $MRTTRY/mask.mif -mask $MRTTRY/mask.mif -curvature 1 -grad $MRTTRY/grads.b \
#             -minlength 5 -number 10000 -maxnum 100000

##
## track ROI to ROI
##

# ## combine ROI files to seed
# mradd 2ROIseed.mif ROI1.mif ROI2.mif

# ## track fibers between ROIs
# streamtrack SD_PROB $MRTTRY/csd8.mif $MRTTRY/mtrix_csd8_curv-1_roi_to_roi.tck \ 
#     -seed 2ROIseed.mif -include ROI1.mif -include ROI2.mif -mask $MRTTRY/wm_mask.mif \ 
#     -curvature 1 -grad $MRTTRY/grads.b \
#     -number 10000 -maxnum 100000
