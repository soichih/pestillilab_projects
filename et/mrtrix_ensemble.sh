#!/bin/bash
## Ensemble tractogrpahy
## 
## This shell script uses mrtrix/0.2.12 to run a series of tractography methods using both probabilistic
## and deterministic tractography based on the tensor model or on constrained spherical deconvolution. 
##
## Brent McPherson and Franco Pestilli Indiana University 2016

## load necessary modules on the Karst cluster environment
module unload mrtrix/0.3.12
module load mrtrix/0.2.12

## The script requires a single input tha tis the folder name for the subject that needs to be processed
## The corrent version of the script handles only data on the local Indiana University Cluster Systems
## Under the project lifebid. There are two current data sets there the HCP and STN96
SUBJ=$1

## Set paths to diffusion data directories
## DWIFILENAME=run01_fliprot_aligned_trilin
## TOPDIR=/N/dc2/projects/lifebid/2t1/predator/$SUBJ

DWIFILENAME=dwi_data_b2000_aligned_trilin
TOPDIR=/N/dc2/projects/lifebid/2t1/HCP/$SUBJ

ANATDIR=$TOPDIR/anatomy
OUTDIR=$TOPDIR/fibers

## Number of fibers requested and max number attempted to hit the number.
NUMFIBERS=500000
MAXNUMFIBERSATTEMPTED=1500000

##
echo 
echo Performing preprocessing of data before starting tracking...
echo 
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
echo DONE performing preprocessing of data before starting tracking...
##

##
echo START tracking...
##
streamtrack DT_STREAM $OUTDIR/${DWIFILENAME}_dwi.mif \
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

##
echo DONE tracking. Exiting Ensebmle Tracking Script
##

