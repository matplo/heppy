#!/bin/bash -l

savedir=${PWD}

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
source ${THISD}/util.sh
separator "${BASH_SOURCE}"

# cd ${THISD}/..
pipfilepath=$(abspath ${THISD}/../Pipfile)
[ -f ${pipfilepath} ] && export PIPENV_PIPFILE=${pipfilepath}
export WORKON_HOME=$(abspath ${THISD}/../venv)
unset PIPENV_VENV_IN_PROJECT
pipenv $@

cd ${savedir}
