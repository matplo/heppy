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

official=$(get_opt "v3" $@)
if [ ! -z ${official} ]; then
	export RUGITREPO=https://gitlab.cern.ch/RooUnfold/RooUnfold.git
	roounfold_version=3.0.1
fi

do_master=$(get_opt "master" $@)
if [ ! -z ${do_master} ]; then
    roounfold_version=master
fi

do_patch=""
do_patch=$(get_opt "patch" $@)
if [ ! -z ${do_patch} ]; then
    do_patch="-DROOUNFOLD_PATCH=${do_patch}"
else
    do_patch=""
fi

ezrasru=$(get_opt "ezra" $@)
if [ ! -z ${ezrasru} ]; then
	export RUGITREPO=https://gitlab.cern.ch/elesser/RooUnfold.git
	roounfold_version=master
	do_patch="-DROOUNFOLD_PATCH=RooUnfoldCMakePatch-ezra"
	export RUGITREPO=https://gitlab.cern.ch/mploskon/RooUnfold.git
	roounfold_version=2.1.heppy
	do_patch=""
fi

heppyru=$(get_opt "heppy" $@)
if [ ! -z ${heppyru} ]; then
	export RUGITREPO=https://gitlab.cern.ch/mploskon/RooUnfold.git
	roounfold_version=2.1.heppy
	do_patch=""
fi

echo_warning "[i] Using RooUnfold at ${RUGITREPO} ${roounfold_version}"
echo_warning "    version=${roounfold_version}"
echo_warning "    patch: ${do_patch}"


clean=$(get_opt "clean" $@)
if [ ! -z ${clean} ]; then
	separator "clean"
	rm -rf ./build_roounfold
fi

cleanall=$(get_opt "cleanall" $@)
if [ ! -z ${cleanall} ]; then
	separator "cleanall"
	rm -rf ./build_roounfold ./roounfold-${roounfold_version}
fi

mkdir -p ./build_roounfold
cd ./build_roounfold

roounfold_heppy_prefix="${THISD}/roounfold-${roounfold_version}"
separator configuration
cmake -DCMAKE_BUILD_TYPE=Release -DROOUNFOLD_VERSION="${roounfold_version}" -DROOUNFOLD_HEPPY_PREFIX=${roounfold_heppy_prefix} ${do_patch} ..
separator build
cmake --build . --target all  

cd ${cdir}

# if [ -e ${roounfold_heppy_prefix}/bin/RooUnfoldTest ]; 
if [ -e "${roounfold_heppy_prefix}/lib/libRooUnfold.so" ];
then
	if [ -e ${THISD}/roounfold-current ]; then
		rm -v ${THISD}/roounfold-current
	fi
	ln -sf ${roounfold_heppy_prefix} ${THISD}/roounfold-current
	separator summary
	echo "${roounfold_version}" > ${roounfold_heppy_prefix}/include/version.txt
	ls -l ${roounfold_heppy_prefix}/include
	ls -l ${roounfold_heppy_prefix}/lib
	ls -l ${roounfold_heppy_prefix}/bin
else
	# echo_error "[e] sorry... the build failed: no RooUnfoldTest in ${roounfold_heppy_prefix}/bin/"
	echo_error "[e] sorry... the build failed: no libRooUnfold.so in ${roounfold_heppy_prefix}/lib/"
	separator "roounfold build script done"
	exit 1
fi
separator "roounfold build script done"
