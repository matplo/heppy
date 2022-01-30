#!/bin/bash

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
source ${THISD}/../../scripts/util.sh
separator "${BASH_SOURCE}"

if [ $(get_opt help $@) ]; then
	echo_info "${BASH_SOURCE} [--help] | [--build] | [command]"
	exit 0
fi

package_name="heppy"
version=$(cat ${THISD}/Dockerfile | grep FROM | grep root | cut -d':' -f2)
echo_info "version is: ${version}"
docker_image_local=${package_name}:${version}

### --build
if [ $(get_opt build $@) ]; then
	_previous=$(docker images --filter "label=heppy@${version}" | grep ${version})
	echo_info "pre-build image: ${_previous}"
	_previous=$(docker images --filter "label=heppy@${version}" | grep ${version} | tr -s ' ' | cut -f3 -d' ')
	echo_info "pre-build image id: ${_previous}"
	docker build -t ${docker_image_local} --label "heppy@${version}" -f ${THISD}/Dockerfile ${PWD}
	nimages=$(docker images --filter "label=heppy@${version}" | grep ${version} | wc -l)
	docker images --filter "label=heppy@${version}"
	if [ ! -z ${_previous} ]; then
		echo_info "pre-build image id: ${_previous}"
		if [ "x1" == "x${nimages}" ]; then
			echo_warning "[warning] NOT removing pre-build image id: ${_previous} since number of images left is: ${nimages}"
		else
			echo_warning "[warning] removing pre-build image id: ${_previous}"
			docker image rm ${_previous}
		fi
		docker images --filter "label=heppy@${version}"
	fi
	exit 0
fi

# prefer locally build docker image but download if not found
# note: docker images -q slower than docker image inspect (on a system with many images)
# [ "$(docker images -q ${docker_image_local} 2> /dev/null)" == "" ]
if [ ! -z $(docker images -q ${docker_image_local}) ]; then
	echo_info "will use local image ${docker_image_local}"
	echo_info "local images tagged ${docker_image_local} : $(docker images -q ${docker_image_local})"
else
	docker_image_local="nobetternick/${docker_image_local}"
	if [ ! -z $(docker images -q ${docker_image_local}) ]; then
		echo_info "will use local image ${docker_image_local}"
		echo_info "local images tagged ${docker_image_local} : $(docker images -q ${docker_image_local})"
	else
		echo_info "pulling image ${docker_image_local}"
		docker pull ${docker_image_local}
		if [ ! -z $(docker images -q ${docker_image_local}) ]; then
			echo_info "will use local image ${docker_image_local}"
			echo_info "local images tagged ${docker_image_local} : $(docker images -q ${docker_image_local})"
		else
			error "local image ${docker_image_local} does not exist. stop here."
			exit 1
		fi
	fi
fi

### --tag
if [ $(get_opt tag $@) ]; then
	if [ -z ${2} ]; then
		docker tag ${docker_image_local} nobetternick/${docker_image_local}
		docker images
		exit $?
	else
		docker tag ${docker_image_local} nobetternick/heppy:${2}
		docker images
		exit $?
	fi
fi

### --push
if [ $(get_opt push $@) ]; then
	if [ -z ${2} ]; then
		docker push nobetternick/${docker_image_local} 
		exit $?
	else
		docker push ${2}
		exit $?
	fi
fi

#### now if run
_tmp_name=$(mktemp)
_slash="/"
_dash="-"
_tmp_cont_name=${_tmp_name//$_slash/$_dash}
_tmp_cont_name="docker.root.${version}-${_tmp_cont_name}"
echo_info "instance name: ${_tmp_cont_name}"
exchange_tmp_dir=/tmp/${_tmp_cont_name}
mkdir -pv ${exchange_tmp_dir}
echo "echo ${exchange_tmp_dir}" > "${exchange_tmp_dir}/whats_my_hostdir.sh"
chmod +x ${exchange_tmp_dir}/whats_my_hostdir.sh
echo_info "temp dir is ${exchange_tmp_dir}"

cp -v ${THISD}/../bash_aliases ${exchange_tmp_dir}/.bash_aliases
cp -v ${THISD}/../in_docker_exec.sh ${exchange_tmp_dir}/
#cp -v ${THISD}/../util.sh ${exchange_tmp_dir}/
cp -v ${THISD}/../../scripts/util.sh ${exchange_tmp_dir}/

function check_ps()
{
	if [ "x${1}" == "xall" ]; then
		_exited_imgs=( $(docker ps -all | awk '{print $1,$2}') )
	else
		_exited_imgs=( $(docker ps --filter status=${1} | awk '{print $1,$2}') )
	fi
	# echo_info "Checking for ${1} containers..."
	shash=""
	for em in ${_exited_imgs[@]}
	do
		if [ "x${em}" == "x$docker_image_local" ]; then
			_runlistExited="${_runlistExited} ${shash}"
		fi
		shash=${em}
	done
	echo ${_runlistExited}
}
export -f check_ps

function check_ps_states()
{
	runlistExited=$(check_ps exited)
	nrunlistExited=$(echo ${runlistExited} | wc -w | tr -d ' ')

	runlistRunning=$(check_ps running)
	nrunlistRunning=$(echo ${runlistRunning} | wc -w | tr -d ' ')

	runlistAny=$(check_ps all)
	nrunlistAny=$(echo ${runlistAny} | wc -w | tr -d ' ')
}
export -f check_ps_states

function create_current_user_files()
{
	echo_info "creating current user files..."
	fout=${exchange_tmp_dir}/.current_user.sh
	echo "export _USERNAME=$(whoami)" > $fout
	echo "export _UID=$(id -u)" >> $fout
	echo "export _GID=$(id -g)" >> $fout
	rm -rf ${exchange_tmp_dir}/.ssh
	cp -r ${HOME}/.ssh ${exchange_tmp_dir}
}
export -f create_current_user_files

########

check_ps_states

if [ "x0" != "x$nrunlistExited" ]; then
	echo_warning "Removing container $runlistExited"
	docker rm $runlistExited
fi

create_current_user_files

_interactive="-it"
_cmnd=""

# check if a command to execute
if [ ! -z "${1}" ]; then
		_cmnd="$@"
		_interactive=""
fi

echo_info "interactive? ${_interactive}"
echo_info "cmnd to execute: ${_cmnd}"

# note about running containers
if [ "x0" != "x$nrunlistRunning" ]; then
	echo_warning "[info] note, you already have ${nrunlistRunning} running instances [${runlistRunning}]"
fi

# run the container
separator "running container"

echo_warning "[info] exchange dir in /usr/local/docker/fromhost is ${exchange_tmp_dir}"

echo "#!/bin/bash" > ${exchange_tmp_dir}/ssh_to_docker.sh
echo "_ip=\$(docker inspect -f \"{{ .NetworkSettings.IPAddress }}\" ${_tmp_cont_name})" >> ${exchange_tmp_dir}/ssh_to_docker.sh
echo "ssh -Y \${_ip} \$@" >> ${exchange_tmp_dir}/ssh_to_docker.sh
chmod +x ${exchange_tmp_dir}/ssh_to_docker.sh
echo_warning "[info] to ssh to this docker execute ${exchange_tmp_dir}/ssh_to_docker.sh"

echo "#!/bin/bash" > ${exchange_tmp_dir}/ip.sh
echo "_ip=\$(docker inspect -f \"{{ .NetworkSettings.IPAddress }}\" ${_tmp_cont_name})" >> ${exchange_tmp_dir}/ip.sh
echo "echo \${_ip}" >> ${exchange_tmp_dir}/ip.sh
chmod +x ${exchange_tmp_dir}/ip.sh
echo_warning "[info] to show docker's ip: ${exchange_tmp_dir}/ip.sh"

docker run ${_interactive} --rm \
	--mount type=bind,source="/",target=/host \
	--mount type=bind,source="${exchange_tmp_dir}",target=/usr/local/docker/fromhost \
	-v ${HOME}:/hostuserhome \
	-w /root -h ${package_name}-${version} --env-file "${THISD}/../docker.env" \
	--name ${_tmp_cont_name} \
	-m 4g \
	--user root \
	${docker_image_local} \
	${_cmnd}
separator "."

echo_info "removing ${_tmp_name} ${exchange_tmp_dir}"
rm -rf ${_tmp_name} ${exchange_tmp_dir}

separator "${BASH_SOURCE} done."
