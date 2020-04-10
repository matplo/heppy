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

separator "building lhapdf6 ${PWD}"

clean=$(get_opt "clean" $@)
if [ ! -z ${clean} ]; then
	separator "clean"
	rm -rf ./build_lhapdf6
fi

mkdir -p ./build_lhapdf6
cd ./build_lhapdf6

lhapdf6_version=6.2.3
lhapdf6_heppy_prefix="${THISD}/lhapdf6-${lhapdf6_version}"
separator configuration
cmake -DCMAKE_BUILD_TYPE=Release -DPYTHIA8_VERSION="${lhapdf6_version}" -DPYTHIA8_HEPPY_PREFIX=${lhapdf6_heppy_prefix} ..
separator build
cmake --build . --target all  

cd ${cdir}

if [ -e ${lhapdf6_heppy_prefix}/bin/lhapdf6-config ]; 
then
	ln -sf ${lhapdf6_heppy_prefix} ${THISD}/lhapdf6-current
	separator summary
	${lhapdf6_heppy_prefix}/bin/lhapdf6-config --config
else
	echo_error "[e] sorry... the build failed: no lhapdf6-config in ${lhapdf6_heppy_prefix}/bin/"
	separator "lhapdf6 build script done"
	exit 1
fi
separator "lhapdf6 build script done"
