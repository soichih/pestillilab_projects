#!/bin/bash

#######   EDIT  #######
## define the paths to files
TOPDIR=/N/dc2/projects/lifebid/Rockefeller/working
SUBJ=quincy

## define the files
t1=$TOPDIR/$SUBJ/t1.nii.gz 
t1mask=$TOPDIR/$SUBJ/t1_mask.nii.gz
t2=$TOPDIR/$SUBJ/t2.nii.gz
#t2mask=$TOPDIR/$SUBJ/t2_mask.nii.gz
prefixOut=antsAN4_

#######  RARELY EDIT  #######
## run bias correction on T1
$TOPDIR/bin/antsAtroposN4.sh -d 3 -a $t1 -x $t1mask -m 10 -n 20 -c 4 -o $TOPDIR/$SUBJ/$prefixOut


## run bias correction on T2 and creates a good T2
## create a crappy T2 mask
fslmaths $TOPDIR/$SUBJ/t2.nii.gz -thr 300 -bin -kernel gauss 3 -fmean -thr 0.3 -bin -fillh $TOPDIR/$SUBJ/t2_mask_tmp

## run bias correction on T2
$TOPDIR/bin/antsAtroposN4.sh -d 3 -a $t2 -x $TOPDIR/$SUBJ/t2_mask_tmp.nii.gz -m 10 -n 20 -c 4 -o $TOPDIR/$SUBJ/antsAN4_T2_

## create a goos T2 mask
fslmaths $TOPDIR/$SUBJ/antsN4_T2_Segmentation.nii.gz -thr 2 -bin -fillh $TOPDIR/$SUBJ/t2_mask
