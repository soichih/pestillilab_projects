#!/bin/bash

## Brent McPherson
## 20160226
## convert diffusion DICOMS to nifti and create b0 volume
##

## create default names files
dcm2nii dicom_folder/* 

## check what *.nii.gz are created
## may not compress - could just be *.nii

## *.nii.gz is the one I pulled and renamed
mv dicom_folder/*.nii.gz ./dwi_data.nii.gz

## split into separate volumes to get b0 file
fslsplit dwi_data.nii.gz

## make b0
cp vol0000.nii.gz t2.nii.gz

## OPTIONAL: remove split volumes
rm -f vol*.nii.gz

