#!/bin/bash
## Ensemble tractography cadidate fascicles generation script.
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

## HCP dataset
DWIFILENAME=dwi_data_b3000_aligned_trilin
TOPDIR=/N/dc2/projects/lifebid/2t1/HCP/$SUBJ

## STN96 dataset
ANATDIR=$TOPDIR/anatomy/
OUTDIR=$TOPDIR/fibers_new

mkdir -v $OUTDIR

## Number of fibers requested and max number attempted to hit the number.
NUMFIBERS=500000
MAXNUMFIBERSATTEMPTED=1000000

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
## echo DONE Lmax=$i_lmax 
done 

##
echo DONE performing preprocessing of data before starting tracking...
##

##
echo START tracking...
##
##echo tracking Deterministic Tensorbased
for i_track in 01 02 03 04 05 06 07 08 09 10; do
streamtrack DT_STREAM $OUTDIR/${DWIFILENAME}_dwi.mif $OUTDIR/${DWIFILENAME}_wm_tensor-NUM${i_track}-$NUMFIBERS.tck -seed $OUTDIR/${DWIFILENAME}_wm.mif -mask $OUTDIR/${DWIFILENAME}_wm.mif -grad $OUTDIR/${DWIFILENAME}.b -number $NUMFIBERS -maxnum $MAXNUMFIBERSATTEMPTED
done

for i_track in 01 02 03 04 05 06 07 08 09 10; do
## loop over tracking and lmax
for i_tracktype in SD_STREAM SD_PROB; do
##
##echo Tracking $i_tracktype Deterministic=1 Probabilistic=2 CSD-based
##
    for i_lmax in 2 4 6 8 10 12; do
	##echo Tracking CSD-based Lmax=$i_lmax
	streamtrack $i_tracktype $OUTDIR/${DWIFILENAME}_lmax${i_lmax}.mif   $OUTDIR/${DWIFILENAME}_csd_lmax${i_lmax}_wm_${i_tracktype}-NUM${i_track}-$NUMFIBERS.tck -seed $OUTDIR/${DWIFILENAME}_wm.mif  -mask $OUTDIR/${DWIFILENAME}_wm.mif  -grad $OUTDIR/$DWIFILENAME.b -number $NUMFIBERS -maxnum $MAXNUMFIBERSATTEMPTED
    done
##
##echo DONE Tracking $i_tracktype Deterministic=1 Probabilistic=2 CSD-based
##
done
done
##
echo DONE tracking. Exiting Ensemble Tracking Candidate Fascicle Generation Script
##

