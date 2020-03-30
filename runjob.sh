job1=$(qsub multi1.pbs)
echo $job1
job2=$(qsub -W depend=afterok:$job1 multi2.pbs)
echo $job2
qsub -W depend=afterok:$job2 multi3.pbs
