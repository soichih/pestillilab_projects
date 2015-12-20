#!/bin/bash

export TOPDIR=/N/dc2/projects/lifebid/HCP/Brent/vss-2016/pestillilab_projects/life_conn
export SUBJ=MP_96dirs_b2000_1p5iso

#PBS -N EnsembleMrtrix
#PBS -l walltime=20:00:00
#PBS -l nodes=1:ppn=16
#PBS -k oe
#PBS -o $TOPDIR/logs/$SUBJ.olog
#PBS -e $TOPDIR/logs/$SUBJ.error
#PBS -M bcmcpher@iu.edu
#PBS -V

## -V exports default environment variables
bash $TOPDIR/mrtrix_ensemble.sh $SUBJ