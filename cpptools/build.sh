#!/bin/bash

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
source ${THISD}/../scripts/util.sh
separator "heppy: ${BASH_SOURCE}"

install_path=$(abspath ${THISD})
build_path=${THISD}/build

rn -rf ${build_path}

verbose=$(get_opt "verbose" $@)
if [ ! -z ${verbose} ]; then
    export VERBOSE=1
else
    unset VERBOSE
fi

build_python_iface="TRUE"
cxx_only=$(get_opt "cxx-only" $@)
if [ "x${cxx_only}" == "xyes" ]; then
    build_python_iface="FALSE"
fi

build_configuration="Release"
debug=$(get_opt "debug" $@)
if [ ! -z ${debug} ]; then
    build_configuration="Debug"
fi

echo "[i] building in ${build_path}"
mkdir -p ${build_path}
if [ -d ${build_path} ]; then
    cd ${build_path}
    cmake -DBUILD_PYTHON=${build_python_iface} ${build_python_iface} -DCMAKE_INSTALL_PREFIX=${install_path} -DCMAKE_BUILD_TYPE=${build_configuration} ${THISD}
    cmake --build . --target all -- -j $(n_cores)
    cmake --build . --target install
else
	echo "[error] unable to access build path: ${build_path}"
fi
