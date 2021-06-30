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

separator "building pythia8 ${PWD}"

clean=$(get_opt "clean" $@)
if [ ! -z ${clean} ]; then
	separator "clean"
	rm -rf ./build_pythia8
fi

mkdir -p ./build_pythia8
cd ./build_pythia8

pythia8_version=8244
# pythia8_version=8305

pythia8_heppy_prefix="${THISD}/pythia8-${pythia8_version}"
separator configuration
cmake -DCMAKE_BUILD_TYPE=Release -DPYTHIA8_VERSION="${pythia8_version}" -DPYTHIA8_HEPPY_PREFIX=${pythia8_heppy_prefix} ..
separator build
cmake --build . --target all  

cd ${cdir}

if [ -e ${pythia8_heppy_prefix}/bin/pythia8-config ]; 
then
	rm -f ${THISD}/pythia8-current
	ln -sfv ${pythia8_heppy_prefix} ${THISD}/pythia8-current
	separator summary
	${pythia8_heppy_prefix}/bin/pythia8-config --config
else
	echo_error "[e] sorry... the build failed: no pythia8-config in ${pythia8_heppy_prefix}/bin/"
	separator "pythia8 build script done"
	exit 1
fi
separator "pythia8 build script done"
