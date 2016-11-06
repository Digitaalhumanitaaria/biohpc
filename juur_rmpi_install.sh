!#/bin/bash
# A script to install OpenMPI with Java bindings on Rocket
# and then also install Parallel R

# Documentation on MPI and Java can be found at:
# http://charith.wickramaarachchi.org/
# http://www.open-mpi.de/faq/?category=java
# users.dsic.upv.es/~jroman/preprints/ompi-java.pdf
# https://github.com/esaliya/OpenMPI-Java-OMB
# https://cloudmesh.github.io/reu/projects/mpi-java-performance.html
# courses.washington.edu/css434/prog/hw2.pdf
# http://www.i3s.unice.fr/~hogie/mpi4lectures/
# kodu.ut.ee/~eero/pdf/2008/P2P-MPI.pdf

cd $HOME
module purge
module load gcc-4.8.2
export PARALLELR=parallelr
mkdir $PARALLELR
cd $PARALLELR
# Give zlib installation directory a name
export ZLIBDIR=zlib
mkdir $ZLIBDIR
cd $ZLIBDIR
#wget https://sourceforge.net/projects/libpng/files/zlib/1.2.8/zlib-1.2.8.tar.gz
#tar -xvf zlib-1.2.8.tar.gz
#cd zlib-1.2.8
#make distclean
#./configure --prefix=$HOME/$PARALLELR/$ZLIBDIR/install
#make
#make install
cd $HOME/$PARALLELR

# Give MPI installation directory a name
export MPIDIR=OpenMPI
# Make installation directory
mkdir $MPIDIR
# Go into installation directory
cd $MPIDIR
# Get OpenMPI
#wget www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.2.tar.gz
# Decompress OpenMPI
#tar -xvf openmpi-1.10.2.tar.gz
# Go into OpenMPI directory
#cd openmpi-1.10.2
#./configure --prefix=$HOME/$PARALLELR/$MPIDIR/install --with-slurm \
#            FC=/opt/gcc-4.8.2/bin/gfortran \
#            CXX=/opt/gcc-4.8.2/bin/g++ \
#            --disable-dlopen \
#           CPPFLAGS="-I/$HOME/$PARALLELR/$ZLIBDIR/install/include"
# Build library
#make all
# Install the library
#make all install

cd $HOME
export RDIR=R_directory

mkdir $RDIR
cd $RDIR
# Get Readline (http://tiswww.case.edu/php/chet/readline/rltop.html) 
#wget ftp://ftp.cwru.edu/pub/bash/readline-6.3.tar.gz
ftp://ftp.gnu.org/gnu/readline/readline-6.3.tar.gz
tar -xvf readline-6.3.tar.gz
cd readline-6.3
./configure --prefix=$HOME/$PARALLELR/$RDIR/readlineinstall \
 CC=$HOME/$PARALLELR/$MPIDIR/install/bin/mpicc 
make
make install
cd ..

# Get R version 3.0.0 since this seems to work with MPI
# https://cran.r-project.org/doc/manuals/R-admin.html#Getting-and-unpacking-the-sources 
wget http://ftp.eenet.ee/pub/cran/src/base/R-3/R-3.0.0.tar.gz
tar -xvf R-3.0.0.tar.gz
cd R-3.0.0
./configure --prefix=$HOME/$PARALLELR/$RDIR/R300install \
 CC=$HOME/$PARALLELR/$MPIDIR/install/bin/mpicc \
 CXX=$HOME/$PARALLELR/$MPIDIR/install/bin/mpicxx \
 F77=$HOME/$PARALLELR/$MPIDIR/install/bin/mpif90 \
 FC=$HOME/$PARALLELR/$MPIDIR/install/bin/mpif90 \
 --with-recommended-packages \
 --enable-static --enable-shared \
 LDFLAGS="-L$HOME/$PARALLELR/$RDIR/readlineinstall/lib" \
 CPPFLAGS="-I$HOME/$PARALLELR/$RDIR/readlineinstall/include" \
--with-x=no
make
make install
cd ..

mkdir -p ~/R/x86_64-unknown-linux-gnu-library/3.0
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/$PARALLELR/$RDIR/R300install/lib64/R/lib:$HOME/$PARALLELR/$RDIR/R300install/lib64/R/library

export MPIINCLUDE=$HOME/$PARALLELR/$MPIDIR/install/include
export MPILIB=$HOME/$PARALLELR/$MPIDIR/install/lib

# Get RMPI http://www.stats.uwo.ca/faculty/yu/Rmpi/ 
wget https://cran.r-project.org/src/contrib/Rmpi_0.6-5.tar.gz

$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library  Rmpi_0.6-5.tar.gz 

# Get Rmethods https://cran.r-project.org/web/packages/R.methodsS3/index.html
wget https://cran.r-project.org/src/contrib/R.methodsS3_1.7.1.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I/$MPIINCLUDE LDFLAGS=' -L/$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library R.methodsS3_1.7.1.tar.gz

# Get R.oo https://cran.r-project.org/web/packages/R.oo/index.html
wget https://cran.r-project.org/src/contrib/R.oo_1.20.0.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I/$MPIINCLUDE LDFLAGS=' -L/$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library R.oo_1.20.0.tar.gz

# Get doMC https://cran.r-project.org/web/packages/doMC/index.html
wget https://cran.r-project.org/src/contrib/doMC_1.3.4.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I/$MPIINCLUDE LDFLAGS=' -L$HOME/$PARALLELR/$MPIDIR/install//lib'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library doMC_1.3.4.tar.gz

# Get utils https://cran.r-project.org/web/packages/R.utils/index.html
wget https://cran.r-project.org/src/contrib/R.utils_2.3.0.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$HOME/$PARALLELR/$MPIDIR/install//lib'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library R.utils_2.3.0.tar.gz


# Get SNOW https://cran.r-project.org/web/packages/snow/index.html
wget https://cran.r-project.org/src/contrib/snow_0.4-1.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$HOME/$PARALLELR/$MPIDIR/install//lib'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library snow_0.4-1.tar.gz 


# Get iterators https://cran.r-project.org/web/packages/iterators/index.html
wget https://cran.r-project.org/src/contrib/iterators_1.0.8.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$HOME/$PARALLELR/$MPIDIR/install//lib'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library iterators_1.0.8.tar.gz


# Get codetools https://cran.r-project.org/web/packages/codetools/index.html
wget https://cran.r-project.org/src/contrib/codetools_0.2-14.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library codetools_0.2-14.tar.gz


# Get foreach https://cran.r-project.org/web/packages/foreach/index.html 
wget https://cran.r-project.org/src/contrib/foreach_1.4.3.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$HOME/$PARALLELR/$MPIDIR/install//lib'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library foreach_1.4.3.tar.gz


# Get doparallel https://cran.r-project.org/web/packages/doParallel/index.html
wget https://cran.r-project.org/src/contrib/doParallel_1.0.10.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library doParallel_1.0.10.tar.gz


# Get doMPI https://cran.r-project.org/web/packages/doMPI/index.html
wget https://cran.r-project.org/src/contrib/doMPI_0.2.1.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library doMPI_0.2.1.tar.gz


# Get doSNOW https://cran.r-project.org/web/packages/doSNOW/
wget https://cran.r-project.org/src/contrib/doSNOW_1.0.14.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library doSNOW_1.0.14.tar.gz


# Get snowfall https://cran.r-project.org/web/packages/snowfall/index.html
wget https://cran.r-project.org/src/contrib/snowfall_1.84-6.1.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library snowfall_1.84-6.1.tar.gz


# Get rlecuyer https://cran.r-project.org/web/packages/rlecuyer/index.html
wget https://cran.r-project.org/src/contrib/rlecuyer_0.3-4.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library rlecuyer_0.3-4.tar.gz


# Get pdbMPI https://cran.r-project.org/web/packages/pbdMPI/index.html
wget https://cran.r-project.org/src/contrib/pbdMPI_0.3-1.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library pbdMPI_0.3-1.tar.gz

    
#get  https://cran.r-project.org/web/packages/rlecuyer/index.html
     wget https://cran.r-project.org/src/contrib/rlecuyer_0.3-4.tar.gz
     $HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library rlecuyer_0.3-4.tar.gz
    
    
#get https://cran.r-project.org/web/packages/pbdSLAP/index.html
 wget https://cran.r-project.org/src/contrib/pbdSLAP_0.2-1.tar.gz
 $HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library pbdSLAP_0.2-1.tar.gz
  
  
 
# get  https://cran.r-project.org/web/packages/pbdBASE/index.html
wget https://cran.r-project.org/src/contrib/pbdBASE_0.4-3.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
 -l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library pbdBASE_0.4-3.tar.gz
 
 
# Get pdbMAT https://cran.r-project.org/web/packages/pbdMAT/index.html
wget https://cran.r-project.org/src/contrib/pbdDMAT_0.4-0.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library pbdDMAT_0.4-0.tar.gz 

# Get and install the HDF5 Parallel IO library
wget www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.17.tar.gz
tar -xvf hdf5-1.8.17.tar.gz
cd hdf5-1.8.17
export HDF5DIR=hdf5
CC="$HOME/$PARALLELR/$MPIDIR/install/bin/mpicc" 
CFLAGS="-fPIC -I$MPIINCLUDE" 
CPPFLAGS="-fPIC -I$MPIINCLUDE" 
LDFLAGS="-L$MPILIB"
./configure \
 --prefix=$HOME/$PARALLELR/$HDF5DIR/HDF5install/ \ 
           --enable-parallel \
           --enable-shared 
make
make install
cd ..

# Get and install netcdf, information at:
# https://www.unidata.ucar.edu/software/netcdf/docs/index.html 
wget https://github.com/Unidata/netcdf-c/archive/v4.4.0.tar.gz
tar -xvf v4.4.0.tar.gz
export NETCDF4DIR=netcdf4
cd netcdf-c-4.4.0
CC="$HOME/$PARALLELR/$MPIDIR/install/bin/mpicc -g"
CFLAGS="-fPIC -I$MPIINCLUDE -I$HOME/$PARALLELR/$HDF5DIR/HDF5install/include"
CPPFLAGS="-fPIC -I$MPIINCLUDE -I$HOME/$PARALLELR/$HDF5DIR/HDF5install/include" 
LDFLAGS="-L$MPILIB -L$HOME/$PARALLELR/$HDF5DIR/HDF5install/lib -lhdf5"
./configure \
      --prefix=$HOME/$PARALLELR/$NETCDF4DIR/netcdf4install/ \
      --enable-netcdf4 \
      --enable-shared \
      CC="$HOME/$MPIDIR/install/bin/mpicc -g" \
      CFLAGS="-fPIC -I$MPIINCLUDE -I$HOME/$PARALLELR/$HDF5DIR/HDF5install/include" \
      CPPFLAGS="-fPIC -I$MPIINCLUDE -I$HOME/$PARALLELR/$HDF5DIR/HDF5install/include" \ 
      LDFLAGS="-L$MPILIB -L$HOME/$PARALLELR/$HDF5DIR/HDF5install/lib -lhdf5"
make 
make install
cd ..

# Get pdbNETCDF4 https://cran.r-project.org/web//packages/pbdDEMO/index.html 
wget https://cran.r-project.org/src/contrib/pbdNCDF4_0.1-4.tar.gz
tar -zxvf pbdNCDF4_0.1-4.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \ 
 --configure-args="--with-nc-config=$HOME/$PARALLELR/$NETCDF4DIR/netcdf4install/bin \
                   --enable-parallel \
                   --with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library pbdNCDF4 


# Get and install pbdDEMO https://cran.r-project.org/web/packages/pbdDEMO/index.html
wget https://cran.r-project.org/src/contrib/pbdDEMO_0.3-0.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library pbdDEMO_0.3-0.tar.gz
 
 
# Get pdbDEMO https://cran.r-project.org/web//packages/pbdDEMO/index.html 
#wget https://github.com/wrathematics/pbdDEMO/archive/v0.2-0.tar.gz 
#mv v0.2-0.tar.gz pbdDEMO_0.2-0.tar.gz
#$HOME/$RDIR/R300install/bin/R CMD INSTALL \
# --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
# --configure-args="--with-mpi-include=$MPIINCLUDE \
#                   --with-mpi-libpath=$MPILIB \
#                   --with-mpi-type=OPENMPI" \
#-l $HOME/$RDIR/R300install/lib64/R/library pbdDEMO_0.2-0.tar.gz 
 
# Get chron which is needed for data.table https://cran.r-project.org/web/packages/chron/index.html
wget https://cran.r-project.org/src/contrib/chron_2.3-47.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library chron_2.3-47.tar.gz


# Get data.table https://cran.r-project.org/web/packages/data.table/index.html
wget https://cran.r-project.org/src/contrib/data.table_1.9.6.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library data.table_1.9.6.tar.gz

# Get PM cluster https://cran.r-project.org/web/packages/pmclust/index.html
wget https://cran.r-project.org/src/contrib/pmclust_0.1-8.tar.gz
$HOME/$PARALLELR/$RDIR/R300install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$PARALLELR/$RDIR/R300install/lib64/R/library pmclust_0.1-8.tar.gz 

