#!/bin/bash
#SBATCH --export=NONE
#SBATCH -J snake_workflow
#SBATCH -o snake_workflow.o
#SBATCH -e snake_workflow.e
#SBATCH --ntasks 1
#SBATCH --time 120:00:00
#SBATCH --mem=8G



# activate conda
. /varidata/research/software/BBC/miniconda_bare/etc/profile.d/conda.sh && . '/primary/vari/software/BBC/miniconda_bare/etc/profile.d/mamba.sh'
conda activate snakemake

# make logs dir if it does not exist already. 
logs_dir="logs/"
[[ -d $logs_dir ]] || mkdir -p $logs_dir


snakemake -p --profile 'profile/generic_slurm/' --keep-incomplete
