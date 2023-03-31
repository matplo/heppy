#!/bin/bash

cdir=$(pwd)

function thisdir()
{
	SOURCE="${BASH_SOURCE[0]}"
	while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
	  SOURCE="$(readlink "$SOURCE")"
	  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
	done
	DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
	echo ${DIR}
}
THISD=$(thisdir)
cd ${THISD}

. ${THISD}/../../scripts/util.sh

separator "building hepmc3 ${PWD}"

clean=$(get_opt "clean" $@)
if [ ! -z ${clean} ]; then
	separator "clean"
	rm -rf ./build_hepmc3
fi

build_dir=${PWD}/build_hepmc3
mkdir -p ${build_dir}
cd ${build_dir}

hepmc3_version=3.2.5
hepmc3_heppy_prefix="${THISD}/hepmc3-${hepmc3_version}"
if [ "x${hepmc3_version}" == "x3.0.0" ]; then
	archsuffix='.tgz'
else
	archsuffix='.tar.gz'
fi

fname=HepMC3-${hepmc3_version}
if [ ! -e ${THISD}/downloads/${fname}${archsuffix} ]; then
	mkdir -p ${THISD}/downloads
	cd ${THISD}/downloads
	wget http://hepmc.web.cern.ch/hepmc/releases/${fname}${archsuffix}
	cd ${THISD}
fi

cd ${build_dir}
dirsrc="${build_dir}/HepMC3-${hepmc3_version}"
if [ -e ${THISD}/downloads/${fname}${archsuffix} ]; then
	if [ ! -d ${dirsrc} ]; then
		tar zxvf ${THISD}/downloads/${fname}${archsuffix}
	fi
else
	echo_error "[e] unable to get the sources ./downloads/${fname}${archsuffix} does not exists"
fi


if [ -d ${dirsrc} ]; then
	dirinst=${hepmc3_heppy_prefix}
	cd ${dirsrc}
	mkdir -p ${build_dir}/build
	cd ${build_dir}/build
	separator configuration
		ROOTIOFLAG=OFF
		[ ! -z ${ROOTSYS} ] && [ -d ${ROOTSYS} ] && ROOTIOFLAG=ON
		cmake \
			-DCMAKE_INSTALL_PREFIX=${dirinst} \
			-DHEPMC3_ENABLE_ROOTIO=${ROOTIOFLAG} \
			-DHEPMC3_BUILD_EXAMPLES=OFF \
			-DHEPMC3_ENABLE_TEST=OFF \
			-DHEPMC3_INSTALL_INTERFACES=ON \
	      	-DCMAKE_MACOSX_RPATH=ON \
	      	-DCMAKE_INSTALL_RPATH=${dirinst}/lib \
	      	-DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON \
	      	-DCMAKE_CXX_COMPILER=$(which g++) -DCMAKE_C_COMPILER=$(which gcc) \
	      	${dirsrc}
	separator build
	# make && make install
	# make test
	cmake --build . --target all  
	cmake --build . --target install

	cd ${cdir}
	hepmc3lib=$(find ${hepmc3_heppy_prefix} -name "libHepMC3.*" | head -n 1)
	if [ -e ${hepmc3lib} ];
	then
		separator "post build"
		echo_info "link: ln -s ${dirinst}/include/HepMC3 ${dirinst}/include/HepMC"
		rm ${dirinst}/include/HepMC
		ln -sfv ${dirinst}/include/HepMC3 ${dirinst}/include/HepMC
		echo_info "link ${hepmc3lib}"
		_libdir=${dirinst}/lib
		[ -e ${dirinst}/lib64 ] && ln -svf ${dirinst}/lib64 ${_libdir} && _libdir=${dirinst}/lib64
		[ -e ${_libdir}/libHepMC3.dylib ] && ln -svf ${_libdir}/libHepMC3.dylib ${_libdir}/libHepMC.dylib
		[ -e ${_libdir}/libHepMC3.so ] && ln -svf ${_libdir}/libHepMC3.so ${_libdir}/libHepMC.so
		separator summary
		ls $(dirname ${hepmc3lib})
		rm ${THISD}/hepmc3-current
		ln -sfv ${hepmc3_heppy_prefix} ${THISD}/hepmc3-current
	else
		echo_error "[e] sorry... the build failed: no hepmc3 library in ${hepmc3_heppy_prefix}"
		separator "hepmc3 build script done"
		exit 1
	fi
else
	echo_error "[e] no source directory ${dirsrc}"
	exit 1
fi
separator "hepmc3 build script done"
