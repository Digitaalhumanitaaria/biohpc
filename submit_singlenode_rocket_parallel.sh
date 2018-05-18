#!/bin/bash
#SBATCH -J clustering_single_node_parallel
#SBATCH -N 1 
#SBATCH --ntasks-per-node=4
#SBATCH -t 00:05:00

module purge
module load gcc-5.2.0
export MPIDIR=R_OpenMPI31
export RDIR=R_directory
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/$RDIR/extrasinstall/lib:$HOME/$RDIR/R350install/lib64/R/lib
export MPIINCLUDE=$HOME/$MPIDIR/install/include
export MPILIB=$HOME/$MPIDIR/install/lib
export OMP_NUM_THREADS=1

~/ROpenMPI31/install/bin/mpirun -np 4 ~/R_directory/R350install/bin/Rscript --vanilla  ./pmclustdemo.R
