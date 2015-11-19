#!/bin/bash

#PBS -l nodes=1:ppn=1,walltime=2:00:00
#PBS -n mrt-fiber-roi

## Brent McPherson
## 20151118
## batch submission script to Karst
##

module unload mrtrix
module load mrtrix/0.2.12

## variables passed as arguments
ROIDIR=$1
OUTDIR=$2
TCKDIR=$3
a=$4
b=$5
A=$6
B=$7

## create seed mask specific to ROIs
mradd $ROIDIR/$a $ROIDIR/$b $ROIDIR/$A-$B-seed.mif

## track b/w ROIs
streamtrack -seed $ROIDIR/seed_tmp.mif -mask $OUTDIR/dwi_data_b2000_aligned_trilin_brainmask.mif -grad $OUTDIR/dwi_data_b2000_aligned_trilin.b -include $ROIDIR/$a -include $ROIDIR/$b  SD_PROB $OUTDIR/CSD10.mif $TCKDIR/${A}_to_${B}.tck -number 1000 -maxnum 100000
	
## clear out seed file...
rm -f $ROIDIR/$A-$B-seed.mif
