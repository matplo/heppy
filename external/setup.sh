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
source ${THISD}/../scripts/util.sh
separator "${BASH_SOURCE}"
build_with_python="python"
[ "x$(get_opt \"python2\" $@)" == "xyes" ] && build_with_python="python2"
[ "x$(get_opt \"python3\" $@)" == "xyes" ] && build_with_python="python3"
${THISD}/../scripts/make_module.sh ${build_with_python}
module use ${THISD}/../modules
module avail
separator ''
module load heppy/heppy_${build_with_python}
build_lhapdf6=$(get_opt "lhapdf6" $@)
build_hepmc2=$(get_opt "hepmc2" $@)
build_root=$(get_opt "root" $@)
build_hepmc3=$(get_opt "hepmc3" $@)
build_pythia8=$(get_opt "pythia8" $@)
build_install=$(get_opt "install" $@)
build_fastjet=$(get_opt "fastjet" $@)
build_all=$(get_opt "all" $@)
separator 'build options'
echo_info "build_all:" ${build_all}
if [ "x${build_all}" == "xyes" ]; then
	build_lhapdf6="yes"
	build_hepmc2="yes"
	build_hepmc3="yes"
	build_root="yes"
	build_pythia8="yes"
	build_install="yes"
	build_fastjet="yes"
fi
echo_info "build_lhapdf6:" ${build_lhapdf6}
echo_info "build_hepmc2:" ${build_hepmc2}
echo_info "build_hepmc3:" ${build_hepmc3}
echo_info "build_root:" ${build_root}
echo_info "build_pythia8:" ${build_pythia8}
echo_info "build_install:" ${build_install}
echo_info "build_fastjet:" ${build_fastjet}
if [ "x${build_lhapdf6}" == "xyes" ]; then
	separator "LHAPDF6"
	${THISD}/setup_lhapdf6.sh 		--version=6.2.3 	 $@
	module load heppy/${build_with_python}/LHAPDF6/6.2.3
fi
if [ "x${build_hepmc2}" == "xyes" ]; then
	separator "HEPMC2"
	${THISD}/setup_hepmc2_cmake.sh 	--version=2.06.09 	 $@
	module load heppy/${build_with_python}/HEPMC2/2.06.09
fi
if [ "x${build_root}" == "xyes" ]; then
	separator "ROOT"
	# ${THISD}/setup_root.sh 	--version=6.18.06 	 $@
	# ${THISD}/setup_root.sh 	--version=6.19.01 	 $@
	# ${THISD}/setup_root.sh 	--version=6.18.04 --source	 $@
	${THISD}/setup_root.sh 	--version=head 	 $@
	module load heppy/${build_with_python}/ROOT
fi
if [ "x${build_hepmc3}" == "xyes" ]; then
	separator "HEPMC3"
	${THISD}/setup_hepmc3.sh 		--version=3.1.1  	 $@
	module load heppy/${build_with_python}/HEPMC3/3.1.1
fi
if [ "x${build_pythia8}" == "xyes" ]; then
	separator "PYTHIA8"
	module use ${THISD}/../modules
	#module load heppy/${build_with_python}/fastjet/3.3.2
	${THISD}/setup_pythia8.sh 		--version=8235 		 $@
fi
if [ "x${build_install}" == "xyes" ]; then
	separator "redo HEPMC3"
	note "... running with install"
	. ${THISD}/setup_hepmc3.sh 		--version=3.1.1 --re $@
	module load heppy/${build_with_python}/HEPMC3/3.1.1
fi
if [ "x${build_fastjet}" == "xyes" ]; then
	separator "FASTJET"
	${THISD}/setup_fastjet.sh 		--version=3.3.3 	 $@
fi
cd ${cdir}
