#!/bin/bash

for i in FP_96dirs_b2000_1p5iso MP_96dirs_b2000_1p5iso HT_96dirs_b2000_1p5iso KK_96dirs_b2000_1p5iso KW_96dirs_b2000_1p5iso JW_96dirs_b2000_1p5iso; do
    bash /N/dc2/projects/lifebid/HCP/Brent/vss-2016/pestillilab_projects/life_conn/mrtrix_ensemble.sh $i
done