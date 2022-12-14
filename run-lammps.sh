#!/bin/bash -l
#! -cwd
#! -j y
#! -S /bin/bash
#SBATCH -D ./
#SBATCH --job-name=EQa-SiOx
#SBATCH --partition=high2 # Partition you are running on. Options: low2, med2, high2
#SBATCH --output=/home/agoga/sandbox/lammps/topcon/slurm-output/SiO-%j.txt
#SBATCH --mail-user="adgoga@ucdavis.edu"
#SBATCH --mail-type=FAIL,END

#======
#SBATCH --ntasks=256
#SBATCH --ntasks-per-node=256
#SBATCH --cpus-per-task=1 
#SBATCH --mem=64G
#SBATCH -t 10-00:00

###COMMAND LINE ARGUMENTS
###1ST FILE NAME
###2ND 'farm' or no to tell if farm or not
###3RD 

lmppre='lmp/'
FILE=$1
FILENAME=${1#"$lmppre"} #"SilicaAnneal.lmp"

j=$SLURM_JOB_ID

NAME=${FILENAME%.*}

if [[ $2 == "farm" ]]; then
    UNIQUE_TAG="-FARM-"$SLURM_JOBID
else 
    UNIQUE_TAG=$(date +%m%d-%Hh%Mm%S)
fi


CWD=$(pwd) #current working directory
OUT_FOLDER=$CWD"/output/"${NAME}${UNIQUE_TAG}"/"

mkdir -p $CWD"/output/" #just in case output folder is not made
mkdir $OUT_FOLDER #Now make folder where all the output will go


IN_FILE=$CWD"/"$FILE
LOG_FILE=$OUT_FOLDER$NAME".log"
cp $IN_FILE $OUT_FOLDER

s=$OUT_FOLDER$NAME"_SLURM.txt"






export OMP_NUM_THREADS=1
# export OMP_PLACES=threads
# export OMP_PROC_BIND=true

if [[ $2 == "farm" ]]; then    #                                                          Creates a variable in lammps ${output_folder}
    srun /home/agoga/sandbox/lammps/lmp_mpi -nocite -log $LOG_FILE -in $OUT_FOLDER$FILENAME -var output_folder $OUT_FOLDER
else
    mpirun -np 2 lmp_mpi -nocite -log $LOG_FILE -in $OUT_FOLDER$FILENAME -var output_folder $OUT_FOLDER
fi
