#!/bin/bash
#SBATCH -J binning_serial 
#SBATCH -N 1 
#SBATCH --ntasks-per-node=1
#SBATCH -t 00:05:00

module purge
module load gcc-5.2.0
module load zlib-1.2.8
export MPIDIR=OpenMPI
export RDIR=R_directory
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/$RDIR/R300install/lib64/R/lib
export MPIINCLUDE=$HOME/$MPIDIR/install/include
export MPILIB=$HOME/$MPIDIR/install/lib
export OMP_NUM_THREADS=1

~/OpenMPI/install/bin/mpirun  ~/R_directory/R300install/bin/Rscript --vanilla  ./pca_demo.R

