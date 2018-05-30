#!/bin/bash
#SBATCH -J Rinstallation 
#SBATCH -N 1
#SBATCH --mem 35000
#SBATCH -t 05:05:00

bash rocket_rmpi_install2.sh
