#!/bin/bash
# A script to install OpenMPI on Rocket
# and then also install Parallel R


cd $HOME
module purge
module load gcc-5.2.0
# Give installation directory a name
export MPIDIR=ROpenMPI31
# Make installation directory
rm -r $MPIDIR
mkdir $MPIDIR
# Go into installation directory
cd $MPIDIR
# Get OpenMPI
wget https://www.open-mpi.org/software/ompi/v3.1/downloads/openmpi-3.1.0.tar.gz
# Decompress OpenMPI
tar -xvf openmpi-3.1.0.tar.gz
# Go into OpenMPI directory
cd openmpi-3.1.0
./configure --prefix=$HOME/$MPIDIR/install --with-slurm \
            FC=/storage/software/gcc-5.2.0/bin/gfortran \
            CXX=/storage/software/gcc-5.2.0/bin/g++ \
            --disable-dlopen \
           CPPFLAGS="-I/storage/software/zlib-1.2.8/include"
# Build library
make all
# Install the library
make all install

cd $HOME
export RDIR=R_directory
rm -r $RDIR
mkdir $RDIR
cd $RDIR
# Get Curses (https://www.gnu.org/software/ncurses/)
wget https://invisible-mirror.net/archives/ncurses/ncurses-6.1.tar.gz
tar -xvf ncurses-6.1.tar.gz
cd ncurses-6.1
./configure --prefix=$HOME/$RDIR/extrasinstall --with-shared \
 CC=$HOME/$MPIDIR/install/bin/mpicc
make
make install
export LD_LIBRARY_PATH=$HOME/$RDIR/extrasinstall/lib:$LD_LIBRARY_PATH
cd ..

# Get Readline (http://tiswww.case.edu/php/chet/readline/rltop.html) 
wget ftp://ftp.gnu.org/gnu/readline/readline-7.0.tar.gz
tar -xvf readline-7.0.tar.gz
cd readline-7.0
./configure --with-curses --prefix=$HOME/$RDIR/extrasinstall \
 --enable-shared --enable-static CC=$HOME/$MPIDIR/install/bin/mpicc
make
make install
cd ..


# Get zlib
wget https://sourceforge.net/projects/libpng/files/zlib/1.2.8/zlib-1.2.8.tar.gz
tar -xvf zlib-1.2.8.tar.gz
cd zlib-1.2.8
make distclean
./configure --prefix=$HOME/$RDIR/extrasinstall
make
make install
cd ..

# Get openssl
wget https://www.openssl.org/source/openssl-1.0.2o.tar.gz
tar -xvf openssl-1.0.2o.tar.gz
cd openssl-1.0.2o
./config shared --prefix=$HOME/$RDIR/extrasinstall
make
make install
cd ..

# Get xz
wget https://sourceforge.net/projects/lzmautils/files/xz-5.2.4.tar.gz/download
mv download xz-5.2.4.tar.gz
tar -xvf xz-5.2.4.tar.gz
cd xz-5.2.4
./configure --prefix=$HOME/$RDIR/extrasinstall \
 --enable-shared --enable-static CC=$HOME/$MPIDIR/install/bin/mpicc
make
make install
cd ..

# Get curl
wget https://github.com/curl/curl/releases/download/curl-7_59_0/curl-7.59.0.tar.gz
tar -xvf curl-7.59.0.tar.gz
cd curl-7.59.0
./configure --prefix=$HOME/$RDIR/extrasinstall \
 --enable-shared --enable-static CC=$HOME/$MPIDIR/install/bin/mpicc \
 --with-ssl=$HOME/$RDIR/extrasinstall/
make
make install
cd ..

# Get R version 3.5.0
# https://cran.r-project.org/doc/manuals/R-admin.html#Getting-and-unpacking-the-sources 
wget http://ftp.eenet.ee/pub/cran/src/base/R-3/R-3.5.0.tar.gz
tar -xvf R-3.5.0.tar.gz
export PKG_CONFIG_PATH=$OME/$RDIR/extrasinstall/lib/pkgconfig:$PKG_CONFIG_PATH
cd R-3.5.0
./configure --prefix=$HOME/$RDIR/R350install \
 CC=$HOME/$MPIDIR/install/bin/mpicc \
 CXX=$HOME/$MPIDIR/install/bin/mpicxx \
 F77=$HOME/$MPIDIR/install/bin/mpif90 \
 FC=$HOME/$MPIDIR/install/bin/mpif90 \
 --with-recommended-packages \
 --enable-static --enable-shared\
 LDFLAGS="-L$HOME/$RDIR/extrasinstall/lib -lcurl" \
 CPPFLAGS="-I$HOME/$RDIR/extrasinstall/include" \
--with-x=no
make
make install
cd ..

mkdir -p ~/R/x86_64-unknown-linux-gnu-library/3.5
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/$RDIR/R350install/lib64/R/lib:$HOME/$RDIR/R350install/lib64/R/library

export MPIINCLUDE=$HOME/$MPIDIR/install/include
export MPILIB=$HOME/$MPIDIR/install/lib

# Get RMPI http://www.stats.uwo.ca/faculty/yu/Rmpi/ 
wget https://cran.r-project.org/src/contrib/Rmpi_0.6-7.tar.gz

$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library  Rmpi_0.6-7.tar.gz 

# Get Rmethods https://cran.r-project.org/web/packages/R.methodsS3/index.html
wget https://cran.r-project.org/src/contrib/R.methodsS3_1.7.1.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I/$MPIINCLUDE LDFLAGS=' -L/$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library R.methodsS3_1.7.1.tar.gz

# Get R.oo https://cran.r-project.org/web/packages/R.oo/index.html
wget https://cran.r-project.org/src/contrib/R.oo_1.22.0.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I/$MPIINCLUDE LDFLAGS=' -L/$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library R.oo_1.22.0.tar.gz

# Get doMC https://cran.r-project.org/web/packages/doMC/index.html
wget https://cran.r-project.org/src/contrib/doMC_1.3.5.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I/$MPIINCLUDE LDFLAGS=' -L$HOME/$MPIDIR/install//lib'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library doMC_1.3.5.tar.gz

# Get utils https://cran.r-project.org/web/packages/R.utils/index.html
wget https://cran.r-project.org/src/contrib/R.utils_2.6.0.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$HOME/$MPIDIR/install//lib'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library R.utils_2.6.0.tar.gz


# Get SNOW https://cran.r-project.org/web/packages/snow/index.html
wget https://cran.r-project.org/src/contrib/snow_0.4-2.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$HOME/$MPIDIR/install//lib'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library snow_0.4-2.tar.gz 


# Get iterators https://cran.r-project.org/web/packages/iterators/index.html
wget https://cran.r-project.org/src/contrib/iterators_1.0.9.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$HOME/$MPIDIR/install//lib'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library iterators_1.0.9.tar.gz


# Get codetools https://cran.r-project.org/web/packages/codetools/index.html
wget https://cran.r-project.org/src/contrib/codetools_0.2-15.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library codetools_0.2-15.tar.gz


# Get foreach https://cran.r-project.org/web/packages/foreach/index.html 
wget https://cran.r-project.org/src/contrib/foreach_1.4.4.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$HOME/$MPIDIR/install//lib'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library foreach_1.4.4.tar.gz


# Get doparallel https://cran.r-project.org/web/packages/doParallel/index.html
wget https://cran.r-project.org/src/contrib/doParallel_1.0.11.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library doParallel_1.0.11.tar.gz


# Get doMPI https://cran.r-project.org/web/packages/doMPI/index.html
wget https://cran.r-project.org/src/contrib/doMPI_0.2.2.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library doMPI_0.2.2.tar.gz


# Get doSNOW https://cran.r-project.org/web/packages/doSNOW/
wget https://cran.r-project.org/src/contrib/doSNOW_1.0.16.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library doSNOW_1.0.16.tar.gz


# Get snowfall https://cran.r-project.org/web/packages/snowfall/index.html
wget https://cran.r-project.org/src/contrib/snowfall_1.84-6.1.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library snowfall_1.84-6.1.tar.gz


# Get rlecuyer https://cran.r-project.org/web/packages/rlecuyer/index.html
wget https://cran.r-project.org/src/contrib/rlecuyer_0.3-4.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-Rmpi-include=$MPIINCLUDE \
                   --with-Rmpi-libpath=$MPILIB \
                   --with-Rmpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library rlecuyer_0.3-4.tar.gz


# Get pdbMPI https://cran.r-project.org/web/packages/pbdMPI/index.html
wget https://cran.r-project.org/src/contrib/pbdMPI_0.3-5.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library pbdMPI_0.3-5.tar.gz

    
#get  https://cran.r-project.org/web/packages/rlecuyer/index.html
     wget https://cran.r-project.org/src/contrib/rlecuyer_0.3-4.tar.gz
     $HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library rlecuyer_0.3-4.tar.gz
    
    
#get https://cran.r-project.org/web/packages/pbdSLAP/index.html
 wget https://cran.r-project.org/src/contrib/pbdSLAP_0.2-4.tar.gz
 $HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library pbdSLAP_0.2-4.tar.gz
  
  
 
# get  https://cran.r-project.org/web/packages/pbdBASE/index.html
wget https://cran.r-project.org/src/contrib/pbdBASE_0.4-5.1.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
 -l $HOME/$RDIR/R350install/lib64/R/library pbdBASE_0.4-5.1.tar.gz
 
 
# Get pdbMAT https://cran.r-project.org/web/packages/pbDMAT/index.html
wget https://cran.r-project.org/src/contrib/pbdDMAT_0.4-2.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$RDIR/R350install/lib64/R/library pbdDMAT_0.4-2.tar.gz 

# Get and install the HDF5 Parallel IO library
wget www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.10.1.tar.gz
tar -xvf hdf5-1.10.1.tar.gz
cd hdf5-1.10.1
export HDF5DIR=hdf5
CC="$HOME/$MPIDIR/install/bin/mpicc" 
CFLAGS="-fPIC -I$MPIINCLUDE" 
CPPFLAGS="-fPIC -I$MPIINCLUDE" 
LDFLAGS="-L$MPILIB"
./configure \
 --prefix=$HOME/$HDF5DIR/HDF5install/ \ 
           --enable-parallel \
           --enable-shared 
make
make install
cd ..

# Get and install netcdf, information at:
# https://www.unidata.ucar.edu/software/netcdf/docs/index.html 
wget https://github.com/Unidata/netcdf-c/archive/v4.6.1.tar.gz
tar -xvf v4.6.1.tar.gz
export NETCDF4DIR=netcdf4
cd netcdf-c-4.6.1
CC="$HOME/$MPIDIR/install/bin/mpicc -g"
CFLAGS="-fPIC -I$MPIINCLUDE -I$HOME/$HDF5DIR/HDF5install/include"
CPPFLAGS="-fPIC -I$MPIINCLUDE -I$HOME/$HDF5DIR/HDF5install/include" 
LDFLAGS="-L$MPILIB -L$HOME/$HDF5DIR/HDF5install/lib -lhdf5"
./configure \
      --prefix=$HOME/$NETCDF4DIR/netcdf4install/ \
      --enable-netcdf4 \
      --enable-shared \
      CC="$HOME/$MPIDIR/install/bin/mpicc -g" \
      CFLAGS="-fPIC -I$MPIINCLUDE -I$HOME/$HDF5DIR/HDF5install/include" \
      CPPFLAGS="-fPIC -I$MPIINCLUDE -I$HOME/$HDF5DIR/HDF5install/include" \ 
      LDFLAGS="-L$MPILIB -L$HOME/$HDF5DIR/HDF5install/lib -lhdf5"
make 
make install
cd ..

# Get pdbNETCDF4 https://cran.r-project.org/web//packages/pbdNCDF4/index.html 
wget https://cran.r-project.org/src/contrib/pbdNCDF4_0.1-4.tar.gz
tar -zxvf pbdNCDF4_0.1-4.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \ 
 --configure-args="--with-nc-config=$HOME/$NETCDF4DIR/netcdf4install/bin \
                   --enable-parallel \
                   --with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$RDIR/R350install/lib64/R/library pbdNCDF4 


# Get and install pbdDEMO https://cran.r-project.org/web/packages/pbdDEMO/index.html
wget https://cran.r-project.org/src/contrib/pbdDEMO_0.3-1.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$RDIR/R350install/lib64/R/library pbdDEMO_0.3-1.tar.gz
 
 
# Get pdbDEMO https://cran.r-project.org/web//packages/pbdDEMO/index.html 
#wget https://github.com/wrathematics/pbdDEMO/archive/v0.2-0.tar.gz 
#mv v0.2-0.tar.gz pbdDEMO_0.2-0.tar.gz
#$HOME/$RDIR/R300install/bin/R CMD INSTALL \
# --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
# --configure-args="--with-mpi-include=$MPIINCLUDE \
#                   --with-mpi-libpath=$MPILIB \
#                   --with-mpi-type=OPENMPI" \
#-l $HOME/$RDIR/R300install/lib64/R/library pbdDEMO_0.2-0.tar.gz 
 
 # Get chron which is needed for data.table https://cran.r-project.org/web/packages/chro
n/index.html
wget https://cran.r-project.org/src/contrib/chron_2.3-52.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$RDIR/R350install/lib64/R/library chron_2.3-52.tar.gz


# Get data.table https://cran.r-project.org/web/packages/data.table/index.html
wget https://cran.r-project.org/src/contrib/data.table_1.11.2.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$RDIR/R350install/lib64/R/library data.table_1.11.2.tar.gz

# Get PM cluster https://cran.r-project.org/web/packages/pmclust/index.html
wget https://cran.r-project.org/src/contrib/pmclust_0.2-0.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$RDIR/R350install/lib64/R/library pmclust_0.2-0.tar.gz

#Coda dependency for the cubfit https://cran.r-project.org/web/packages/coda/index.html
wget https://cran.r-project.org/src/contrib/coda_0.19-1.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$RDIR/R350install/lib64/R/library coda_0.19-1.tar.gz


# Cubfit demo https://cran.r-project.org/web/packages/cubfits/index.html
wget https://cran.r-project.org/src/contrib/cubfits_0.1-3.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$RDIR/R350install/lib64/R/library cubfits_0.1-3.tar.gz

# Get pdbDEMO https://cran.r-project.org/web//packages/pbdDEMO/index.html 
#wget https://github.com/wrathematics/pbdDEMO/archive/v0.2-0.tar.gz
wget https://cran.r-project.org/src/contrib/pbdDEMO_0.3-1.tar.gz
$HOME/$RDIR/R350install/bin/R CMD INSTALL \
 --configure-vars="CPPFLAGS=-I$MPIINCLUDE LDFLAGS=' -L$MPILIB'" \
 --configure-args="--with-mpi-include=$MPIINCLUDE \
                   --with-mpi-libpath=$MPILIB \
                   --with-mpi-type=OPENMPI" \
-l $HOME/$RDIR/R350install/lib64/R/library pbdDEMO_0.3-1.tar.gz 

