#!/bin/bash
#================================================================
#%
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-hv] [-o[file]] args ...
#%
#% DESCRIPTION
#%    Script to run the TPC-H or JCC-H benchmark on Greenplum. 
#%    You can specify three different data placement policies (FT, INT or MEM), 
#%    number of workers and number of cores per worker.
#%
#% OPTIONS
#%    -o [file], --output=[file]    Set log file (default=/dev/null)
#%                                  use DEFAULT keyword to autoname file
#%                                  The default value is /dev/null.
#%    -w, --workers                 Number of workers per CPU core, the default value is 1. 
#%    -p, --policy                  Memory policy: MEM (membind), INT (Interleaving) or FT (First-Touch).
#%                                  The default is FT 
#%    -s, --scale-factor            TPC-H scale factor (default=100).
#%    -q, --query                   TPC-H Query to perform comma separated, 
#%                                  the default is 'all of them'.
#%    -c  --cpu-cores               Number of cores to use.
#%    -b  --benchmark               Type of benchmark: TPC-H or JCC-H (default=TPC-H).
#%    -d  --directory               Query output directory.
#%                                  Default: ./results/WIC_%Y%m%d%H%M%S
#%    -t, --timelog                 Add timestamp to log ("+%y/%m/%d@%H:%M:%S")
#%    -x, --ignorelock              Ignore if lock file exists
#%    -h, --help                    Print this help
#%    -v, --version                 Print script information
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} -o DEFAULT -t -m WIC -s 100
#%
#================================================================
#-
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 0.0.1
#-    author          Alessandro Fogli <a.fogli18@imperial.ac.uk>
#-

trap 'error "${SCRIPT_NAME}: FATAL ERROR at $(date "+%HH%M") (${SECONDS}s): Interrupt signal intercepted! Exiting now..."
	2>&1 | tee -a ${fileLog:-/dev/null} >&2 ;
	exit 99;' INT QUIT TERM
trap 'cleanup' EXIT

#============================
#  FUNCTIONS
#============================

	#== fecho function ==#
fecho() {
	_Type=${1} ; shift ;
	[[ ${SCRIPT_TIMELOG_FLAG:-0} -ne 0 ]] && printf "$( date ${SCRIPT_TIMELOG_FORMAT} ) "
	echo "${*}"
	if [[ "${_Type}" = CAT ]]; then
		_Tag=""
		[[ "$1" == \[*\] ]] && _Tag="${_Tag} ${1}"
		if [[ ${SCRIPT_TIMELOG_FLAG:-0} -eq 0 ]]; then
			cat -un - | awk '$0="'"${_Tag}"' "$0; fflush();' ;
		elif [[ "${GNU_AWK_FLAG}" ]]; then # fast - compatible linux
			cat -un - | awk -v tformat="${SCRIPT_TIMELOG_FORMAT#+} " '$0=strftime(tformat)"'"${_Tag}"' "$0; fflush();' ;
		#elif [[ "${PERL_FLAG}" ]]; then # fast - if perl installed
		#	cat -un - | perl -pne 'use POSIX qw(strftime); print strftime "'${SCRIPT_TIMELOG_FORMAT}' ' "${_Tag}"' ", gmtime();'
		else # average speed but resource intensive- compatible unix/linux
			cat -un - | while read LINE; do \
				[[ ${OLDSECONDS:=$(( ${SECONDS}-1 ))} -lt ${SECONDS} ]] && OLDSECONDS=$(( ${SECONDS}+1 )) \
				&& TSTAMP="$( date ${SCRIPT_TIMELOG_FORMAT} ) "; printf "${TSTAMP}${_Tag} ${LINE}\n"; \
			done 
		fi
	fi
}

	#== custom function ==#
check_cre_file() {
	_File=${1}
	_Script_Func_name="${SCRIPT_NAME}: check_cre_file"
	[[ "x${_File}" = "x" ]] && error "${_Script_Func_name}: No parameter" && return 1
	[[ "${_File}" = "/dev/null" ]] && return 0
	[[ -e ${_File} ]] && error "${_Script_Func_name}: ${_File}: File already exists" && return 2
	touch ${_File} 1>/dev/null 2>&1
	[[ $? -ne 0 ]] && error "${_Script_Func_name}: ${_File}: Cannot create file" && return 3
	rm -f ${_File} 1>/dev/null 2>&1
	[[ $? -ne 0 ]] && error "${_Script_Func_name}: ${_File}: Cannot delete file" && return 4
	return 0
}

	#== error management functions ==#
info() { fecho INF "${*}"; }

warning() { fecho WRN "WARNING: ${*}" 1>&2 ; }

error() { fecho ERR "ERROR: ${*}" 1>&2 ; }

debug() { [[ ${flagDbg} -ne 0 ]] && fecho DBG "DEBUG: ${*}" 1>&2; }


tag() { [[ "x$1" == "x--eol" ]] && awk '$0=$0" ['$2']"; fflush();' || awk '$0="['$1'] "$0; fflush();' ; }

infotitle() { _txt="# ${*} #"; _txt2="#$( echo " ${*} " | tr '[:print:]' '#' )#" ;
	info ""; info "$_txt2"; info "$_txt"; info "$_txt2"; info "";
}

	#== startup and finish functions ==#
cleanup() { 
	#remove_workers_directory
	[[ flagScriptLock -ne 0 ]] && [[ -e "${GP_SCRIPT_DIR_LOCK}" ]] && rm -fr ${GP_SCRIPT_DIR_LOCK}; }

scriptstart() { trap 'kill -TERM ${$}; exit 99;' TERM
	info "${SCRIPT_NAME}: Start $(date "+%y/%m/%d@%H:%M:%S") with pid ${EXEC_ID} by ${USER}@${HOSTNAME}:${PWD}"\
		$( [[ ${flagOptLog} -eq 1 ]] && echo " (LOG: ${fileLog})" || echo " (NOLOG)" );
	flagMainScriptStart=1 && ipcf_save "PRG" "${EXEC_ID}" "${FULL_COMMAND}"
}

scriptfinish() {
	kill $(jobs -p) 1>/dev/null 2>&1 && warning "${SCRIPT_NAME}: Some bg jobs have been killed" ;
	[[ ${flagOptLog} -eq 1 ]] && info "${SCRIPT_NAME}: LOG file can be found here: ${fileLog}" ;
	countErr="$( ipcf_count ERR )" ; countWrn="$( ipcf_count WRN )" ;
	[[ $rc -eq 0 ]] && endType="INF" || endType="ERR";
	fecho ${endType} "${SCRIPT_NAME}: Finished$([[ $countErr -ne 0 ]] && echo " with ERROR(S)") at $(date "+%HH%M") (Time=${SECONDS}s, Error=${countErr}, Warning=${countWrn}, RC=$rc).";
	exit $rc ; }

	#== usage functions ==#
usage() { printf "Usage: "; scriptinfo usg ; }

usagefull() { scriptinfo ful ; }

scriptinfo() { headFilter="^#-"
	[[ "$1" = "usg" ]] && headFilter="^#+"
	[[ "$1" = "ful" ]] && headFilter="^#[%+]"
	[[ "$1" = "ver" ]] && headFilter="^#-"
	head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "${headFilter}" | sed -e "s/${headFilter}//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g"; }

	#== Inter Process Communication File functions (ipcf) ==#
#== Create semaphore on fd 101 #==  Not use anymore ==# 
# ipcf_cre_sem() { SCRIPT_SEM_RC="${GP_SCRIPT_DIR_LOCK}/pipe-rc-${$}";
# 	mkfifo "${SCRIPT_SEM_RC}" && exec 101<>"${SCRIPT_SEM_RC}" && rm -f "${SCRIPT_SEM_RC}"; }
#==  Use normal file instead for persistency ==# 
ipcf_save() { # Usage: ipcf_save <TYPE> <ID> <DATA>
	_Line="${1}|${2}"
	shift 2 && _Line+="|${*}"
	[[ "${*}" == "${_Line}" ]] \
		&& warning "ipcf_save: Failed: Wrong format: ${*}" && return 1
	echo "${_Line}" >> ${ipcf_file} ;
	[[ "${?}" -ne 0 ]] \
		&& warning "ipcf_save: Failed: Writing error to ${ipcf_file}: ${*}" && return 2
	return 0 ;
}

ipcf_load() { # Usage: ipcf_load <TAG> <ID> ; Return: $ipcf_return ;
	ipcf_return=""
	_Line="$( grep "^${1}${ipcf_IFS}${2}" ${ipcf_file} | tail -1 )" ;
	[[ "$( echo "${_Line}" | wc -w )" -eq 0 ]] \
		&& warning "ipcf_load: Failed: No data found: ${1} ${2}" && return 1 ;
	IFS="${ipcf_IFS}" read ipcftype ipcfid ipcfdata <<< $(echo "${_Line}") ;
	[[ "$( echo "${ipcfdata}" | wc -w )" -eq 0 ]] \
		&& warning "ipcf_load: Failed: Cannot parse - wrong format: ${1} ${2}" && return 2 ;
	ipcf_return="$ipcfdata" && echo "${ipcf_return}" && return 0 ;
}

ipcf_count() { # Usage: ipcf_count <TAG> [<ID>] ; Return: $ipcf_return ;
	ipcf_return="$( grep "^${1}${ipcf_IFS}${2:-0}" ${ipcf_file} | wc -l )";
	echo ${ipcf_return}; return 0;
}

ipcf_save_rc() { rc=$? && ipcf_return="${rc}"; ipcf_save "RC_" "${1:-0}" "${rc}"; return $? ; }

ipcf_load_rc() { # Usage: ipcf_load_rc [<ID>] ; Return: $ipcf_return ;
	ipcf_return=""; ipcfdata=""; ipcf_load "RC_" "${1:-0}" >/dev/null ;
	[[ "${?}" -ne 0 ]] && warning "ipcf_load_rc: Failed: No rc found: ${1:-0}" && return 1 ;
	[[ ! "${ipcfdata}" =~ ^-?[0-9]+$ ]] \
		&& warning "ipcf_load_rc: Failed: Not a Number (ipcfdata=${ipcfdata}): ${1:-0}" && return 2 ;
	rc="${ipcfdata}" && ipcf_return="${rc}" && echo "${rc}"; return 0 ;
}

ipcf_save_cmd() { # Usage: ipcf_save_cmd <CMD> ; Return: $ipcf_return ;
	ipcf_return=""; cmd_id="" ;
	_cpid="$(exec sh -c 'echo $PPID')"; _NewId="$( printf '%.5d' ${_cpid:-${RANDOM}} )" ;
	ipcf_save "CMD" "${_NewId}" "${*}" ;
	[[ "${?}" -ne 0 ]] && warning "ipcf_save_cmd: Failed: ${1:-0}" && return 1 ;
	cmd_id="${_NewId}" && ipcf_return="${cmd_id}" && echo "${ipcf_return}"; return 0;
}

ipcf_load_cmd() { # Usage: ipcf_load_cmd <ID> ; Return: $ipcf_return ;
	ipcf_return=""; cmd="" ;
	if [[ "x${1}"  =~ ^x[0]*$ ]]; then ipcfdata="0" ;
	else
		ipcfdata=""; ipcf_load "CMD" "${1:-0}" >/dev/null ;
		[[ "${?}" -ne 0 ]] && warning "ipcf_load_cmd: Failed: No cmd found: ${1:-0}" && return 1 ;
	fi
	cmd="${ipcfdata}" && ipcf_return="${ipcfdata}" && echo "${ipcf_return}"; return 0 ;
}

ipcf_assert_cmd() { # Usage: ipcf_assert_cmd [<ID>] ;
	cmd=""; rc=""; msg="";
	ipcf_load_cmd ${1:-0} >/dev/null
	[[ "${?}" -ne 0 ]] && warning "ipcf_assert_cmd: Failed: No cmd found: ${1:-0}" && return 1 ;
	ipcf_load_rc ${1:-0} >/dev/null
	[[ "${?}" -ne 0 ]] && warning "ipcf_assert_cmd: Failed: No rc found: ${1:-0}" && return 2 ;
	msg="[${1:-0}] Command succeeded [OK] (rc=${rc}): ${cmd} " ;
	[[ $rc -ne 0 ]] && error "$(echo ${msg} | sed -e "s/succeeded \[OK\]/failed [KO]/1")" || info "${msg}" ;
	return $rc ;
}

	#== exec_cmd function ==#
exec_cmd() { # Usage: exec_cmd <CMD> ;
	cmd_id="" ; ipcf_save_cmd "${*}" >/dev/null || return 1 ;
	{ {
		eval ${*}
		ipcf_save_rc ${cmd_id} ;
	} 2>&1 1>&3 | tag STDERR 1>&2 ; } 3>&1 2>&1 | fecho CAT "[${cmd_id}]" "${*}"
	ipcf_assert_cmd ${cmd_id}
	return $rc ;
}

wait_cmd() { # Usage: wait_cmd [<TIMEOUT>] ;
	_num_timer=0 ; _num_fail_cmd=0 ; _num_run_jobs=0 ;
	_tmp_txt="" ; _tmp_rc=0 ; _flag_nokill=0 ;
	_cmd_id_fail="" ; _cmd_id_check="" ; _cmd_id_list="" ;
	_tmp_grep_bash="exec_cmd" ;
	[[ "x$BASH" == "x" ]] && _tmp_grep_bash=""
	sleep 1
	[[ "x$1" == "x--nokill" ]] && _flag_nokill=1 && shift
	_num_timeout=${1:-32768} ;
	_num_start_line="$( grep -sn "^CHK${ipcf_IFS}" ${ipcf_file} | tail -1 | cut -f1 -d: )"
	_cmd_id_list="$( tail -n +${_num_start_line:-0} ${ipcf_file} | grep "^CMD${ipcf_IFS}" | cut -d"${ipcf_IFS}" -f2 | xargs ) " ;
	while true; do
		# Retrieve all RC from ipcf_file to Array
		unset -v _cmd_rc_a
		[[ "x$BASH" == "x" ]] && typeset -A _cmd_rc_a || declare -A _cmd_rc_a #Other: ps -ocomm= -q $$
		eval $( tail -n +${_num_start_line:-0} ${ipcf_file} | grep "^RC_${ipcf_IFS}" | cut -d"${ipcf_IFS}" -f2,3 | xargs | sed "s/\([0-9]*\)|\([0-9]*\)/_cmd_rc_a[\1]=\2\;/g" ) ;
		
		#debug "wait_cmd: \$_cmd_id_list='$_cmd_id_list' ; \${_cmd_rc_a[@]}=${_cmd_rc_a[@]}; \${!_cmd_rc_a[@]}=${!_cmd_rc_a[@]};"
		
		for __cmd_id in ${_cmd_id_list}; do
			#_tmp_rc="$(ipcf_load_rc ${__cmd_id} 2>/dev/null)"
			if [[ "${_cmd_rc_a[$__cmd_id]}" ]]; then
				_cmd_id_list=${_cmd_id_list/"${__cmd_id} "}
				_cmd_id_check+="${__cmd_id} "
				[[ "${_cmd_rc_a[$__cmd_id]}" -ne 0 ]] && _cmd_id_fail+="${__cmd_id} "
			fi
		done
		
		_num_run_jobs="$( jobs -l | grep -i "Running.*${_tmp_grep_bash}" | wc -l )"
		[[ $((_num_timer%5)) -eq 0 ]] && info "wait_cmd: Waiting for ${_num_run_jobs} bg jobs to finish: $( echo ${_cmd_id_list} | sed -e "s/\([0-9]*\)/[\1]/g" ) (elapsed: ${_num_timer}s)"
		((++_num_timer))
		if [[ $((_num_timer%_num_timeout)) -eq 0 ]]; then
			[[ "$_flag_nokill" -eq 0 ]] \
				&& kill $( jobs -l | grep -i "Running.*${_tmp_grep_bash}" | tr -d '+-' | tr -s ' ' | cut -d" " -f2 | xargs ) 1>/dev/null 2>&1 \
				&& _tmp_txt="- killed ${_num_run_jobs} bg job(s)" || _tmp_txt=""
			warning "wait_cmd: Time out reached (${_num_timer}s) ${_tmp_txt} - exit function"
			return 255
		fi
		
		[[ "$( echo "${_cmd_id_list}" | wc -w )" -eq 0 ]] && break
		
		[[ "${_num_run_jobs}" -eq 0 ]] \
			&& warning "wait_cmd: No more running jobs but there is still cmd_id left: ${_cmd_id_list}" \
			&& _cmd_id_fail+="${_cmd_id_list} " && break
		sleep 1;
	done
	
	_num_run_jobs="$( jobs -l | grep -i "Running.*${_tmp_grep_bash}" | wc -l )"
	[[ ${_num_run_jobs} -gt 1 ]] \
		&& warning "wait_cmd: No more cmd but Still have running jobs: $( jobs -p | xargs echo )"
	
	_num_fail_cmd="$( echo ${_cmd_id_fail} | wc -w )"
	[[ ${_num_fail_cmd} -eq 0 ]] && info "wait_cmd: All cmd_id succeeded" \
		|| warning "wait_cmd: ${_num_fail_cmd} cmd_id failed: $( echo ${_cmd_id_fail} | sed -e "s/\([0-9]*\)/[\1]/g" )"
	
	ipcf_save "CHK" "0" "${_cmd_id_check}"
	
	return $_num_fail_cmd
}

assert_rc() { [[ $rc -ne 0 ]] && error "${*} (RC=$rc)"; return $rc; }

print_message_with_date() {
	TSTAMP="$( date ${SCRIPT_TIMELOG_FORMAT} ) ";
	echo -n "${TSTAMP} ${1}"
}

print_message_with_date_and_newline() {
	TSTAMP="$( date ${SCRIPT_TIMELOG_FORMAT} ) ";
	echo "${TSTAMP} ${1}"
}


# display error if the script is run as root user
check_user_not_root() {
	if [[ $USER == "root" ]]; then
		error "This script must not be run as root!"
		exit 1;
	fi
}

check_ssh() {
	sshrun=$(ssh -o PasswordAuthentication=no 127.0.0.1 echo "SSH OK")
	if [[ $sshrun != "SSH OK" ]]; then
		error "Verify that you can ssh to your machine name without a password."
		error "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys"
		error "chmod 600 ~/.ssh/authorized_keys"
		exit 1
	fi
}

get_number_of_NUMA_nodes() {
	NUMACTL_OUT=$(numactl --hardware)

	TEMP=${NUMACTL_OUT##available: }
	NUM_NUMA_NODES=${TEMP::1}

	if [[ $NUM_NUMA_NODES -le 1 ]]; then
		error 'You need a multisocket system to run this benchmark:'
		error 'Number of NUMA nodes: 1'
		exit 1
	fi

	NUMACORES=$(grep ^cpu\\scores /proc/cpuinfo | uniq |  awk '{print $4}')

	TOTAL_CORES=$(($NUMACORES*$NUM_NUMA_NODES))

	create_numactl_array

	CORES_PER_WORKER=1
}

get_total_workers() {
	TOTAL_WORKERS=$(( ${WORKERS_PER_DOMAIN}*${NUM_NUMA_NODES}*${NUMACORES} ))
}

create_workers_directory() {
	for ((i = 0; i < $CORES_TO_USE; i += 1)) ; do
		exec_cmd "mkdir -p ./gpdb/gpdata$(($i+1));"
	done
} 

remove_workers_directory() {

	for ((i = 0; i < $CORES_TO_USE; i += 1)) ; do
		exec_cmd "rm -rf ./gpdb/gpdata$(($i+1))"
	done	

	exec_cmd "rm -rf ./gpdb/gpmaster/gpsne-*"
}

set_coordinator_config_file() {

	exec_cmd "sed -i \"s/replace_this_with_hostname_of_your_machine/${HOSTNAME}/g\" ${GP_SCRIPT_DIR}/gpdb/hostlist_singlenode"

	exec_cmd "sed -i \"s/MASTER_HOSTNAME=hostname_of_machine/MASTER_HOSTNAME=${HOSTNAME}/g\" ${GP_SCRIPT_DIR}/gpdb/gpinitsystem_singlenode"

	exec_cmd "sed -i \"s|MASTER_DIRECTORY=/gpmaster|MASTER_DIRECTORY=${GP_SCRIPT_DIR}/gpdb/gpmaster|g\" ${GP_SCRIPT_DIR}/gpdb/gpinitsystem_singlenode"

	
	DATA_DIRECTORY='declare -a DATA_DIRECTORY=('

	for ((i = 1; i <= $CORES_TO_USE; i += 1)) ; do
		DATA_DIRECTORY="$DATA_DIRECTORY ${GP_SCRIPT_DIR}/gpdb/gpdata$i"
	done

	DATA_DIRECTORY="$DATA_DIRECTORY)"

	exec_cmd "sed -i \"s|declare -a DATA_DIRECTORY=(/gpdata1 /gpdata2)|${DATA_DIRECTORY}|g\" ${GP_SCRIPT_DIR}/gpdb/gpinitsystem_singlenode"

	sudo sed -i "s|\"\$GPHOME/bin/pg_ctl\",|\"numactl -C 0-$(($TOTAL_CORES-1)) \$GPHOME/bin/pg_ctl\",|g" /opt/gpdb/lib/python/gppylib/commands/gp.py
	GPPY_INIT="\"numactl -C 0-$(($TOTAL_CORES-1)) \$GPHOME/bin/pg_ctl\","
}

get_port() {
		# LOW_BOUND=8080
		# RANGE=1000
		# while true; do
		# 	CANDIDATE=$[$LOW_BOUND + ($RANDOM % $RANGE)]
		# 	(echo "" >/dev/tcp/127.0.0.1/${CANDIDATE}) >/dev/null 2>&1
		# 	if [ $? -ne 0 ]; then
		# 		break
		# 	fi
		# done

		CANDIDATE=$(comm -23 <(seq 49152 65535 | sort) <(ss -tan | awk '{print $4}' | cut -d':' -f2 | sort -u) | shuf | head -n 1)
}

create_numactl_array() {
	NUMACTL_ARRAY=()
	for ((i = 0; i < $NUM_NUMA_NODES; i += 1)) ; do
		NUMACTL_OUT=$(numactl --hardware)
		NUMACTL_OUT=${NUMACTL_OUT%node ${i} size:*}
		NUMACTL_OUT=${NUMACTL_OUT##*node ${i} cpus: }
		NUMACTL_ARRAY+=("$NUMACTL_OUT")
	done
}


start_coordinator_and_workers() {

	gpinitsystem -c ./gpdb/gpinitsystem_singlenode -h ./gpdb/hostlist_singlenode -a 

	export MASTER_DATA_DIRECTORY=${GP_SCRIPT_DIR}/gpdb/gpmaster/gpsne-1

	createdb tpch

	if [[ $POLICY == "MEM" ]]; then
		for ((j = 0; j < $WORKERS_PER_DOMAIN; j += 1)) ; do
			for ((i = 1; i < $CORES_TO_USE; i += 1)) ; do
				SEG_PORT=$(ps aux | egrep ${GP_SCRIPT_DIR}/gpdb/gpdata${i}/gpsne$(($i-1)) | sed 's/^.* -p //' | head -1 | sed -e 's/\s.*$//')

				/opt/gpdb/sbin/gpsegstop.py  -v  -D ${GP_SCRIPT_DIR}/gpdb/gpdata${i}/gpsne$(($i-1)):${SEG_PORT} -m immediate -t 120 -V 'postgres (Greenplum Database) 5.28.5 build 94dd060-oss'

				numactl -C $(($i-1)) -m $(($(($i-1))%$NUM_NUMA_NODES)) /opt/gpdb/bin/pg_ctl -D ${GP_SCRIPT_DIR}/gpdb/gpdata${i}/gpsne$(($i-1)) -l ${GP_SCRIPT_DIR}/gpdb/gpdata${i}/gpsne$(($i-1))/pg_log/startup.log -w -t 600 -o " -p $SEG_PORT --gp_dbid=$(($i+1)) --gp_num_contents_in_cluster=$(($WORKERS_PER_DOMAIN*$CORES_TO_USE)) --silent-mode=true -i -M mirrorless --gp_contentid=$(($i-1)) " start 
			done
		done
	elif [[ $POLICY == "INT" ]]; then
		for ((j = 0; j < $WORKERS_PER_DOMAIN; j += 1)) ; do
			for ((i = 1; i < $CORES_TO_USE; i += 1)) ; do
				SEG_PORT=$(ps aux | egrep ${GP_SCRIPT_DIR}/gpdb/gpdata${i}/gpsne$(($i-1)) | sed 's/^.* -p //' | head -1 | sed -e 's/\s.*$//')

				/opt/gpdb/sbin/gpsegstop.py  -v  -D ${GP_SCRIPT_DIR}/gpdb/gpdata${i}/gpsne$(($i-1)):${SEG_PORT} -m immediate -t 120 -V 'postgres (Greenplum Database) 5.28.5 build 94dd060-oss'

				numactl -C $(($i-1)) -i 0-$(($NUM_NUMA_NODES-1)) /opt/gpdb/bin/pg_ctl -D ${GP_SCRIPT_DIR}/gpdb/gpdata${i}/gpsne$(($i-1)) -l ${GP_SCRIPT_DIR}/gpdb/gpdata${i}/gpsne$(($i-1))/pg_log/startup.log -w -t 600 -o " -p $SEG_PORT --gp_dbid=$(($i+1)) --gp_num_contents_in_cluster=$(($WORKERS_PER_DOMAIN*$CORES_TO_USE)) --silent-mode=true -i -M mirrorless --gp_contentid=$(($i-1)) " start 
			done
		done
	fi
	
	export MASTER_DATA_DIRECTORY=${GP_SCRIPT_DIR}/gpdb/gpmaster/gpsne-1
}

stop_coordinator_and_workers() {

	exec_cmd "gpstop -a"

	sudo sed -i "s|${GPPY_INIT}|\"\$GPHOME/bin/pg_ctl\",|g" /opt/gpdb/lib/python/gppylib/commands/gp.py
}

refine_datase() {

	rev ${GP_SCRIPT_DIR}/benchmark-greenplum/dbgen/nation.tbl | cut -c2- |rev >> nation &
	rev ${GP_SCRIPT_DIR}/benchmark-greenplum/dbgen/customer.tbl | cut -c2- |rev >> customer &
	rev ${GP_SCRIPT_DIR}/benchmark-greenplum/dbgen/partsupp.tbl | cut -c2- |rev >> partsupp &
	rev ${GP_SCRIPT_DIR}/benchmark-greenplum/dbgen/part.tbl | cut -c2- |rev >> part &
	rev ${GP_SCRIPT_DIR}/benchmark-greenplum/dbgen/region.tbl | cut -c2- |rev >> region &
	rev ${GP_SCRIPT_DIR}/benchmark-greenplum/dbgen/supplier.tbl | cut -c2- |rev >> supplier &
	rev ${GP_SCRIPT_DIR}/benchmark-greenplum/dbgen/orders.tbl | cut -c2- |rev >> orders &
	rev ${GP_SCRIPT_DIR}/benchmark-greenplum/dbgen/lineitem.tbl | cut -c2- |rev >> lineitem

	rm -rf *.tbl

	mv nation nation.tbl
	mv customer customer.tbl
	mv partsupp partsupp.tbl
	mv part part.tbl
	mv region region.tbl
	mv supplier supplier.tbl
	mv orders orders.tbl
	mv lineitem lineitem.tbl
}

run_tpch_benchmark() {
	if [[ ($QUERY == '') ]]; then
		QUERY="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22"
	fi

	for q in $(echo $QUERY | sed "s/,/ /g")
	do
		print_message_with_date_and_newline "Running Query $q..."
		for ((i = 0; i < 10; i += 1)) ; do
			if [[ $BENCH == 'TPC-H' ]]; then
				{ time psql tpch < "${GP_SCRIPT_DIR}/benchmark-greenplum/queries/q${q}.sql" ; } &>> "${OUT_DIR}/q${q}_result.txt"
			else
				{ time psql tpch < "${GP_SCRIPT_DIR}/benchmark-greenplum/jcch_queries/jq${q}.sql" ; } &>> "${OUT_DIR}/jq${q}_result.txt"
			fi		
		done
	done
}

#============================
#  FILES AND VARIABLES
#============================

	#== general variables ==#
SCRIPT_NAME="$(basename ${0})" # scriptname without path
GP_SCRIPT_DIR="$( cd $(dirname "$0") && pwd )" # script directory
SCRIPT_FULLPATH="${GP_SCRIPT_DIR}/${SCRIPT_NAME}"

SCRIPT_ID="$(scriptinfo | grep script_id | tr -s ' ' | cut -d' ' -f3)"
SCRIPT_HEADSIZE=$(grep -sn "^# END_OF_HEADER" ${0} | head -1 | cut -f1 -d:)

SCRIPT_UNIQ="${SCRIPT_NAME%.*}.${SCRIPT_ID}.${HOSTNAME%%.*}"
SCRIPT_UNIQ_DATED="${SCRIPT_UNIQ}.$(date "+%y%m%d%H%M%S").${$}"

GP_SCRIPT_DIR_TEMP="/tmp" # Make sure temporary folder is RW
GP_SCRIPT_DIR_LOCK="${GP_SCRIPT_DIR_TEMP}/${SCRIPT_UNIQ}.lock"

SCRIPT_TIMELOG_FLAG=0
SCRIPT_TIMELOG_FORMAT="+%Y/%m/%d@%H:%M:%S"
SCRIPT_TIMELOG_FORMAT_PERL="$(echo ${SCRIPT_TIMELOG_FORMAT#+} | sed 's/%y/%Y/g')"

HOSTNAME="$(hostname)"
FULL_COMMAND="${0} $*"
EXEC_DATE=$(date "+%y%m%d%H%M%S")
EXEC_ID=${$}
GNU_AWK_FLAG="$(awk --version 2>/dev/null | head -1 | grep GNU)"
PERL_FLAG="$(perl -v 1>/dev/null 2>&1 && echo 1)"

	#== Test variables ==#
MODE="WIC"
BENCH="TPC-H"
POLICY="FT"
PHYMEM=0
WORKERS_PER_DOMAIN=1
SCALE_FACTOR=100
CORES_TO_USE=64
CORES_PER_WORKER=1
TOTAL_WORKERS=0
TOTAL_CORES=0

	#== file variables ==#
filePid="${GP_SCRIPT_DIR_LOCK}/pid"
fileLog="/dev/null"

	#== function variables ==#
ipcf_file="${GP_SCRIPT_DIR_LOCK}/${SCRIPT_UNIQ_DATED}.tmp.ipcf";
ipcf_IFS="|" ; ipcf_return="" ;
rc=0 ; countErr=0 ; countWrn=0 ;

	#== NUMA variables ==#
NUMACTL_OUT=""
NUM_NUMA_NODES=0
NUMACORES=0

	#== Greenplum variables ==#


	#== option variables ==#
flagOptErr=0
flagOptLog=0
flagOptTimeLog=0
flagOptIgnoreLock=0

flagTmp=0
flagDbg=1
flagScriptLock=0
flagMainScriptStart=0


#============================
#  PARSE OPTIONS WITH GETOPTS
#============================

	#== set short options ==#
SCRIPT_OPTS=':o:txhv:b:s:q:c:d:w:p:-:'

	#== set long options associated with short one ==#
typeset -A ARRAY_OPTS
ARRAY_OPTS=(
	[workers]=w
	[scale-factor]=s
	[query]=q
	[cpu-cores]=c
	[directory]=d
	[benchmark]=b
	[policy]=p
	[timelog]=t
	[ignorelock]=x
	[output]=o
	[help]=h
	[man]=h
)

	#== parse options ==#
while getopts ${SCRIPT_OPTS} OPTION ; do
	#== translate long options to short ==#
	if [[ "x$OPTION" == "x-" ]]; then
		LONG_OPTION=$OPTARG
		LONG_OPTARG=$(echo $LONG_OPTION | grep "=" | cut -d'=' -f2)
		LONG_OPTIND=-1
		[[ "x$LONG_OPTARG" = "x" ]] && LONG_OPTIND=$OPTIND || LONG_OPTION=$(echo $OPTARG | cut -d'=' -f1)
		[[ $LONG_OPTIND -ne -1 ]] && eval LONG_OPTARG="\$$LONG_OPTIND"
		OPTION=${ARRAY_OPTS[$LONG_OPTION]}
		[[ "x$OPTION" = "x" ]] &&  OPTION="?" OPTARG="-$LONG_OPTION"
		
		if [[ $( echo "${SCRIPT_OPTS}" | grep -c "${OPTION}:" ) -eq 1 ]]; then
			if [[ "x${LONG_OPTARG}" = "x" ]] || [[ "${LONG_OPTARG}" = -* ]]; then 
				OPTION=":" OPTARG="-$LONG_OPTION"
			else
				OPTARG="$LONG_OPTARG";
				if [[ $LONG_OPTIND -ne -1 ]]; then
					[[ $OPTIND -le $Optnum ]] && OPTIND=$(( $OPTIND+1 ))
					shift $OPTIND
					OPTIND=1
				fi
			fi
		fi
	fi

	#== options follow by another option instead of argument ==#
	if [[ "x${OPTION}" != "x:" ]] && [[ "x${OPTION}" != "x?" ]] && [[ "${OPTARG}" = -* ]]; then 
		OPTARG="$OPTION" OPTION=":"
	fi

	#== manage options ==#
	case "$OPTION" in

		w ) WORKERS_PER_DOMAIN="${OPTARG}"
			if [[ ! $WORKERS_PER_DOMAIN =~ ^[0-9]+$ ]]; then
				error "invalid -w option: $WORKERS_PER_DOMAIN"
				error "-w must to be a positive number."
				exit 1;
			fi
		;;

		s ) SCALE_FACTOR="${OPTARG}"
			if [[ ! $SCALE_FACTOR =~ ^[0-9]+$ ]]; then
				error "invalid -s option: $SCALE_FACTOR"
				error "-s must to be a positive number."
				exit 1;
			fi
		;;

		q ) QUERY="${OPTARG}"

			rex='^0?[1-9]$|^1\d$|^2[0-6]$'
			if ! [[ $QUERY =~ $rex ]]; then
				if ! [[ $QUERY =~ ^0?[1-9](,0?[1-9]|,1\d|,2[0-2])+$|^1[0-9](,0?[1-9]|,1[0-9]|,2[0-2])+$|^2[0-2](,0?[1-9]|,1[0-9]|,2[0-2])+$ ]]; then
					error "Invalid -q option: $QUERY"
					error "-q must be a TPC-H query number (between 1 and 22) or a comma separated list of them."
					usagefull
					exit 1
				fi
			fi

		;;

		b ) BENCH=${OPTARG}
			if [[ $BENCH != "TPC-H" ]] && [[ $BENCH != "JCC-H" ]]; then	
				error "Invalid -b option: $BENCH"
				usagefull
				exit 1
			fi
		;;		

		d ) OUT_DIR=${OPTARG}
			if [ ! -d $OUT_DIR ]; then
				mkdir -p ${OUT_DIR}
			fi

		;;

		p ) POLICY=${OPTARG}
			case "$POLICY" in		
				"MEM")
				;;
				"FT")
				;;
				"INT")
				;;
				*)	
					error "Invalid -p option: $POLICY"
					usagefull
					exit 1
					;;
				esac
		;;		

		c ) CORES_TO_USE="${OPTARG}"
			if [[ ! $CORES_TO_USE =~ ^[0-9]+$ ]]; then
				error "invalid -c option: $CORES_TO_USE"
				error "-c must to be a positive number."
				exit 1;
			fi
			get_number_of_NUMA_nodes
			if [ $CORES_TO_USE -gt $(($NUMACORES*$NUM_NUMA_NODES*2)) ]; then
				error "invalid -c option: $CORES_TO_USE"
				error "-c must be smaller than the total number of CPU cores"
				exit 1;
			fi
		;;

		o ) fileLog="${OPTARG}"
			[[ "${OPTARG}" = *"DEFAULT" ]] && fileLog="$( echo ${OPTARG} | sed -e "s/DEFAULT/${SCRIPT_UNIQ_DATED}.log/g" )"
			flagOptLog=1
		;;
		
		t ) flagOptTimeLog=1
			SCRIPT_TIMELOG_FLAG=1
		;;
		
		x ) flagOptIgnoreLock=1
		;;
		
		h ) usagefull
			exit 0
		;;
		
		v ) scriptinfo
			exit 0
		;;
		
		: ) error "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
			flagOptErr=1
		;;
		
		? ) error "${SCRIPT_NAME}: -$OPTARG: unknown option"
			flagOptErr=1
		;;
	esac
done
shift $((${OPTIND} - 1)) ## shift options

#============================
#  MAIN SCRIPT
#============================

check_user_not_root

check_ssh

source /opt/gpdb/greenplum_path.sh

[ $flagOptErr -eq 1 ] && usagefull 1>&2 && exit 1 ## print usage if option error and exit

	#== Check/Set arguments ==#
[[ $# -gt 2 ]] && error "${SCRIPT_NAME}: Too many arguments" && usage 1>&2 && exit 2

	#== Create lock ==#
flagScriptLock=0
while [[ flagScriptLock -eq 0 ]]; do
	if mkdir ${GP_SCRIPT_DIR_LOCK} 1>/dev/null 2>&1; then
		info "${SCRIPT_NAME}: ${GP_SCRIPT_DIR_LOCK}: Locking succeeded" >&2
		flagScriptLock=1
	elif [[ ${flagOptIgnoreLock} -ne 0 ]]; then
		warning "${SCRIPT_NAME}: ${GP_SCRIPT_DIR_LOCK}: Lock detected BUT IGNORED" >&2
		GP_SCRIPT_DIR_LOCK="${SCRIPT_UNIQ_DATED}.lock"
		filePid="${GP_SCRIPT_DIR_LOCK}/pid"
		ipcf_file="${GP_SCRIPT_DIR_LOCK}/${SCRIPT_UNIQ_DATED}.tmp.ipcf";
		flagOptIgnoreLock=0
	elif [[ ! -e "${GP_SCRIPT_DIR_LOCK}" ]]; then
		error "${SCRIPT_NAME}: ${GP_SCRIPT_DIR_LOCK}: Cannot create lock folder" && exit 3
	else
		[[ ! -e ${filePid} ]] && sleep 1 # In case of concurrency
		if [[ ! -e ${filePid} ]]; then
			warning "${SCRIPT_NAME}: ${GP_SCRIPT_DIR_LOCK}: Remove stale lock (no filePid)"
		elif [[ "x$( ps -ef | grep $(head -1 "${filePid}"))" == "x" ]]; then
			warning "${SCRIPT_NAME}: ${GP_SCRIPT_DIR_LOCK}: Remove stale lock (no running pid)"
		else 
			error "${SCRIPT_NAME}: ${GP_SCRIPT_DIR_LOCK}: Lock detected (running pid: $(head -1 "${filePid}")) - exit program" && exit 3
		fi
		rm -fr "${GP_SCRIPT_DIR_LOCK}" 1>/dev/null 2>&1
		[[ "${?}" -ne 0 ]] && error "${SCRIPT_NAME}: ${GP_SCRIPT_DIR_LOCK}: Cannot delete lock folder" && exit 3
	fi
done

	#== Create files ==#
check_cre_file "${filePid}" || exit 4
check_cre_file "${ipcf_file}" || exit 4
check_cre_file "${fileLog}" || exit 4

echo "${EXEC_ID}" > ${filePid}

if [[ "${fileLog}" != "/dev/null" ]]; then
	touch ${fileLog} && fileLog="$( cd $(dirname "${fileLog}") && pwd )"/"$(basename ${fileLog})"
fi

	#== Main part ==#
	#===============#
{ scriptstart ;
	#== start your program here ==#

get_number_of_NUMA_nodes

get_total_workers

infotitle "Starting test in ${MODE} mode with ${TOTAL_WORKERS} total Workers..."

print_message_with_date_and_newline "MUMA Domains: ${NUM_NUMA_NODES}, Cores per NUMA Domain: ${NUMACORES}"

infotitle "Creating Workers directory..."

create_workers_directory

infotitle "Setting Coordinator files..."

set_coordinator_config_file

infotitle "Start Workers and Coordinator..."

start_coordinator_and_workers

print_message_with_date "Wait for the Workers..."

for ((j = 0; j < 30; j += 1)) ; do
	sleep 2
	if [[ $j -eq 29 ]]; then
		echo "."
	else
		echo -n "."
	fi
done  

infotitle "Creating output directory for queries..."

now="`date +%Y%m%d%H%M%S`";
if [[ ($OUT_DIR == '') ]]; then
	OUT_DIR="${GP_SCRIPT_DIR}/results/${MODE}_${POLICY}_${now}"
fi

exec_cmd "mkdir -p ${GP_SCRIPT_DIR}/results/${MODE}_${POLICY}_${now}"

if [[ $BENCH == 'TPC-H' ]]; then
	infotitle "Generating the TPC-H dataset with SF $SCALE_FACTOR..."
	export DSS_PATH=${SCRIPT_DIR}/benchmark-singlestore/dbgen/
	cd benchmark-greenplum/dbgen/
	exec_cmd "./dbgen -s $SCALE_FACTOR"
	infotitle "Refining the TPC-H dataset..."
	refine_datase
	cd ../../
else
	infotitle "Generating the JCC-H dataset with SF $SCALE_FACTOR..."
	export DSS_PATH=${SCRIPT_DIR}/benchmark-singlestore/JCC-H_dbgen/
	cd benchmark-greenplum/JCC-H_dbgen/
	exec_cmd "./dbgen -k -s $SCALE_FACTOR"
	infotitle "Refining the JCC-H dataset..."
	refine_datase
	cd ../../
fi

#infotitle "Creating $BENCH Tables..."

#exec_cmd "createdb tpch"

infotitle "Loading $BENCH Dataset..."


if [[ $BENCH == 'TPC-H' ]]; then
	exec_cmd "psql tpch < ./benchmark-greenplum/tpch-load.sql"
	infotitle "Running the TPC-H benchmark..."
else
	exec_cmd "psql tpch < ./benchmark-greenplum/jcch-load.sql"
	infotitle "Running the JCC-H benchmark..."
fi

exec_cmd "psql tpch < ${GP_SCRIPT_DIR}/benchmark-greenplum/tpch-index.sql"
exec_cmd "psql tpch < ${GP_SCRIPT_DIR}/benchmark-greenplum/tpch-analyze.sql"

run_tpch_benchmark

infotitle "Drop $BENCH Tables..."

exec_cmd "psql postgres < ${GP_SCRIPT_DIR}/benchmark-greenplum/drop_db.sql"

infotitle "Stop Workers and Coordinator..."

stop_coordinator_and_workers

remove_workers_directory

exec_cmd "cp /opt/gpdb/docs/cli_help/gpconfigs/gpinitsystem_singlenode ${GP_SCRIPT_DIR}/gpdb/"
exec_cmd "cp /opt/gpdb/docs/cli_help/gpconfigs/hostlist_singlenode ${GP_SCRIPT_DIR}/gpdb/"


if [[ $BENCH == 'TPC-H' ]]; then
	exec_cmd "sudo rm ${GP_SCRIPT_DIR}/benchmark-greenplum/dbgen/*.tbl"
else
	exec_cmd "sudo rm ${GP_SCRIPT_DIR}/benchmark-greenplum/JCC-H_dbgen/*.tbl"
fi

infotitle "Test completed!"

ipcf_save_rc >/dev/null

	#== end   your program here ==#
scriptfinish ; } 2>&1 | tee ${fileLog}

	#== End ==#
	#=========#
ipcf_load_rc >/dev/null
exit $rc