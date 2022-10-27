
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
. ${THISD}/../../scripts/util.sh
separator "${BASH_SOURCE}"

if [ os_linux ]; then
	export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${1}
fi

if [ os_darwin ]; then
	export DYLD_LIBRARY_PATH=${DYLD_LIBRARY_PATH}:${1}
fi

echo "<i> PYTHON_PATH to append: ${1}"
echo "<i> PYTHON_EXECUTABLE: ${2}"
${2} -c "import sys; sys.path.append('${1}'); import ROOT; ROOT.gROOT.SetBatch(True); print('[i] ROOT version from within python:',ROOT.gROOT.GetVersion());"
