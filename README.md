# Synb0-DISCO
A docker and singularity repo for Synb0-DISCO for ubuntu16.04

Recreating the Dockerfile and Singularity recipe from https://github.com/MASILab/Synb0-DISCO based on the work in: 

Registration-free Distortion Correction of Diffusion Weighted MRI.
Kurt G Schilling, Justin Blaber, Colin Hansen, Baxter Rogers, Adam W Anderson, Seth Smith, Praitayini Kanakaraj, Tonia Rex, Susan M. Resnick, Andrea T. Shafer, Laurie Cutting, Neil Woodward, David Zald, Bennett A Landman
bioRxiv 2020.01.19.911784; doi: https://doi.org/10.1101/2020.01.19.911784

# Build with
```
singularity build syn.simg syn.build
```
or for an editable image

```
singularity build --writable syn.simg syn.build
```

Or download the built (writable) image from cloudstor (40gb):
https://cloudstor.aarnet.edu.au/sender/?s=download&token=02ba6a30-afb8-4a26-83cc-395933631f2e


# Set up:
In the top level directory should be the empty folder ```OUTPUTS```, the freesurfer license file ```license.txt```, the singularity image ```syn.simg```, the pbs jobscripts ```multi*.pbs``` and the ```INPUTS``` folder containing:
```
INPUTS/
  T1.nii.gz  
  acqparams.txt  
  b0.nii.gz
  pipeline1.sh
  pipeline2GPU.sh
  pipeline3.sh
```
Note, to obtain the ```license.txt``` for freesurfer, register for free at: [https://surfer.nmr.mgh.harvard.edu/registration.html](https://surfer.nmr.mgh.harvard.edu/registration.html)

The contents of ```license.txt``` should look something like:
```
your.email@somewhere.edu.au
12345
 *CKCKCKCKKC
 JASKDKAKKAKD
 ```
 
 # Run on HPC

Use ```runjob.sh``` to call the add the pbs files to the queue. You must edit the PBS files to suit your project/naming conventions etc.
```
job1=$(qsub multi1.pbs)                               
echo $job1                                                                     
job2=$(qsub -W depend=afterok:$job1 multi2.pbs)                                     
echo $job2                                                                                                          
qsub -W depend=afterok:$job2 multi3.pbs
```
Submit this with ```sh runjob.sh```. This will queue each part of the pipeline as requried.
