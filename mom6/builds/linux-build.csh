#!/bin/csh -x                                                                                  
set machine_name = "gfdl-ws" #"gfdl-ws" # "theta"        # "lscsky50"
set platform = "intel15"        #"intel16" # "gnu6"    # "intel18_avx1" # "intel18up2_avx1"
set target = "repro" #"debug-openmp"                                                                           
set model  = "slab-sis2" #"mom6-sis2" #"mom6-solo"
set rootdir = `dirname $0`
set abs_rootdir = `cd $rootdir && pwd`


#load modules                                                                                  
source $rootdir/$machine_name/$platform.env

set makeflags = "NETCDF=3"

if( $target =~ *"openmp"* ) then 
   set makeflags = "$makeflags OPENMP=1" 
endif

if( $target =~ *"repro"* ) then
   set makeflags = "$makeflags REPRO=1"
endif

if( $target =~ *"prod"* ) then
   set makeflags = "$makeflags PROD=1"
endif

if( $target =~ *"debug"* ) then
   set makeflags = "$makeflags DEBUG=1"
endif

set root = $cwd
set srcdir = $root/../src

mkdir -p build/$machine_name-$platform/shared/$target
pushd build/$machine_name-$platform/shared/$target   
rm -f path_names                       
$srcdir/mkmf/bin/list_paths $srcdir/FMS
$srcdir/mkmf/bin/mkmf -t $abs_rootdir/$machine_name/$platform.mk -p libfms.a -c "-Duse_libMPI -Duse_netCDF -DSPMD" path_names

make $makeflags libfms.a         

popd

if( $model =~ *"mom6-solo"* ) then
    mkdir -p build/$machine_name-$platform/$model/$target
    pushd build/$machine_name-$platform/$model/$target
    rm -f path_names
    $srcdir/mkmf/bin/list_paths $srcdir/MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}/
    $srcdir/mkmf/bin/mkmf -t $abs_rootdir/$machine_name/$platform.mk -o "-I../../shared/$target" -p $model -l "-L../../shared/$target -lfms" -c '-Duse_libMPI -Duse_netCDF -DSPMD' path_names

    make $makeflags $model
    exit 0
endif

if( $model =~ *"mom6-sis2"* ) then
    mkdir -p build/$machine_name-$platform/$model/$target
    pushd build/$machine_name-$platform/$model/$target
    rm -f path_names
    $srcdir/mkmf/bin/list_paths $srcdir/MOM6/config_src/{dynamic,coupled_driver} $srcdir/MOM6/src/{*,*/*}/ $srcdir/{atmos_null,coupler,land_null,atmos_param,ice_param,icebergs,SIS2,FMS/coupler,FMS/include}/ ; \
    $srcdir/mkmf/bin/mkmf -t $abs_rootdir/$machine_name/$platform.mk -o "-I../../shared/$target" -p $model -l "-L../../shared/$target -lfms" -c '-Duse_libMPI -Duse_netCDF -DSPMD -Duse_AM3_physics -D_USE_LEGACY_LAND_' path_names

    make $makeflags $model
    exit 0
endif

if( $model =~ *"slab-sis2"* ) then
    mkdir -p build/$machine_name-$platform/$model/$target
    pushd build/$machine_name-$platform/$model/$target
    rm -f path_names
    $srcdir/mkmf/bin/list_paths $srcdir/MOM6/config_src/coupled_driver/{MOM_surface_forcing.F90,coupler_util.F90} $srcdir/MOM6/config_src/{dynamic} $srcdir/MOM6/src/{*,*/*}/ $srcdir/{ocean_slab,atmos_null,coupler,land_null,atmos_param,ice_param,icebergs,SIS2,FMS/coupler,FMS/include}/ ; \
    $srcdir/mkmf/bin/mkmf -t $abs_rootdir/$machine_name/$platform.mk -o "-I../../shared/$target" -p $model -l "-L../../shared/$target -lfms" -c '-Duse_libMPI -Duse_netCDF -DSPMD -Duse_AM3_physics -D_USE_LEGACY_LAND_' path_names

    make $makeflags $model
    exit 0
endif




###Sample compile line
##lscsky50-intel18up2_avx1.debug
#mpiifort -Duse_libMPI -Duse_netCDF -DSPMD -Duse_LARGEFILE  -fpp -Wp,-w -I/opt/netcdf/4.6.1/INTEL/include -I/opt/intel/2018_up2/impi/2018.2.199/include64 -I/opt/netcdf/4.6.1/INTEL/include -I/opt/intel/2018_up2/impi/2018.2.199/include64 -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -nowarn -sox -align array64byte -i4 -real-size 64 -no-prec-div -no-prec-sqrt -xCORE-AVX-I -qno-opt-dynamic-align  -g -O0 -check -check noarg_temp_created -check nopointer -warn -warn noerrors -fp-stack-check -fstack-protector-all -fpe0 -debug -traceback -ftrapuv -I../../shared/debug  -c -I../../../../src/MOM6/config_src/dynamic -I../../../../src/MOM6/src/framework     ../../../../src/MOM6/src/core/MOM.F90
##
##theta-intel18_avx1.debug
#ftn -Duse_libMPI -Duse_netCDF -DSPMD -Duse_LARGEFILE  -fpp -Wp,-w -I/opt/cray/pe/netcdf/4.4.1.1.3/INTEL/16.0/include -I/opt/cray/pe/hdf5/1.10.0/INTEL/15.0//include -I/opt/cray/pe/netcdf/4.4.1.1.3/INTEL/16.0/include -I/opt/cray/pe/hdf5/1.10.0/INTEL/15.0//include -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -nowarn -sox -align array64byte -i4 -real-size 64 -no-prec-div -no-prec-sqrt -xCORE-AVX-I -qno-opt-dynamic-align  -g -O0 -check -check noarg_temp_created -check nopointer -warn -warn noerrors -fp-stack-check -fstack-protector-all -fpe0 -debug -traceback -ftrapuv -I../../shared/debug  -c -I../../../../src/MOM6/config_src/dynamic -I../../../../src/MOM6/src/framework  ../../../../src/MOM6/src/core/MOM.F90
#ifort: command line warning #10121: overriding '-xmic-avx512' with '-xCORE-AVX-I'
##theta-intel18_avx1.repro
#ftn -Duse_libMPI -Duse_netCDF -DSPMD -Duse_LARGEFILE  -fpp -Wp,-w -I/opt/cray/pe/netcdf/4.4.1.1.3/INTEL/16.0/include -I/opt/cray/pe/hdf5/1.10.0/INTEL/15.0//include -I/opt/cray/pe/netcdf/4.4.1.1.3/INTEL/16.0/include -I/opt/cray/pe/hdf5/1.10.0/INTEL/15.0//include -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -nowarn -sox -align array64byte -i4 -real-size 64 -no-prec-div -no-prec-sqrt -xCORE-AVX-I -qno-opt-dynamic-align  -O2 -debug minimal -fp-model source -qoverride-limits -g -traceback  -I../../shared/repro  -c -I../../../../src/MOM6/config_src/dynamic -I../../../../src/MOM6/src/framework  ../../../../src/MOM6/src/core/MOM.F90
#ifort: command line warning #10121: overriding '-xmic-avx512' with '-xCORE-AVX-I'
##theta-intel18_avx1.prod
#ftn -Duse_libMPI -Duse_netCDF -DSPMD -Duse_LARGEFILE  -fpp -Wp,-w -I/opt/cray/pe/netcdf/4.4.1.1.3/INTEL/16.0/include -I/opt/cray/pe/hdf5/1.10.0/INTEL/15.0//include -I/opt/cray/pe/netcdf/4.4.1.1.3/INTEL/16.0/include -I/opt/cray/pe/hdf5/1.10.0/INTEL/15.0//include -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -nowarn -sox -align array64byte -i4 -real-size 64 -no-prec-div -no-prec-sqrt -xCORE-AVX-I -qno-opt-dynamic-align  -O2 -debug minimal -fp-model source -qoverride-limits -qopt-prefetch=3 -I../../shared/prod  -c -I../../../../src/MOM6/config_src/dynamic -I../../../../src/MOM6/src/framework ../../../../src/MOM6/src/core/MOM.F90
#ifort: command line warning #10121: overriding '-xmic-avx512' with '-xCORE-AVX-I'


