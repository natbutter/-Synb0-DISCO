#!/bin/bash

echo RUNNING PART 1...

# Set path for executable
export PATH=$PATH:/extra

# Set up freesurfer
export FREESURFER_HOME=/extra/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# Set up FSL
. /extra/fsl/etc/fslconf/fsl.sh
export PATH=$PATH:/extra/fsl/bin
export FSLDIR=/extra/fsl

# Set up ANTS
export ANTSPATH=/extra/ANTS/bin/ants/bin/
export PATH=$PATH:$ANTSPATH:/extra/ANTS/ANTs/Scripts

# Prepare input
prepare_input.sh /INPUTS/b0.nii.gz /INPUTS/T1.nii.gz /extra/atlases/mni_icbm152_t1_tal_nlin_asym_09c.nii.gz /extra/atlases/mni_icbm152_t1_tal_nlin_asym_09c_2_5.nii.gz /OUTPUTS

echo FINISHED PART 1!!!
