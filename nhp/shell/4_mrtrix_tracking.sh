#!/bin/bash

## Brent McPherson & Ilaria Sani
## 20160224
## do a bunch of fiber tracking
##

## track a whole brain of fibers
streamtrack SD_PROB csd8.mif test_prob_c1.tck \
            -seed fa_wm_mask.mif -mask fa_wm_mask.mif -grad grads.b \
            -number 50000 -maxnum 500000 \ 
            -curvature 1 -minlength 5 

streamtrack SD_STREAM csd8.mif test_det_c1.tck \
            -seed fa_wm_mask.mif -mask fa_wm_mask.mif -grad grads.b \
            -number 50000 -maxnum 500000 \ 
            -curvature 1 -minlength 5 

## ROI to ROI tracking
#mradd merged_rois.mif ROI1.mif ROI2.mif
#streamtrack SD_PROB csd8.mif whole_exlcuding.tck \
#            -seed wm_mask.mif -mask wm_mask.mif -grad grads.b \
#            -exclude merged_rois.mif \
#            -number 50000 -maxnum 500000 \ 
#            -curvature 1 -minlength 5 
#streamtrack SD_PROB csd8.mif ROI2ROI.tck \
#            -seed merged_rois.mif -mask wm_mask.mif -grad grads.b \
#            -include ROI1.mif -include ROI2.mif \
#            -number 10000 -maxnum 100000 \ 
#            -curvature 1 -minlength 5 
#merge_tracks whole.tck whole_excluding.tck ROI2ROI.tck

