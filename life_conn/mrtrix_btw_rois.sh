#!/bin/bash

## Brent McPherson 
## 20151117
## create 1000 fiber paths between each pair of FreeSurfer ROIs

## module calls
module unload mrtrix/0.3.12
module load mrtrix/0.2.12

## build path
SUBJ=105115
TOPDIR=/N/dc2/projects/lifebid/HCP/Brent
PRJDIR=$TOPDIR/vss-2016
OUTDIR=$PRJDIR/mrtrix
ROIDIR=$OUTDIR/rois
TCKDIR=$OUTDIR/tracks

##
## convert / create files
##

## convert dwi's 
# mrconvert $TOPDIR/$SUBJ/diffusion_data/dwi_data_b2000_aligned_trilin.nii.gz $OUTDIR/dwi_data_b2000_aligned_trilin_dwi.mif

## make mask from DWI data
# average $OUTDIR/dwi_data_b2000_aligned_trilin_dwi.mif -axis 3 - | threshold - - | median3D - - | median3D - $OUTDIR/dwi_data_b2000_aligned_trilin_brainmask.mif

## fit tensors
# dwi2tensor $OUTDIR/dwi_data_b2000_aligned_trilin_dwi.mif -grad $OUTDIR/dwi_data_b2000_aligned_trilin.b $OUTDIR/dwi_data_b2000_aligned_trilin_dt.mif 

## create FA image
# tensor2FA $OUTDIR/dwi_data_b2000_aligned_trilin_dt.mif - | mrmult - $OUTDIR/dwi_data_b2000_aligned_trilin_brainmask.mif $OUTDIR/dwi_data_b2000_aligned_trilin_fa.mif

## create eigenvector map
# tensor2vector $OUTDIR/dwi_data_b2000_aligned_trilin_dt.mif - | mrmult - $OUTDIR/dwi_data_b2000_aligned_trilin_fa.mif $OUTDIR/dwi_data_b2000_aligned_trilin_ev.mif

## convert wm mask
# mrconvert $TOPDIR/anatomy/$SUBJ/wm_mask.nii.gz $OUTDIR/dwi_data_b2000_aligned_trilin_wm.mif

## erodes brainmask - removes extreme artifacts (w/ high FA), creates FA image, AND single fiber mask 
# erode $OUTDIR/dwi_data_b2000_aligned_trilin_brainmask.mif -npass 3 - | mrmult $OUTDIR/dwi_data_b2000_aligned_trilin_fa.mif - - | threshold - -abs 0.7 $OUTDIR/dwi_data_b2000_aligned_trilin_sf.mif

##
## estimate fiber model
##

## estimates response function
# estimate_response $OUTDIR/dwi_data_b2000_aligned_trilin_dwi.mif $OUTDIR/dwi_data_b2000_aligned_trilin_sf.mif -lmax 10 -grad $OUTDIR/dwi_data_b2000_aligned_trilin.b $OUTDIR/dwi_data_b2000_aligned_trilin_response.txt

## does CSD for creating fiber maps
# csdeconv $OUTDIR/dwi_data_b2000_aligned_trilin_dwi.mif -grad $OUTDIR/dwi_data_b2000_aligned_trilin.b $OUTDIR/dwi_data_b2000_aligned_trilin_response.txt -lmax 10 -mask $OUTDIR/dwi_data_b2000_aligned_trilin_brainmask.mif $OUTDIR/CSD10.mif

## 
## create ROIs
##

## copy *smooth3mm.nii.gz files to $ROIDIR 
## find . -name "*_smooth3mm.nii.gz" | sed "s/_label_smooth3mm.nii.gz//g" | xargs -I {} mrconvert {}_label_smooth3mm.nii.gz {}.mif
## delete .nii.gz files

##
## create fibers between each pair of ROIs
##

set -- `find $ROIDIR -type f -name "*.mif" | sed 's#.*/##'`
## set files to be all rois - no path info
for a; do
    shift
    for b; do
        ## a/b are the files w/ extensions
 	## A/B are the files w/o extensions

 	A=`echo $a | sed 's/.mif//g'`
 	B=`echo $b | sed 's/.mif//g'`
 	printf "%s to %s\n" "$A" "$B"
	
	## create seed mask
	mradd $ROIDIR/$a $ROIDIR/$b $ROIDIR/seed_tmp.mif

        ## create a probabilistic lh tract between the two ROIs using CSD
 	streamtrack -seed $ROIDIR/seed_tmp.mif -mask $OUTDIR/dwi_data_b2000_aligned_trilin_brainmask.mif -grad $OUTDIR/dwi_data_b2000_aligned_trilin.b -include $ROIDIR/$a -include $ROIDIR/$b  SD_PROB $OUTDIR/CSD10.mif $TCKDIR/${A}_to_${B}.tck -number 1000 -maxnum 100000
	
	## clear out seed file...
	rm -f $ROIDIR/seed_tmp.mif

    done
done
