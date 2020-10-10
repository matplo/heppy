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

separator "building root ${PWD}"

clean=$(get_opt "clean" $@)
if [ ! -z ${clean} ]; then
	separator "clean"
	rm -rf ./build_root
fi

build_dir=${THISD}/build_root
mkdir -p ${build_dir}
cd ${build_dir}

#root_version=v6-22-02
root_version=v6-18-04
#root_version=v6-20-04 -Dglew=OFF
root_heppy_prefix="${THISD}/root-${root_version}"
fname=root_v${root_version}.source

# if [ ! -e ${THISD}/downloads/${fname}.tar.gz ]; then
# 	mkdir -p ${THISD}/downloads
# 	cd ${THISD}/downloads
# 	wget https://root.cern/download/${fname}.tar.gz
# 	cd ${THISD}
# fi

# cd ${build_dir}
# dirsrc="${build_dir}/root-${root_version}"
# if [ -e ${THISD}/downloads/${fname}.tar.gz ]; then
# 	if [ ! -d ${dirsrc} ]; then
# 		tar zxvf ${THISD}/downloads/${fname}.tar.gz
# 	fi
# else
# 	echo_error "[e] unable to get the sources ./downloads/${fname}.tar.gz does not exists"
# fi

dirsrc="./"
if [ -d ${dirsrc} ]; then
	cd ${dirsrc}
	mkdir -p ${build_dir}/build
	cd ${build_dir}/build
	separator configuration

		_gff=$(which gfortran)
		_gcc=$(which gcc)
		_gpp=$(which g++)
		# config_opts="-Dbuiltin_xrootd=ON -Dmathmore=ON -Dxml=ON -Dvmc=ON"
		compiler_opts="-DCMAKE_C_COMPILER=${_gcc} -DCMAKE_CXX_COMPILER=${_gpp} -DCMAKE_Fortran_COMPILER=${_gff}"

		_is_mac=$(uname -s)
		if [ "x${_is_mac}" == "xDarwin" ]; then
			# this from root 6.19
			compiler_opts="${compiler_opts} -Dmacos_native=ON"
			# this for 6.18 - workaround
			_sysversion_major=$(sw_vers -productVersion | cut -d. -f 1)
			_sysversion_minor=$(sw_vers -productVersion | cut -d. -f 2)
			_sysversion="${_sysversion_major}.${_sysversion_minor}"
			_catalina="10.15"
			if [ "x${_sysversion}" == "x${_catalina}" ]; then
				_sdk_path=$(xcrun --show-sdk-path)
				compiler_opts="${compiler_opts} -DCMAKE_OSX_SYSROOT=${_sdk_path}"
			fi
		fi

		echo_info "extra options: ${config_opts} ${compiler_opts} ${root_version}"

		# cmake -DCMAKE_BUILD_TYPE\=Release ${compiler_opts} ${config_opts} ${dirsrc}
		cmake -DCMAKE_BUILD_TYPE=Release -DROOT_VERSION=${root_version} ${compiler_opts} ${config_opts} ${THISD}

	separator "build"
		cmake --build . 
		# -- -j $(n_cores)

	separator "install"
		cmake -DCMAKE_INSTALL_PREFIX=${root_heppy_prefix} -P cmake_install.cmake

	cd ${cdir}

	if [ -e ${root_heppy_prefix}/bin/root-config ];
	then
		separator summary
		rver=$(${root_heppy_prefix}/bin/root-config --version)
		echo_info "ROOT at ${rver} via root-config"
		ln -sfv ${root_heppy_prefix} ${THISD}/root-current
	else
		echo_error "[e] sorry... the build failed: no root library in ${root_heppy_prefix}"
		separator "root build script done"
		exit 1
	fi
else
	echo_error "[e] no source directory ${dirsrc}"
	exit 1
fi
separator "root build script done"
