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

separator "building hepmc2 ${PWD}"

clean=$(get_opt "clean" $@)
if [ ! -z ${clean} ]; then
	separator "clean"
	rm -rf ./build_hepmc2
fi

build_dir=${PWD}/build_hepmc2
mkdir -p ${build_dir}
cd ${build_dir}

hepmc2_version=2.06.09
hepmc2_heppy_prefix="${THISD}/hepmc2-${hepmc2_version}"

fname=HepMC-${hepmc2_version}
if [ ! -e ${THISD}/downloads/${fname}.tar.gz ]; then
	mkdir -p ${THISD}/downloads
	cd ${THISD}/downloads
	wget http://lcgapp.cern.ch/project/simu/HepMC/download/${fname}.tar.gz
	cd ${THISD}
fi

cd ${build_dir}
dirsrc="${build_dir}/HepMC-${hepmc2_version}"
if [ -e ${THISD}/downloads/${fname}.tar.gz ]; then
	if [ ! -d ${dirsrc} ]; then
		tar zxvf ${THISD}/downloads/${fname}.tar.gz
	fi
else
	echo_error "[e] unable to get the sources ./downloads/${fname}.tar.gz does not exists"
fi


if [ -d ${dirsrc} ]; then
	cd ${dirsrc}
	[ "x${version}" == "x2.06.09" ] && patch -N CMakeLists.txt -i ${THISD}/../patches/HepMC-2.06.09-CMakeLists.txt.patch
	mkdir -p ${build_dir}/build
	cd ${build_dir}/build
	separator configuration
			cmake -Dmomentum:STRING=GEV -Dlength:STRING=CM \
					-DCMAKE_INSTALL_PREFIX=${hepmc2_heppy_prefix} \
			     	-DCMAKE_BUILD_TYPE=Release \
			      	-Dbuild_docs:BOOL=OFF \
			      	-DCMAKE_MACOSX_RPATH=ON \
			      	-DCMAKE_INSTALL_RPATH=${hepmc2_heppy_prefix}/lib \
			      	-DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON \
			      	-DCMAKE_CXX_COMPILER=$(which g++) -DCMAKE_C_COMPILER=$(which gcc) \
				    ${dirsrc}
	separator build
	# make && make install
	# make test
	cmake --build . --target all  
	cmake --build . --target install

	separator "test"
	cmake --build . --target test

	cd ${cdir}
	hepmc2lib=$(find ${hepmc2_heppy_prefix} -name libHepMC.dylib)
	if [ -e ${hepmc2lib} ];
	then
		separator summary
		ls $(dirname ${hepmc2lib})
		ln -sf ${hepmc2_heppy_prefix} ${THISD}/hepmc2-current
		echo_info "looks like the libraries are there - so ignore if the tests have failed. "
	else
		echo_error "[e] sorry... the build failed: no hepmc2 library in ${hepmc2_heppy_prefix}"
		separator "hepmc2 build script done"
		exit 1
	fi
else
	echo_error "[e] no source directory ${dirsrc}"
	exit 1
fi
separator "hepmc2 build script done"
