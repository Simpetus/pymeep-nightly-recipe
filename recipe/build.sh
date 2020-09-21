#!/bin/bash

set -xe

export CPPFLAGS="-I${PREFIX}/include ${CPPFLAGS}"

# We need to install a later MacOS SDK than the default Travis SDK for compatibilty with the Anaconda compilers.
if [[ $(uname) == Darwin ]]; then
    export MACOSX_DEPLOYMENT_TARGET="10.9"
    export CONDA_BUILD_SYSROOT="$(xcode-select -p)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk"
    echo "Downloading ${MACOSX_DEPLOYMENT_TARGET} sdk"
    curl -L -O https://github.com/phracker/MacOSX-SDKs/releases/download/10.13/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk.tar.xz
    tar -xf MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk.tar.xz -C "$(dirname "$CONDA_BUILD_SYSROOT")"
    # set minimum sdk version to our target
    plutil -replace MinimumSDKVersion -string ${MACOSX_DEPLOYMENT_TARGET} $(xcode-select -p)/Platforms/MacOSX.platform/Info.plist
    plutil -replace DTSDKName -string macosx${MACOSX_DEPLOYMENT_TARGET}internal $(xcode-select -p)/Platforms/MacOSX.platform/Info.plist
    export LDFLAGS="${LDFLAGS/-Wl,-dead_strip_dylibs/}"
fi

if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
    export CC=${PREFIX}/bin/mpicc
    export CXX=${PREFIX}/bin/mpic++
    export WITH_MPI=--with-mpi
else
    export WTIH_MPI=
fi

sh autogen.sh --prefix=${PREFIX} --with-libctl=${PREFIX}/share/libctl ${WITH_MPI}

pushd src && make -j 2 && popd
pushd libpympb && make -j 2 && popd
pushd python && make -j 2 && popd
make install

rm ${SP_DIR}/meep/_meep.a
rm ${PREFIX}/lib/libmeep.a
