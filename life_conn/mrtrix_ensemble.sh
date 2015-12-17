#!/bin/bash

## Brent McPherson 
## 20151218
## create an ensemble of whole brain fibers

## module calls
module unload mrtrix/0.3.12
module load mrtrix/0.2.12

## build paths and file names

SUBJ=$1

DWIFILENAME=run02_fliprot_aligned_trilin
TOPDIR=/N/dc2/projects/lifebid/2t1/predator/$SUBJ

## DWIFILENAME=dwi_data_b2000_aligned_trilin
## TOPDIR=/N/dc2/projects/lifebid/2t1/HCP/$SUBJ

ANATDIR=/N/dc2/projects/lifebid/2t1/predator/$SUBJ/anatomy
OUTDIR=$TOPDIR/fibers

NUMFIBERS=500000
MAXNUMFIBERSATTEMPTED=1000000

##
## preprocessing
##

## convert wm mask
mrconvert $ANATDIR/wm_mask.nii.gz $OUTDIR/${DWIFILENAME}_wm.mif

## convert dwi's 
mrconvert $TOPDIR/diffusion_data/$DWIFILENAME.nii.gz $OUTDIR/${DWIFILENAME}_dwi.mif

## make mask from DWI data
average $OUTDIR/${DWIFILENAME}_dwi.mif -axis 3 - | threshold - - | median3D - - | median3D - $OUTDIR/${DWIFILENAME}_brainmask.mif

## fit tensors
dwi2tensor $OUTDIR/${DWIFILENAME}_dwi.mif -grad $OUTDIR/$DWIFILENAME.b $OUTDIR/${DWIFILENAME}_dt.mif 

## create FA image
tensor2FA $OUTDIR/${DWIFILENAME}_dt.mif - | mrmult - $OUTDIR/${DWIFILENAME}_brainmask.mif $OUTDIR/${DWIFILENAME}_fa.mif

## create eigenvector map
tensor2vector $OUTDIR/${DWIFILENAME}_dt.mif - | mrmult - $OUTDIR/${DWIFILENAME}_fa.mif $OUTDIR/${DWIFILENAME}_ev.mif

## # Estimate deconvolution kernel: Estimate the kernel for deconvolution, using voxels with highest FA
## erodes brainmask - removes extreme artifacts (w/ high FA), creates FA image, AND single fiber mask 
erode $OUTDIR/${DWIFILENAME}_brainmask.mif -npass 3 - | mrmult $OUTDIR/${DWIFILENAME}_fa.mif - - | threshold - -abs 0.7 $OUTDIR/${DWIFILENAME}_sf.mif

## estimates response function
estimate_response $OUTDIR/${DWIFILENAME}_dwi.mif $OUTDIR/${DWIFILENAME}_sf.mif -lmax 6 -grad $OUTDIR/$DWIFILENAME.b $OUTDIR/${DWIFILENAME}_response.txt
## # End estimation of deconvolution kernel

## Perform CSD in each white matter voxel
for i_lmax in 2 4 6 8 10 12; do
    csdeconv $OUTDIR/${DWIFILENAME}_dwi.mif -grad $OUTDIR/$DWIFILENAME.b $OUTDIR/${DWIFILENAME}_response.txt -lmax $i_lmax -mask $OUTDIR/${DWIFILENAME}_brainmask.mif $OUTDIR/${DWIFILENAME}_lmax${i_lmax}.mif
done 

##
## tracking
##

streamtrack DT_STREAM $OUTDIR/${DWIFILENAME}_dt.mif \
                      $OUTDIR/${DWIFILENAME}_wm_tensor-$NUMFIBERS.tck \
                -seed $OUTDIR/${DWIFILENAME}_wm.mif \ 
                -mask $OUTDIR/${DWIFILENAME}_wm.mif \
                -grad $OUTDIR/${DWIFILENAME}.b \
	      -number $NUMFIBERS \
              -maxnum $MAXNUMFIBERSATTEMPTED

## loop over tracking and lmax
for c in SD_STREAM SD_PROB; do
    for d in 2 4 6 8 10 12; do
	
	streamtrack $c $OUTDIR/${DWIFILENAME}_lmax${d}.mif \
	               $OUTDIR/${DWIFILENAME}_csd_lmax${d}_wm_${c}-$NUMFIBERS.tck \
                 -seed $OUTDIR/${DWIFILENAME}_wm.mif \
		 -mask $OUTDIR/${DWIFILENAME}_wm.mif \
                 -grad $OUTDIR/$DWIFILENAME.b \
               -number $NUMFIBERS \
	       -maxnum $MAXNUMFIBERSATTEMPTED

    done
done

