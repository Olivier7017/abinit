#!/bin/bash

# Init
fallbacks_prefix="@abinit_builddir@/fallbacks/install/@abi_fc_vendor@/@abi_fc_version@"

# Find and Unpack tarball
cd @abinit_builddir@/fallbacks
tarfile=$(ls *.tar.gz)
source=${tarfile%.tar.gz}
if [ ! -d "$source" ]; then
    tar -xzf $tarfile
fi
cd $source
make clean

# Configure
./configure \
  --prefix="${fallbacks_prefix}" \
  --with-tardir="${HOME}/.abinit/tarballs" \
  --with-linalg-incs="@sd_linalg_fcflags@" \
  --with-linalg-libs="@sd_linalg_libs@" \
  --with-fc-vendor="@abi_fc_vendor@" \
  --with-fc-version="@abi_fc_version@" \
  --disable-hdf5 \
  --disable-bigdft \
  --disable-atompaw \
  --disable-wannier90 \
  --disable-xmlf90 --disable-libpsml \
  CC="@CC@" \
  CXX="@CXX@" \
  FC="@FC@"

make -j 4 install
rc=`echo $?`

if test "$rc" = "0"; then
  printf "$(tput bold)----------------------------------------------------------------------$(tput sgr0)\n\n"
  echo "The fallbacks are now ready to use."; \
  echo "You can tell Abinit by copying the options to your ac9 file.";

  list_of_fbks=( libxc netcdf4 netcdf4_fortran linalg )
  for i in "${list_of_fbks[@]}"; do
    if test "`${fallbacks_prefix}/bin/abinit-fallbacks-config --enabled ${i}`" = "yes"; then
      Prefix=`${fallbacks_prefix}/bin/abinit-fallbacks-config --incs ${i}`
      printf "\n$(tput bold)"
      echo "with_${i}=${Prefix}" | sed '-e s/-I//;  s/include$//; s/netcdf4/netcdf/'
      printf "$(tput sgr0)"
    fi
  done
  printf "\n"
else
  printf "We have detected a problem while generating fallbacks : contact Abinit's team\n"
fi

exit
