#!/bin/bash
#SBATCH -J binning_serial 
#SBATCH -N 1 
#SBATCH --ntasks-per-node=1
#SBATCH -t 00:05:00

module purge
module load gcc-4.8.2
export MPIDIR=OpenMPI
export RDIR=R_directory
export PARALLELR=parallelr
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/$PARALLELR/$RDIR/R300install/lib64/R/lib
export MPIINCLUDE=$HOME/$PARALLELR/$MPIDIR/install/include
export MPILIB=$HOME/$PARALLELR/$MPIDIR/install/lib
export OMP_NUM_THREADS=1

~/parallelr/OpenMPI/install/bin/mpirun  ~/parallelr/R_directory/R300install/bin/Rscript --vanilla  ./pca_demo.R

