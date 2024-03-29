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

separator "building fastjet ${PWD}"

clean=$(get_opt "clean" $@)
if [ ! -z ${clean} ]; then
	separator "clean"
	rm -rf ./build_fastjet
fi

cgal_opt=$(get_opt "cgal" $@)
if [ ! -z ${cgal_opt} ]; then
	echo_info "enabling CGAL"
	cgal_opt="-DENABLE_CGAL=TRUE"
else
	cgal_opt=""
fi

mkdir -p ./build_fastjet
cd ./build_fastjet

fastjet_version=3.3.4
fastjet_heppy_prefix="${THISD}/fastjet-${fastjet_version}"
separator configuration
cmake -DCMAKE_BUILD_TYPE=Release -DFASTJET_VERSION="${fastjet_version}" -DFASTJET_HEPPY_PREFIX=${fastjet_heppy_prefix} ${cgal_opt} ..
separator build
cmake --build . --target all  

cd ${cdir}

if [ -e ${fastjet_heppy_prefix}/bin/fastjet-config ]; 
then
	ln -sf ${fastjet_heppy_prefix} ${THISD}/fastjet-current
	separator summary
	${fastjet_heppy_prefix}/bin/fastjet-config --config
else
	echo_error "[e] sorry... the build failed: no fastjet-config in ${fastjet_heppy_prefix}/bin/"
	separator "fastjet build script done"
	exit 1
fi
separator "fastjet build script done"
