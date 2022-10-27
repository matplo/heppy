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

separator "building roounfold ${PWD}"

export RUGITREPO=https://gitlab.cern.ch/RooUnfold/RooUnfold.git
roounfold_version=2.0.0

ezrasru=$(get_opt "ezra" $@)
if [ ! -z ${clean} ]; then
	export RUGITREPO=https://gitlab.cern.ch/elesser/RooUnfold.git
	roounfold_version=master
fi

clean=$(get_opt "clean" $@)
if [ ! -z ${clean} ]; then
	separator "clean"
	rm -rf ./build_roounfold
fi

cleanall=$(get_opt "cleanall" $@)
if [ ! -z ${cleanall} ]; then
	separator "cleanall"
	rm -rf ./build_roounfold ./roounfold-2.0.0
fi

mkdir -p ./build_roounfold
cd ./build_roounfold

roounfold_heppy_prefix="${THISD}/roounfold-${roounfold_version}"
separator configuration
cmake -DCMAKE_BUILD_TYPE=Release -DROOUNFOLD_VERSION="${roounfold_version}" -DROOUNFOLD_HEPPY_PREFIX=${roounfold_heppy_prefix} ..
separator build
cmake --build . --target all  

cd ${cdir}

if [ -e ${roounfold_heppy_prefix}/bin/RooUnfoldTest ]; 
then
	if [ -e ${THISD}/roounfold-current ]; then
		rm -v ${THISD}/roounfold-current
	fi
	ln -sf ${roounfold_heppy_prefix} ${THISD}/roounfold-current
	separator summary
	ls -l ${roounfold_heppy_prefix}/include
	ls -l ${roounfold_heppy_prefix}/lib
	ls -l ${roounfold_heppy_prefix}/bin
else
	echo_error "[e] sorry... the build failed: no RooUnfoldTest in ${roounfold_heppy_prefix}/bin/"
	separator "roounfold build script done"
	exit 1
fi
separator "roounfold build script done"
