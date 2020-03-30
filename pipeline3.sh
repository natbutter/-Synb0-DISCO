#!/bin/bash

# Take mean
echo Taking ensemble average
fslmerge -t /OUTPUTS/b0_u_lin_atlas_2_5_merged.nii.gz /OUTPUTS/b0_u_lin_atlas_2_5_FOLD_*.nii.gz
fslmaths /OUTPUTS/b0_u_lin_atlas_2_5_merged.nii.gz -Tmean /OUTPUTS/b0_u_lin_atlas_2_5.nii.gz

# Apply inverse xform to undistorted b0
echo Applying inverse xform to undistorted b0
antsApplyTransforms -d 3 -i /OUTPUTS/b0_u_lin_atlas_2_5.nii.gz -r /INPUTS/b0.nii.gz -n BSpline -t [/OUTPUTS/epi_reg_d_ANTS.txt,1] -t [/OUTPUTS/ANTS0GenericAffine.mat,1] -o /OUTPUTS/b0_u.nii.gz

# Smooth image
echo Applying slight smoothing to distorted b0
fslmaths /INPUTS/b0.nii.gz -s 1.15 /OUTPUTS/b0_d_smooth.nii.gz

# Merge results and run through topup
echo Running topup
fslmerge -t /OUTPUTS/b0_all.nii.gz /OUTPUTS/b0_d_smooth.nii.gz /OUTPUTS/b0_u.nii.gz
topup -v --imain=/OUTPUTS/b0_all.nii.gz --datain=/INPUTS/acqparams.txt --config=b02b0.cnf --iout=/OUTPUTS/b0_all_topup.nii.gz --out=/OUTPUTS/topup --subsamp=1,1,1,1,1,1,1,1,1 --miter=10,10,10,10,10,20,20,30,30 --lambda=0.00033,0.000067,0.0000067,0.000001,0.00000033,0.000000033,0.0000000033,0.000000000033,0.00000000000067

# Done
echo FINISHED PART 3, complete!!!
