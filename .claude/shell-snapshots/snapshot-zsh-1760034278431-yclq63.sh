# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions
add-zle-hook-widget () {
	local -a hooktypes
	zstyle -a zle-hook types hooktypes
	local usage="Usage: $funcstack[1] hook widgetname\nValid hooks are:\n  $hooktypes" 
	local opt
	local -a autoopts
	integer del list help
	while getopts "dDhLUzk" opt
	do
		case $opt in
			(d) del=1  ;;
			(D) del=2  ;;
			(h) help=1  ;;
			(L) list=1  ;;
			([Uzk]) autoopts+=(-$opt)  ;;
			(*) return 1 ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	1=${1#zle-} 
	if (( list ))
	then
		zstyle -L "zle-(${1:-${(@j:|:)hooktypes[@]}})" widgets
		return $?
	elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 ))
	then
		print -u$(( 2 - help )) $usage
		return $(( 1 - help ))
	fi
	local -aU extant_hooks
	local hook="zle-$1" 
	local fn="$2" 
	if (( del ))
	then
		if zstyle -g extant_hooks "$hook" widgets
		then
			if (( del == 2 ))
			then
				set -A extant_hooks ${extant_hooks[@]:#(<->:|)${~fn}}
			else
				set -A extant_hooks ${extant_hooks[@]:#(<->:|)$fn}
			fi
			if (( ${#extant_hooks} ))
			then
				zstyle "$hook" widgets "${extant_hooks[@]}"
			else
				zstyle -d "$hook" widgets
			fi
		fi
	else
		if [[ "$fn" = "$hook" ]]
		then
			if (( ${+widgets[$fn]} ))
			then
				print -u2 "$funcstack[1]: Cannot hook $fn to itself"
				return 1
			fi
			autoload "${autoopts[@]}" -- "$fn"
			zle -N "$fn"
			return 0
		fi
		integer i=${#options[ksharrays]}-2 
		zstyle -g extant_hooks "$hook" widgets
		if [[ ${widgets[$hook]:-} != "user:azhw:$hook" ]]
		then
			if [[ -n ${widgets[$hook]:-} ]]
			then
				zle -A "$hook" "${widgets[$hook]}"
				extant_hooks=(0:"${widgets[$hook]}" "${extant_hooks[@]}") 
			fi
			zle -N "$hook" azhw:"$hook"
		fi
		if [[ -z ${(M)extant_hooks[@]:#(<->:|)$fn} ]]
		then
			i=${${(On@)${(@M)extant_hooks[@]#<->:}%:}[i]:-0}+1 
		else
			return 0
		fi
		extant_hooks+=("${i}:${fn}") 
		zstyle -- "$hook" widgets "${extant_hooks[@]}"
		if (( ! ${+widgets[$fn]} ))
		then
			autoload "${autoopts[@]}" -- "$fn"
			zle -N -- "$fn"
		fi
		if (( ! ${+widgets[$hook]} ))
		then
			zle -N "$hook" azhw:"$hook"
		fi
	fi
}
add-zsh-hook () {
	emulate -L zsh
	local -a hooktypes
	hooktypes=(chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name) 
	local usage="Usage: add-zsh-hook hook function\nValid hooks are:\n  $hooktypes" 
	local opt
	local -a autoopts
	integer del list help
	while getopts "dDhLUzk" opt
	do
		case $opt in
			(d) del=1  ;;
			(D) del=2  ;;
			(h) help=1  ;;
			(L) list=1  ;;
			([Uzk]) autoopts+=(-$opt)  ;;
			(*) return 1 ;;
		esac
	done
	shift $(( OPTIND - 1 ))
	if (( list ))
	then
		typeset -mp "(${1:-${(@j:|:)hooktypes}})_functions"
		return $?
	elif (( help || $# != 2 || ${hooktypes[(I)$1]} == 0 ))
	then
		print -u$(( 2 - help )) $usage
		return $(( 1 - help ))
	fi
	local hook="${1}_functions" 
	local fn="$2" 
	if (( del ))
	then
		if (( ${(P)+hook} ))
		then
			if (( del == 2 ))
			then
				set -A $hook ${(P)hook:#${~fn}}
			else
				set -A $hook ${(P)hook:#$fn}
			fi
			if (( ! ${(P)#hook} ))
			then
				unset $hook
			fi
		fi
	else
		if (( ${(P)+hook} ))
		then
			if (( ${${(P)hook}[(I)$fn]} == 0 ))
			then
				typeset -ga $hook
				set -A $hook ${(P)hook} $fn
			fi
		else
			typeset -ga $hook
			set -A $hook $fn
		fi
		autoload $autoopts -- $fn
	fi
}
async () {
	async_init
}
async_flush_jobs () {
	setopt localoptions noshwordsplit
	local worker=$1 
	shift
	zpty -t $worker &> /dev/null || return 1
	async_job $worker "_killjobs"
	local junk
	if zpty -r -t $worker junk '*'
	then
		(( ASYNC_DEBUG )) && print -n "async_flush_jobs $worker: ${(V)junk}"
		while zpty -r -t $worker junk '*'
		do
			(( ASYNC_DEBUG )) && print -n "${(V)junk}"
		done
		(( ASYNC_DEBUG )) && print
	fi
	typeset -gA ASYNC_PROCESS_BUFFER
	unset "ASYNC_PROCESS_BUFFER[$worker]"
}
async_init () {
	(( ASYNC_INIT_DONE )) && return
	typeset -g ASYNC_INIT_DONE=1 
	zmodload zsh/zpty
	zmodload zsh/datetime
	autoload -Uz is-at-least
	typeset -g ASYNC_ZPTY_RETURNS_FD=0 
	[[ -o interactive ]] && [[ -o zle ]] && {
		typeset -h REPLY
		zpty _async_test :
		(( REPLY )) && ASYNC_ZPTY_RETURNS_FD=1 
		zpty -d _async_test
	}
}
async_job () {
	setopt localoptions noshwordsplit noksharrays noposixidentifiers noposixstrings
	local worker=$1 
	shift
	local -a cmd
	cmd=("$@") 
	if (( $#cmd > 1 ))
	then
		cmd=(${(q)cmd}) 
	fi
	_async_send_job $0 $worker "$cmd"
}
async_process_results () {
	setopt localoptions unset noshwordsplit noksharrays noposixidentifiers noposixstrings
	local worker=$1 
	local callback=$2 
	local caller=$3 
	local -a items
	local null=$'\0' data 
	integer -l len pos num_processed has_next
	typeset -gA ASYNC_PROCESS_BUFFER
	while zpty -r -t $worker data 2> /dev/null
	do
		ASYNC_PROCESS_BUFFER[$worker]+=$data 
		len=${#ASYNC_PROCESS_BUFFER[$worker]} 
		pos=${ASYNC_PROCESS_BUFFER[$worker][(i)$null]} 
		if (( ! len )) || (( pos > len ))
		then
			continue
		fi
		while (( pos <= len ))
		do
			items=("${(@Q)${(z)ASYNC_PROCESS_BUFFER[$worker][1,$pos-1]}}") 
			ASYNC_PROCESS_BUFFER[$worker]=${ASYNC_PROCESS_BUFFER[$worker][$pos+1,$len]} 
			len=${#ASYNC_PROCESS_BUFFER[$worker]} 
			if (( len > 1 ))
			then
				pos=${ASYNC_PROCESS_BUFFER[$worker][(i)$null]} 
			fi
			has_next=$(( len != 0 )) 
			if (( $#items == 5 ))
			then
				items+=($has_next) 
				$callback "${(@)items}"
				(( num_processed++ ))
			elif [[ -z $items ]]
			then
				
			else
				$callback "[async]" 1 "" 0 "$0:$LINENO: error: bad format, got ${#items} items (${(q)items})" $has_next
			fi
		done
	done
	(( num_processed )) && return 0
	[[ $caller = trap || $caller = watcher ]] && return 0
	return 1
}
async_register_callback () {
	setopt localoptions noshwordsplit nolocaltraps
	typeset -gA ASYNC_PTYS ASYNC_CALLBACKS
	local worker=$1 
	shift
	ASYNC_CALLBACKS[$worker]="$*" 
	if [[ ! -o interactive ]] || [[ ! -o zle ]]
	then
		trap '_async_notify_trap' WINCH
	elif [[ -o interactive ]] && [[ -o zle ]]
	then
		local fd w
		for fd w in ${(@kv)ASYNC_PTYS}
		do
			if [[ $w == $worker ]]
			then
				zle -F $fd _async_zle_watcher
				break
			fi
		done
	fi
}
async_start_worker () {
	setopt localoptions noshwordsplit noclobber
	local worker=$1 
	shift
	local -a args
	args=("$@") 
	zpty -t $worker &> /dev/null && return
	typeset -gA ASYNC_PTYS
	typeset -h REPLY
	typeset has_xtrace=0 
	if [[ -o interactive ]] && [[ -o zle ]]
	then
		args+=(-z) 
		if (( ! ASYNC_ZPTY_RETURNS_FD ))
		then
			integer -l zptyfd
			exec {zptyfd}>&1
			exec {zptyfd}>&-
		fi
	fi
	integer errfd=-1 
	if is-at-least 5.0.8
	then
		exec {errfd}>&2
	fi
	[[ -o xtrace ]] && {
		has_xtrace=1 
		unsetopt xtrace
	}
	if (( errfd != -1 ))
	then
		zpty -b $worker _async_worker -p $$ $args 2>&$errfd
	else
		zpty -b $worker _async_worker -p $$ $args
	fi
	local ret=$? 
	(( has_xtrace )) && setopt xtrace
	(( errfd != -1 )) && exec {errfd}>&-
	if (( ret ))
	then
		async_stop_worker $worker
		return 1
	fi
	if ! is-at-least 5.0.8
	then
		sleep 0.001
	fi
	if [[ -o interactive ]] && [[ -o zle ]]
	then
		if (( ! ASYNC_ZPTY_RETURNS_FD ))
		then
			REPLY=$zptyfd 
		fi
		ASYNC_PTYS[$REPLY]=$worker 
	fi
}
async_stop_worker () {
	setopt localoptions noshwordsplit
	local ret=0 worker k v 
	for worker in $@
	do
		for k v in ${(@kv)ASYNC_PTYS}
		do
			if [[ $v == $worker ]]
			then
				zle -F $k
				unset "ASYNC_PTYS[$k]"
			fi
		done
		async_unregister_callback $worker
		zpty -d $worker 2> /dev/null || ret=$? 
		typeset -gA ASYNC_PROCESS_BUFFER
		unset "ASYNC_PROCESS_BUFFER[$worker]"
	done
	return $ret
}
async_unregister_callback () {
	typeset -gA ASYNC_CALLBACKS
	unset "ASYNC_CALLBACKS[$1]"
}
async_worker_eval () {
	setopt localoptions noshwordsplit noksharrays noposixidentifiers noposixstrings
	local worker=$1 
	shift
	local -a cmd
	cmd=("$@") 
	if (( $#cmd > 1 ))
	then
		cmd=(${(q)cmd}) 
	fi
	_async_send_job $0 $worker "_async_eval $cmd"
}
azhw:zle-history-line-set () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-isearch-exit () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-isearch-update () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-keymap-select () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-line-finish () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-line-init () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
azhw:zle-line-pre-redraw () {
	local -a hook_widgets
	local hook
	zstyle -a $WIDGET widgets hook_widgets
	for hook in "${(@)${(@on)hook_widgets[@]}#<->:}"
	do
		if [[ "$hook" = user:* ]]
		then
			zle "$hook" -f "nolast" -N -- "$@"
		else
			zle "$hook" -f "nolast" -Nw -- "$@"
		fi || return
	done
	return 0
}
compaudit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compdef () {
	local opt autol type func delete eval new i ret=0 cmd svc 
	local -a match mbegin mend
	emulate -L zsh
	setopt extendedglob
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	while getopts "anpPkKde" opt
	do
		case "$opt" in
			(a) autol=yes  ;;
			(n) new=yes  ;;
			([pPkK]) if [[ -n "$type" ]]
				then
					print -u2 "$0: type already set to $type"
					return 1
				fi
				if [[ "$opt" = p ]]
				then
					type=pattern 
				elif [[ "$opt" = P ]]
				then
					type=postpattern 
				elif [[ "$opt" = K ]]
				then
					type=widgetkey 
				else
					type=key 
				fi ;;
			(d) delete=yes  ;;
			(e) eval=yes  ;;
		esac
	done
	shift OPTIND-1
	if (( ! $# ))
	then
		print -u2 "$0: I need arguments"
		return 1
	fi
	if [[ -z "$delete" ]]
	then
		if [[ -z "$eval" ]] && [[ "$1" = *\=* ]]
		then
			while (( $# ))
			do
				if [[ "$1" = *\=* ]]
				then
					cmd="${1%%\=*}" 
					svc="${1#*\=}" 
					func="$_comps[${_services[(r)$svc]:-$svc}]" 
					[[ -n ${_services[$svc]} ]] && svc=${_services[$svc]} 
					[[ -z "$func" ]] && func="${${_patcomps[(K)$svc][1]}:-${_postpatcomps[(K)$svc][1]}}" 
					if [[ -n "$func" ]]
					then
						_comps[$cmd]="$func" 
						_services[$cmd]="$svc" 
					else
						print -u2 "$0: unknown command or service: $svc"
						ret=1 
					fi
				else
					print -u2 "$0: invalid argument: $1"
					ret=1 
				fi
				shift
			done
			return ret
		fi
		func="$1" 
		[[ -n "$autol" ]] && autoload -rUz "$func"
		shift
		case "$type" in
			(widgetkey) while [[ -n $1 ]]
				do
					if [[ $# -lt 3 ]]
					then
						print -u2 "$0: compdef -K requires <widget> <comp-widget> <key>"
						return 1
					fi
					[[ $1 = _* ]] || 1="_$1" 
					[[ $2 = .* ]] || 2=".$2" 
					[[ $2 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$1" "$2" "$func"
					if [[ -n $new ]]
					then
						bindkey "$3" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] && bindkey "$3" "$1"
					else
						bindkey "$3" "$1"
					fi
					shift 3
				done ;;
			(key) if [[ $# -lt 2 ]]
				then
					print -u2 "$0: missing keys"
					return 1
				fi
				if [[ $1 = .* ]]
				then
					[[ $1 = .menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" "$1" "$func"
				else
					[[ $1 = menu-select ]] && zmodload -i zsh/complist
					zle -C "$func" ".$1" "$func"
				fi
				shift
				for i
				do
					if [[ -n $new ]]
					then
						bindkey "$i" | IFS=$' \t' read -A opt
						[[ $opt[-1] = undefined-key ]] || continue
					fi
					bindkey "$i" "$func"
				done ;;
			(*) while (( $# ))
				do
					if [[ "$1" = -N ]]
					then
						type=normal 
					elif [[ "$1" = -p ]]
					then
						type=pattern 
					elif [[ "$1" = -P ]]
					then
						type=postpattern 
					else
						case "$type" in
							(pattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_patcomps[$match[1]]="=$match[2]=$func" 
								else
									_patcomps[$1]="$func" 
								fi ;;
							(postpattern) if [[ $1 = (#b)(*)=(*) ]]
								then
									_postpatcomps[$match[1]]="=$match[2]=$func" 
								else
									_postpatcomps[$1]="$func" 
								fi ;;
							(*) if [[ "$1" = *\=* ]]
								then
									cmd="${1%%\=*}" 
									svc=yes 
								else
									cmd="$1" 
									svc= 
								fi
								if [[ -z "$new" || -z "${_comps[$1]}" ]]
								then
									_comps[$cmd]="$func" 
									[[ -n "$svc" ]] && _services[$cmd]="${1#*\=}" 
								fi ;;
						esac
					fi
					shift
				done ;;
		esac
	else
		case "$type" in
			(pattern) unset "_patcomps[$^@]" ;;
			(postpattern) unset "_postpatcomps[$^@]" ;;
			(key) print -u2 "$0: cannot restore key bindings"
				return 1 ;;
			(*) unset "_comps[$^@]" ;;
		esac
	fi
}
compdump () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compinit () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compinstall () {
	# undefined
	builtin autoload -XUz /usr/share/zsh/5.9/functions
}
compress-audio () {
	set -x
	lame -V6 --vbr-new --resample 22 -m m $1
}
compress-video () {
	set -x
	ffmpeg -i $1 -c:v libx264 -crf 23 ${1}_compressed.mp4
}
eg-papi () {
	set -x
	curl -H "Authorization: Bearer $YNAB_API_ACCESS_TOKEN_DEV" -H "Content-Type: application/json" ${@:2} http://localhost:3000/papi/v1/$1
}
gac () {
	echo "Adding and committing all changes..."
	git add --all :/ && git commit -m "${1}"
}
gacp () {
	gac $1 && git push -u
}
gb () {
	if [ -z "$1" ]
	then
		gbranch
	else
		BRANCH=$1 
		git switch $1
		git pull --ff-only
	fi
}
gbcompare () {
	if [ -z "$1" ]
	then
		echo "You must supply the branch to compare against."
		return 1
	fi
	echo "Showing commits on current branch that are not on the branch '$1'..."
	git log --cherry-pick --no-merges --left-only $(git branch --show-current)...${1}
}
gbpurge () {
	echo "Pruning local branches that have have a deleted remote (origin)..."
	git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
}
gbranch () {
	with_remote=() 
	without_remote=() 
	for branch in $(git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads/)
	do
		if git branch -r | grep -q "origin/$branch"
		then
			with_remote+=("$branch") 
		else
			without_remote+=("$branch") 
		fi
	done
	echo -e "\033[34mBranches with a remote:\033[0m"
	for branch in "${with_remote[@]}"
	do
		git for-each-ref --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) (%(color:green)%(committerdate:relative)%(color:reset))' refs/heads/"$branch"
	done
	echo -e "\033[34mBranches with NO remote:\033[0m"
	for branch in "${without_remote[@]}"
	do
		git for-each-ref --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(contents:subject) (%(color:green)%(committerdate:relative)%(color:reset))' refs/heads/"$branch"
	done
}
gcomp () {
	URL="https://github.$(git config remote.origin.url | cut -f2 -d. | tr ':' /)/compare/${1}...${2}" 
	echo $URL
	open $URL
}
getent () {
	if [[ $1 = hosts ]]
	then
		sed 's/#.*//' /etc/$1 | grep -w $2
	elif [[ $2 = <-> ]]
	then
		grep ":$2:[^:]*$" /etc/$1
	else
		grep "^$2:" /etc/$1
	fi
}
gh-api () {
	if [ -z "$1" ]
	then
		echo "Example usage:\n  gh-api bradymholt/myrepo/statuses\n  gh-api bradymholt/myrepo/statuses/ed94da '{\"state\":\"success\",\"description\":\"Tests\",\"context\":\"Tests\"}'"
		return 1
	fi
	set -x
	if [ -z "$2" ]
	then
		curl -H "Authorization: token $GITHUB_API_TOKEN" -H "Content-Type: application/json" https://api.github.com/repos/$1
	else
		curl -H "Authorization: token $GITHUB_API_TOKEN" -H "Content-Type: application/json" -d "${@:2}" https://api.github.com/repos/$1
	fi
}
gmove () {
	echo "Moving commits on current branch to a new branch..."
	if [ -z "$1" ]
	then
		echo "New branch name required!"
		exit 0
	fi
	CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD) 
	echo "Moving local commits on ${CURRENT_BRANCH} to $1"
	git branch ${1} && git reset --hard origin/${CURRENT_BRANCH} && git checkout ${1}
}
gpr () {
	BRANCH=$(git branch | grep ^* | sed 's/* //' ) 
	URL="https://github.$(git config remote.origin.url | cut -f2 -d. | tr ':' /)/pull/${BRANCH}" 
	echo $URL
	open $URL
}
gsqa () {
	if [ -z "$1" ]
	then
		echo "You must supply the branch to compare against."
		return 1
	fi
	git reset --soft $1 && git commit --edit -m"$(git log --format=%B --reverse HEAD..HEAD@{1})"
}
is-at-least () {
	emulate -L zsh
	local IFS=".-" min_cnt=0 ver_cnt=0 part min_ver version order 
	min_ver=(${=1}) 
	version=(${=2:-$ZSH_VERSION} 0) 
	while (( $min_cnt <= ${#min_ver} ))
	do
		while [[ "$part" != <-> ]]
		do
			(( ++ver_cnt > ${#version} )) && return 0
			if [[ ${version[ver_cnt]} = *[0-9][^0-9]* ]]
			then
				order=(${version[ver_cnt]} ${min_ver[ver_cnt]}) 
				if [[ ${version[ver_cnt]} = <->* ]]
				then
					[[ $order != ${${(On)order}} ]] && return 1
				else
					[[ $order != ${${(O)order}} ]] && return 1
				fi
				[[ $order[1] != $order[2] ]] && return 0
			fi
			part=${version[ver_cnt]##*[^0-9]} 
		done
		while true
		do
			(( ++min_cnt > ${#min_ver} )) && return 0
			[[ ${min_ver[min_cnt]} = <-> ]] && break
		done
		(( part > min_ver[min_cnt] )) && return 0
		(( part < min_ver[min_cnt] )) && return 1
		part='' 
	done
}
load_1pwd_secret () {
	local SECRET_URI="$1" 
	local ACCOUNT="$2" 
	if [[ -z "$SECRET_URI" || -z "$ACCOUNT" ]]
	then
		echo "Usage: load_1pwd_secret <secret_URI> <account_id>"
		return 1
	fi
	local TOKEN_FILE="/tmp/${ACCOUNT}_${SECRET_URI//\//_}" 
	if [[ -f "$TOKEN_FILE" ]]
	then
		cat "$TOKEN_FILE"
	else
		local SECRET=$(op read "$SECRET_URI" --account "$ACCOUNT") 
		if [[ $? -eq 0 ]]
		then
			echo "$SECRET" > "$TOKEN_FILE"
			chmod 600 "$TOKEN_FILE"
			echo "$SECRET"
		else
			echo "Failed to read secret from 1Password"
			return 1
		fi
	fi
}
prompt () {
	local -a prompt_opts theme_active
	zstyle -g theme_active :prompt-theme restore || {
		[[ -o promptbang ]] && prompt_opts+=(bang) 
		[[ -o promptcr ]] && prompt_opts+=(cr) 
		[[ -o promptpercent ]] && prompt_opts+=(percent) 
		[[ -o promptsp ]] && prompt_opts+=(sp) 
		[[ -o promptsubst ]] && prompt_opts+=(subst) 
		zstyle -e :prompt-theme restore "
        zstyle -d :prompt-theme restore
        prompt_default_setup
        ${PS1+PS1=${(q+)PS1}}
        ${PS2+PS2=${(q+)PS2}}
        ${PS3+PS3=${(q+)PS3}}
        ${PS4+PS4=${(q+)PS4}}
        ${RPS1+RPS1=${(q+)RPS1}}
        ${RPS2+RPS2=${(q+)RPS2}}
        ${RPROMPT+RPROMPT=${(q+)RPROMPT}}
        ${RPROMPT2+RPROMPT2=${(q+)RPROMPT2}}
        ${PSVAR+PSVAR=${(q+)PSVAR}}
        prompt_opts=( $prompt_opts[*] )
        reply=( yes )
    "
	}
	set_prompt "$@"
	(( ${#prompt_opts} )) && setopt noprompt{bang,cr,percent,sp,subst} "prompt${^prompt_opts[@]}"
	true
}
prompt_adam1_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_adam2_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_bart_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_bigfade_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_cleanup () {
	local -a cleanup_hooks theme_active
	if ! zstyle -g cleanup_hooks :prompt-theme cleanup
	then
		if ! zstyle -g theme_active :prompt-theme restore
		then
			print -u2 "prompt_cleanup: no prompt theme active"
			return 1
		fi
		zstyle -e :prompt-theme cleanup 'zstyle -d :prompt-theme cleanup;' 'reply=(yes)'
		zstyle -g cleanup_hooks :prompt-theme cleanup
	fi
	cleanup_hooks+=(';' "$@") 
	zstyle -e :prompt-theme cleanup "${cleanup_hooks[@]}"
}
prompt_clint_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_default_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_elite2_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_elite_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_fade_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_fire_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_off_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_oliver_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_preview_safely () {
	emulate -L zsh
	print -P "%b%f%k"
	if [[ -z "$prompt_themes[(r)$1]" ]]
	then
		print "Unknown theme: $1"
		return
	fi
	(
		zstyle -t :prompt-theme cleanup
		typeset +f prompt_${1}_preview >&/dev/null || prompt_${1}_setup
		if typeset +f prompt_${1}_preview >&/dev/null
		then
			prompt_${1}_preview "$@[2,-1]"
		else
			prompt_preview_theme "$@"
		fi
	)
}
prompt_preview_theme () {
	emulate -L zsh
	local -a prompt_opts
	print -n "$1 theme"
	(( $#* > 1 )) && print -n " with parameters \`$*[2,-1]'"
	print ":"
	zstyle -t :prompt-theme cleanup
	prompt_${1}_setup "$@[2,-1]"
	(( ${#prompt_opts} )) && setopt noprompt{bang,cr,percent,sp,subst} "prompt${^prompt_opts[@]}"
	[[ -n ${chpwd_functions[(r)prompt_${1}_chpwd]} ]] && prompt_${1}_chpwd
	[[ -n ${precmd_functions[(r)prompt_${1}_precmd]} ]] && prompt_${1}_precmd
	[[ -o promptcr ]] && print -n $'\r'
	:
	print -P -- "${PS1}command arg1 arg2 ... argn"
	[[ -n ${preexec_functions[(r)prompt_${1}_preexec]} ]] && prompt_${1}_preexec
}
prompt_pure_async_callback () {
	setopt localoptions noshwordsplit
	local job=$1 code=$2 output=$3 exec_time=$4 next_pending=$6 
	local do_render=0 
	case $job in
		(\[async]) if (( code == 2 )) || (( code == 3 )) || (( code == 130 ))
			then
				typeset -g prompt_pure_async_inited=0 
				async_stop_worker prompt_pure
				prompt_pure_async_init
				prompt_pure_async_tasks
				unset prompt_pure_async_render_requested
			fi ;;
		(\[async/eval]) if (( code ))
			then
				prompt_pure_async_tasks
			fi ;;
		(prompt_pure_async_vcs_info) local -A info
			typeset -gA prompt_pure_vcs_info
			info=("${(Q@)${(z)output}}") 
			local -H MATCH MBEGIN MEND
			if [[ $info[pwd] != $PWD ]]
			then
				return
			fi
			if [[ $info[top] = $prompt_pure_vcs_info[top] ]]
			then
				if [[ $prompt_pure_vcs_info[pwd] = ${PWD}* ]]
				then
					prompt_pure_vcs_info[pwd]=$PWD 
				fi
			else
				prompt_pure_vcs_info[pwd]=$PWD 
			fi
			unset MATCH MBEGIN MEND
			[[ -n $info[top] ]] && [[ -z $prompt_pure_vcs_info[top] ]] && prompt_pure_async_refresh
			prompt_pure_vcs_info[branch]=$info[branch] 
			prompt_pure_vcs_info[top]=$info[top] 
			prompt_pure_vcs_info[action]=$info[action] 
			do_render=1  ;;
		(prompt_pure_async_git_aliases) if [[ -n $output ]]
			then
				prompt_pure_git_fetch_pattern+="|$output" 
			fi ;;
		(prompt_pure_async_git_dirty) local prev_dirty=$prompt_pure_git_dirty 
			if (( code == 0 ))
			then
				unset prompt_pure_git_dirty
			else
				typeset -g prompt_pure_git_dirty="*" 
			fi
			[[ $prev_dirty != $prompt_pure_git_dirty ]] && do_render=1 
			(( $exec_time > 5 )) && prompt_pure_git_last_dirty_check_timestamp=$EPOCHSECONDS  ;;
		(prompt_pure_async_git_fetch | prompt_pure_async_git_arrows) case $code in
				(0) local REPLY
					prompt_pure_check_git_arrows ${(ps:\t:)output}
					if [[ $prompt_pure_git_arrows != $REPLY ]]
					then
						typeset -g prompt_pure_git_arrows=$REPLY 
						do_render=1 
					fi ;;
				(97) if [[ -n $prompt_pure_git_arrows ]]
					then
						typeset -g prompt_pure_git_arrows= 
						do_render=1 
					fi ;;
				(99 | 98)  ;;
				(*) if [[ -n $prompt_pure_git_arrows ]]
					then
						unset prompt_pure_git_arrows
						do_render=1 
					fi ;;
			esac ;;
		(prompt_pure_async_git_stash) local prev_stash=$prompt_pure_git_stash 
			typeset -g prompt_pure_git_stash=$output 
			[[ $prev_stash != $prompt_pure_git_stash ]] && do_render=1  ;;
	esac
	if (( next_pending ))
	then
		(( do_render )) && typeset -g prompt_pure_async_render_requested=1 
		return
	fi
	[[ ${prompt_pure_async_render_requested:-$do_render} = 1 ]] && prompt_pure_preprompt_render
	unset prompt_pure_async_render_requested
}
prompt_pure_async_git_aliases () {
	setopt localoptions noshwordsplit
	local -a gitalias pullalias
	gitalias=(${(@f)"$(command git config --get-regexp "^alias\.")"}) 
	for line in $gitalias
	do
		parts=(${(@)=line}) 
		aliasname=${parts[1]#alias.} 
		shift parts
		if [[ $parts =~ ^(.*\ )?(pull|fetch)(\ .*)?$ ]]
		then
			pullalias+=($aliasname) 
		fi
	done
	print -- ${(j:|:)pullalias}
}
prompt_pure_async_git_arrows () {
	setopt localoptions noshwordsplit
	command git rev-list --left-right --count HEAD...@'{u}'
}
prompt_pure_async_git_dirty () {
	setopt localoptions noshwordsplit
	local untracked_dirty=$1 
	local untracked_git_mode=$(command git config --get status.showUntrackedFiles) 
	if [[ "$untracked_git_mode" != 'no' ]]
	then
		untracked_git_mode='normal' 
	fi
	export GIT_OPTIONAL_LOCKS=0 
	if [[ $untracked_dirty = 0 ]]
	then
		command git diff --no-ext-diff --quiet --exit-code
	else
		test -z "$(command git status --porcelain -u${untracked_git_mode})"
	fi
	return $?
}
prompt_pure_async_git_fetch () {
	setopt localoptions noshwordsplit
	local only_upstream=${1:-0} 
	export GIT_TERMINAL_PROMPT=0 
	export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-"ssh"} -o BatchMode=yes" 
	export GPG_TTY= 
	local -a remote
	if ((only_upstream))
	then
		local ref
		ref=$(command git symbolic-ref -q HEAD) 
		remote=($(command git for-each-ref --format='%(upstream:remotename) %(refname)' $ref)) 
		if [[ -z $remote[1] ]]
		then
			return 97
		fi
	fi
	local fail_code=99 
	setopt localtraps monitor
	trap - HUP
	trap '
		# Unset trap to prevent infinite loop
		trap - CHLD
		if [[ $jobstates = suspended* ]]; then
			# Set fail code to password prompt and kill the fetch.
			fail_code=98
			kill %%
		fi
	' CHLD
	command git -c gc.auto=0 fetch --quiet --no-tags --recurse-submodules=no $remote &> /dev/null &
	wait $! || return $fail_code
	unsetopt monitor
	prompt_pure_async_git_arrows
}
prompt_pure_async_git_stash () {
	git rev-list --walk-reflogs --count refs/stash
}
prompt_pure_async_init () {
	typeset -g prompt_pure_async_inited
	if ((${prompt_pure_async_inited:-0}))
	then
		return
	fi
	prompt_pure_async_inited=1 
	async_start_worker "prompt_pure" -u -n
	async_register_callback "prompt_pure" prompt_pure_async_callback
	async_worker_eval "prompt_pure" prompt_pure_async_renice
}
prompt_pure_async_refresh () {
	setopt localoptions noshwordsplit
	if [[ -z $prompt_pure_git_fetch_pattern ]]
	then
		typeset -g prompt_pure_git_fetch_pattern="pull|fetch" 
		async_job "prompt_pure" prompt_pure_async_git_aliases
	fi
	async_job "prompt_pure" prompt_pure_async_git_arrows
	if (( ${PURE_GIT_PULL:-1} )) && [[ $prompt_pure_vcs_info[top] != $HOME ]]
	then
		zstyle -t :prompt:pure:git:fetch only_upstream
		local only_upstream=$((? == 0)) 
		async_job "prompt_pure" prompt_pure_async_git_fetch $only_upstream
	fi
	integer time_since_last_dirty_check=$(( EPOCHSECONDS - ${prompt_pure_git_last_dirty_check_timestamp:-0} )) 
	if (( time_since_last_dirty_check > ${PURE_GIT_DELAY_DIRTY_CHECK:-1800} ))
	then
		unset prompt_pure_git_last_dirty_check_timestamp
		async_job "prompt_pure" prompt_pure_async_git_dirty ${PURE_GIT_UNTRACKED_DIRTY:-1}
	fi
	if zstyle -t ":prompt:pure:git:stash" show
	then
		async_job "prompt_pure" prompt_pure_async_git_stash
	else
		unset prompt_pure_git_stash
	fi
}
prompt_pure_async_renice () {
	setopt localoptions noshwordsplit
	if command -v renice > /dev/null
	then
		command renice +15 -p $$
	fi
	if command -v ionice > /dev/null
	then
		command ionice -c 3 -p $$
	fi
}
prompt_pure_async_tasks () {
	setopt localoptions noshwordsplit
	prompt_pure_async_init
	async_worker_eval "prompt_pure" builtin cd -q $PWD
	typeset -gA prompt_pure_vcs_info
	local -H MATCH MBEGIN MEND
	if [[ $PWD != ${prompt_pure_vcs_info[pwd]}* ]]
	then
		async_flush_jobs "prompt_pure"
		unset prompt_pure_git_dirty
		unset prompt_pure_git_last_dirty_check_timestamp
		unset prompt_pure_git_arrows
		unset prompt_pure_git_stash
		unset prompt_pure_git_fetch_pattern
		prompt_pure_vcs_info[branch]= 
		prompt_pure_vcs_info[top]= 
	fi
	unset MATCH MBEGIN MEND
	async_job "prompt_pure" prompt_pure_async_vcs_info
	[[ -n $prompt_pure_vcs_info[top] ]] || return
	prompt_pure_async_refresh
}
prompt_pure_async_vcs_info () {
	setopt localoptions noshwordsplit
	zstyle ':vcs_info:*' enable git
	zstyle ':vcs_info:*' use-simple true
	zstyle ':vcs_info:*' max-exports 3
	zstyle ':vcs_info:git*' formats '%b' '%R' '%a'
	zstyle ':vcs_info:git*' actionformats '%b' '%R' '%a'
	vcs_info
	local -A info
	info[pwd]=$PWD 
	info[branch]=${vcs_info_msg_0_//\%/%%} 
	info[top]=$vcs_info_msg_1_ 
	info[action]=$vcs_info_msg_2_ 
	print -r - ${(@kvq)info}
}
prompt_pure_check_cmd_exec_time () {
	integer elapsed
	(( elapsed = EPOCHSECONDS - ${prompt_pure_cmd_timestamp:-$EPOCHSECONDS} ))
	typeset -g prompt_pure_cmd_exec_time= 
	(( elapsed > ${PURE_CMD_MAX_EXEC_TIME:-5} )) && {
		prompt_pure_human_time_to_var $elapsed "prompt_pure_cmd_exec_time"
	}
}
prompt_pure_check_git_arrows () {
	setopt localoptions noshwordsplit
	local arrows left=${1:-0} right=${2:-0} 
	(( right > 0 )) && arrows+=${PURE_GIT_DOWN_ARROW:-⇣} 
	(( left > 0 )) && arrows+=${PURE_GIT_UP_ARROW:-⇡} 
	[[ -n $arrows ]] || return
	typeset -g REPLY=$arrows 
}
prompt_pure_human_time_to_var () {
	local human total_seconds=$1 var=$2 
	local days=$(( total_seconds / 60 / 60 / 24 )) 
	local hours=$(( total_seconds / 60 / 60 % 24 )) 
	local minutes=$(( total_seconds / 60 % 60 )) 
	local seconds=$(( total_seconds % 60 )) 
	(( days > 0 )) && human+="${days}d " 
	(( hours > 0 )) && human+="${hours}h " 
	(( minutes > 0 )) && human+="${minutes}m " 
	human+="${seconds}s" 
	typeset -g "${var}"="${human}"
}
prompt_pure_is_inside_container () {
	local -r cgroup_file='/proc/1/cgroup' 
	local -r nspawn_file='/run/host/container-manager' 
	[[ -r "$cgroup_file" && "$(< $cgroup_file)" = *(lxc|docker)* ]] || [[ "$container" == "lxc" ]] || [[ "$container" == "oci" ]] || [[ "$container" == "podman" ]] || [[ -r "$nspawn_file" ]]
}
prompt_pure_precmd () {
	setopt localoptions noshwordsplit
	prompt_pure_check_cmd_exec_time
	unset prompt_pure_cmd_timestamp
	prompt_pure_set_title 'expand-prompt' '%~'
	prompt_pure_set_colors
	prompt_pure_async_tasks
	psvar[12]= 
	if [[ -n $CONDA_DEFAULT_ENV ]]
	then
		psvar[12]="${CONDA_DEFAULT_ENV//[$'\t\r\n']}" 
	fi
	if [[ -n $VIRTUAL_ENV ]] && [[ -z $VIRTUAL_ENV_DISABLE_PROMPT || $VIRTUAL_ENV_DISABLE_PROMPT = 12 ]]
	then
		psvar[12]="${VIRTUAL_ENV:t}" 
		export VIRTUAL_ENV_DISABLE_PROMPT=12 
	fi
	if zstyle -T ":prompt:pure:environment:nix-shell" show
	then
		if [[ -n $IN_NIX_SHELL ]]
		then
			psvar[12]="${name:-nix-shell}" 
		fi
	fi
	prompt_pure_reset_prompt_symbol
	prompt_pure_preprompt_render "precmd"
	if [[ -n $ZSH_THEME ]]
	then
		print "WARNING: Oh My Zsh themes are enabled (ZSH_THEME='${ZSH_THEME}'). Pure might not be working correctly."
		print "For more information, see: https://github.com/sindresorhus/pure#oh-my-zsh"
		unset ZSH_THEME
	fi
}
prompt_pure_preexec () {
	if [[ -n $prompt_pure_git_fetch_pattern ]]
	then
		local -H MATCH MBEGIN MEND match mbegin mend
		if [[ $2 =~ (git|hub)\ (.*\ )?($prompt_pure_git_fetch_pattern)(\ .*)?$ ]]
		then
			async_flush_jobs 'prompt_pure'
		fi
	fi
	typeset -g prompt_pure_cmd_timestamp=$EPOCHSECONDS 
	prompt_pure_set_title 'ignore-escape' "$PWD:t: $2"
	export VIRTUAL_ENV_DISABLE_PROMPT=${VIRTUAL_ENV_DISABLE_PROMPT:-12} 
}
prompt_pure_preprompt_render () {
	setopt localoptions noshwordsplit
	unset prompt_pure_async_render_requested
	local git_color=$prompt_pure_colors[git:branch] 
	local git_dirty_color=$prompt_pure_colors[git:dirty] 
	[[ -n ${prompt_pure_git_last_dirty_check_timestamp+x} ]] && git_color=$prompt_pure_colors[git:branch:cached] 
	local -a preprompt_parts
	if ((${(M)#jobstates:#suspended:*} != 0))
	then
		preprompt_parts+='%F{$prompt_pure_colors[suspended_jobs]}✦' 
	fi
	[[ -n $prompt_pure_state[username] ]] && preprompt_parts+=($prompt_pure_state[username]) 
	preprompt_parts+=('%F{${prompt_pure_colors[path]}}%~%f') 
	typeset -gA prompt_pure_vcs_info
	if [[ -n $prompt_pure_vcs_info[branch] ]]
	then
		preprompt_parts+=("%F{$git_color}"'${prompt_pure_vcs_info[branch]}'"%F{$git_dirty_color}"'${prompt_pure_git_dirty}%f') 
	fi
	if [[ -n $prompt_pure_vcs_info[action] ]]
	then
		preprompt_parts+=("%F{$prompt_pure_colors[git:action]}"'$prompt_pure_vcs_info[action]%f') 
	fi
	if [[ -n $prompt_pure_git_arrows ]]
	then
		preprompt_parts+=('%F{$prompt_pure_colors[git:arrow]}${prompt_pure_git_arrows}%f') 
	fi
	if [[ -n $prompt_pure_git_stash ]]
	then
		preprompt_parts+=('%F{$prompt_pure_colors[git:stash]}${PURE_GIT_STASH_SYMBOL:-≡}%f') 
	fi
	[[ -n $prompt_pure_cmd_exec_time ]] && preprompt_parts+=('%F{$prompt_pure_colors[execution_time]}${prompt_pure_cmd_exec_time}%f') 
	local cleaned_ps1=$PROMPT 
	local -H MATCH MBEGIN MEND
	if [[ $PROMPT = *$prompt_newline* ]]
	then
		cleaned_ps1=${PROMPT##*${prompt_newline}} 
	fi
	unset MATCH MBEGIN MEND
	local -ah ps1
	ps1=(${(j. .)preprompt_parts} $prompt_newline $cleaned_ps1) 
	PROMPT="${(j..)ps1}" 
	local expanded_prompt
	expanded_prompt="${(S%%)PROMPT}" 
	if [[ $1 == precmd ]]
	then
		print
	elif [[ $prompt_pure_last_prompt != $expanded_prompt ]]
	then
		prompt_pure_reset_prompt
	fi
	typeset -g prompt_pure_last_prompt=$expanded_prompt 
}
prompt_pure_reset_prompt () {
	if [[ $CONTEXT == cont ]]
	then
		return
	fi
	zle && zle .reset-prompt
}
prompt_pure_reset_prompt_symbol () {
	prompt_pure_state[prompt]=${PURE_PROMPT_SYMBOL:-❯} 
}
prompt_pure_reset_vim_prompt_widget () {
	setopt localoptions noshwordsplit
	prompt_pure_reset_prompt_symbol
}
prompt_pure_set_colors () {
	local color_temp key value
	for key value in ${(kv)prompt_pure_colors}
	do
		zstyle -t ":prompt:pure:$key" color "$value"
		case $? in
			(1) zstyle -s ":prompt:pure:$key" color color_temp
				prompt_pure_colors[$key]=$color_temp  ;;
			(2) prompt_pure_colors[$key]=$prompt_pure_colors_default[$key]  ;;
		esac
	done
}
prompt_pure_set_title () {
	setopt localoptions noshwordsplit
	(( ${+EMACS} || ${+INSIDE_EMACS} )) && return
	case $TTY in
		(/dev/ttyS[0-9]*) return ;;
	esac
	local hostname= 
	if [[ -n $prompt_pure_state[username] ]]
	then
		hostname="${(%):-(%m) }" 
	fi
	local -a opts
	case $1 in
		(expand-prompt) opts=(-P)  ;;
		(ignore-escape) opts=(-r)  ;;
	esac
	print -n $opts $'\e]0;'${hostname}${2}$'\a'
}
prompt_pure_setup () {
	export PROMPT_EOL_MARK='' 
	prompt_opts=(subst percent) 
	setopt noprompt{bang,cr,percent,subst} "prompt${^prompt_opts[@]}"
	if [[ -z $prompt_newline ]]
	then
		typeset -g prompt_newline=$'\n%{\r%}' 
	fi
	zmodload zsh/datetime
	zmodload zsh/zle
	zmodload zsh/parameter
	zmodload zsh/zutil
	autoload -Uz add-zsh-hook
	autoload -Uz vcs_info
	autoload -Uz async && async
	autoload -Uz +X add-zle-hook-widget 2> /dev/null
	typeset -gA prompt_pure_colors_default prompt_pure_colors
	prompt_pure_colors_default=(execution_time yellow git:arrow cyan git:stash cyan git:branch 242 git:branch:cached red git:action yellow git:dirty 218 host 242 path blue prompt:error red prompt:success magenta prompt:continuation 242 suspended_jobs red user 242 user:root default virtualenv 242) 
	prompt_pure_colors=("${(@kv)prompt_pure_colors_default}") 
	add-zsh-hook precmd prompt_pure_precmd
	add-zsh-hook preexec prompt_pure_preexec
	prompt_pure_state_setup
	zle -N prompt_pure_reset_prompt
	zle -N prompt_pure_update_vim_prompt_widget
	zle -N prompt_pure_reset_vim_prompt_widget
	if (( $+functions[add-zle-hook-widget] ))
	then
		add-zle-hook-widget zle-line-finish prompt_pure_reset_vim_prompt_widget
		add-zle-hook-widget zle-keymap-select prompt_pure_update_vim_prompt_widget
	fi
	PROMPT='%(12V.%F{$prompt_pure_colors[virtualenv]}%12v%f .)' 
	local prompt_indicator='%(?.%F{$prompt_pure_colors[prompt:success]}.%F{$prompt_pure_colors[prompt:error]})${prompt_pure_state[prompt]}%f ' 
	PROMPT+=$prompt_indicator 
	PROMPT2='%F{$prompt_pure_colors[prompt:continuation]}… %(1_.%_ .%_)%f'$prompt_indicator 
	typeset -ga prompt_pure_debug_depth
	prompt_pure_debug_depth=('%e' '%N' '%x') 
	local -A ps4_parts
	ps4_parts=(depth '%F{yellow}${(l:${(%)prompt_pure_debug_depth[1]}::+:)}%f' compare '${${(%)prompt_pure_debug_depth[2]}:#${(%)prompt_pure_debug_depth[3]}}' main '%F{blue}${${(%)prompt_pure_debug_depth[3]}:t}%f%F{242}:%I%f %F{242}@%f%F{blue}%N%f%F{242}:%i%f' secondary '%F{blue}%N%f%F{242}:%i' prompt '%F{242}>%f ') 
	local ps4_symbols='${${'${ps4_parts[compare]}':+"'${ps4_parts[main]}'"}:-"'${ps4_parts[secondary]}'"}' 
	PROMPT4="${ps4_parts[depth]} ${ps4_symbols}${ps4_parts[prompt]}" 
	unset ZSH_THEME
	export CONDA_CHANGEPS1=no 
}
prompt_pure_state_setup () {
	setopt localoptions noshwordsplit
	local ssh_connection=${SSH_CONNECTION:-$PROMPT_PURE_SSH_CONNECTION} 
	local username hostname
	if [[ -z $ssh_connection ]] && (( $+commands[who] ))
	then
		local who_out
		who_out=$(who -m 2>/dev/null) 
		if (( $? ))
		then
			local -a who_in
			who_in=(${(f)"$(who 2>/dev/null)"}) 
			who_out="${(M)who_in:#*[[:space:]]${TTY#/dev/}[[:space:]]*}" 
		fi
		local reIPv6='(([0-9a-fA-F]+:)|:){2,}[0-9a-fA-F]+' 
		local reIPv4='([0-9]{1,3}\.){3}[0-9]+' 
		local reHostname='([.][^. ]+){2}' 
		local -H MATCH MBEGIN MEND
		if [[ $who_out =~ "\(?($reIPv4|$reIPv6|$reHostname)\)?\$" ]]
		then
			ssh_connection=$MATCH 
			export PROMPT_PURE_SSH_CONNECTION=$ssh_connection 
		fi
		unset MATCH MBEGIN MEND
	fi
	hostname='%F{$prompt_pure_colors[host]}@%m%f' 
	[[ -n $ssh_connection ]] && username='%F{$prompt_pure_colors[user]}%n%f'"$hostname" 
	[[ -z "${CODESPACES}" ]] && prompt_pure_is_inside_container && username='%F{$prompt_pure_colors[user]}%n%f'"$hostname" 
	[[ $UID -eq 0 ]] && username='%F{$prompt_pure_colors[user:root]}%n%f'"$hostname" 
	typeset -gA prompt_pure_state
	prompt_pure_state[version]="1.23.0" 
	prompt_pure_state+=(username "$username" prompt "${PURE_PROMPT_SYMBOL:-❯}") 
}
prompt_pure_system_report () {
	setopt localoptions noshwordsplit
	local shell=$SHELL 
	if [[ -z $shell ]]
	then
		shell=$commands[zsh] 
	fi
	print - "- Zsh: $($shell --version) ($shell)"
	print -n - "- Operating system: "
	case "$(uname -s)" in
		(Darwin) print "$(sw_vers -productName) $(sw_vers -productVersion) ($(sw_vers -buildVersion))" ;;
		(*) print "$(uname -s) ($(uname -r) $(uname -v) $(uname -m) $(uname -o))" ;;
	esac
	print - "- Terminal program: ${TERM_PROGRAM:-unknown} (${TERM_PROGRAM_VERSION:-unknown})"
	print -n - "- Tmux: "
	[[ -n $TMUX ]] && print "yes" || print "no"
	local git_version
	git_version=($(git --version)) 
	print - "- Git: $git_version"
	print - "- Pure state:"
	for k v in "${(@kv)prompt_pure_state}"
	do
		print - "    - $k: \`${(q-)v}\`"
	done
	print - "- zsh-async version: \`${ASYNC_VERSION}\`"
	print - "- PROMPT: \`$(typeset -p PROMPT)\`"
	print - "- Colors: \`$(typeset -p prompt_pure_colors)\`"
	print - "- TERM: \`$(typeset -p TERM)\`"
	print - "- Virtualenv: \`$(typeset -p VIRTUAL_ENV_DISABLE_PROMPT)\`"
	print - "- Conda: \`$(typeset -p CONDA_CHANGEPS1)\`"
	local ohmyzsh=0 
	typeset -la frameworks
	(( $+ANTIBODY_HOME )) && frameworks+=("Antibody") 
	(( $+ADOTDIR )) && frameworks+=("Antigen") 
	(( $+ANTIGEN_HS_HOME )) && frameworks+=("Antigen-hs") 
	(( $+functions[upgrade_oh_my_zsh] )) && {
		ohmyzsh=1 
		frameworks+=("Oh My Zsh") 
	}
	(( $+ZPREZTODIR )) && frameworks+=("Prezto") 
	(( $+ZPLUG_ROOT )) && frameworks+=("Zplug") 
	(( $+ZPLGM )) && frameworks+=("Zplugin") 
	(( $#frameworks == 0 )) && frameworks+=("None") 
	print - "- Detected frameworks: ${(j:, :)frameworks}"
	if (( ohmyzsh ))
	then
		print - "    - Oh My Zsh:"
		print - "        - Plugins: ${(j:, :)plugins}"
	fi
}
prompt_pure_update_vim_prompt_widget () {
	setopt localoptions noshwordsplit
	prompt_pure_state[prompt]=${${KEYMAP/vicmd/${PURE_PROMPT_VICMD_SYMBOL:-❮}}/(main|viins)/${PURE_PROMPT_SYMBOL:-❯}} 
	prompt_pure_reset_prompt
}
prompt_pws_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_redhat_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_restore_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_suse_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_walters_setup () {
	# undefined
	builtin autoload -XUz
}
prompt_zefram_setup () {
	# undefined
	builtin autoload -XUz
}
promptinit () {
	emulate -L zsh
	setopt extendedglob
	autoload -Uz add-zsh-hook add-zle-hook-widget
	local ppath='' name theme 
	local -a match mbegin mend
	for theme in $^fpath/prompt_*_setup(N)
	do
		if [[ $theme == */prompt_(#b)(*)_setup ]]
		then
			name="$match[1]" 
			if [[ -r "$theme" ]]
			then
				prompt_themes=($prompt_themes $name) 
				autoload -Uz prompt_${name}_setup
			else
				print "Couldn't read file $theme containing theme $name."
			fi
		else
			print "Eh?  Mismatch between glob patterns in promptinit."
		fi
	done
	prompt_newline=$'\n%{\r%}' 
}
set_prompt () {
	emulate -L zsh
	local opt preview theme usage old_theme
	usage='Usage: prompt <options>
Options:
    -c              Show currently selected theme and parameters
    -l              List currently available prompt themes
    -p [<themes>]   Preview given themes (defaults to all except current theme)
    -h [<theme>]    Display help (for given theme)
    -s <theme>      Set and save theme
    <theme>         Switch to new theme immediately (changes not saved)

Use prompt -h <theme> for help on specific themes.' 
	getopts "chlps:" opt
	case "$opt" in
		(c) if [[ -n $prompt_theme ]]
			then
				print -n "Current prompt theme"
				(( $#prompt_theme > 1 )) && print -n " with parameters"
				print " is:\n  $prompt_theme"
			else
				print "Current prompt is not a theme."
			fi
			return ;;
		(h) if [[ -n "$2" && -n $prompt_themes[(r)$2] ]]
			then
				(
					zstyle -t :prompt-theme cleanup
					typeset +f prompt_$2_help > /dev/null || prompt_$2_setup
					if typeset +f prompt_$2_help > /dev/null
					then
						print "Help for $2 theme:\n"
						prompt_$2_help
					else
						print "No help available for $2 theme."
					fi
					print "\nType \`prompt -p $2' to preview the theme, \`prompt $2'"
					print "to try it out, and \`prompt -s $2' to use it in future sessions."
				)
			else
				print "$usage"
			fi ;;
		(l) print Currently available prompt themes:
			print $prompt_themes
			return ;;
		(p) preview=(${prompt_themes:#$prompt_theme}) 
			(( $#* > 1 )) && preview=("$@[2,-1]") 
			for theme in $preview
			do
				prompt_preview_safely "$=theme"
			done
			print -P "%b%f%k" ;;
		(s) print "Set and save not yet implemented.  Please ensure your ~/.zshrc"
			print "contains something similar to the following:\n"
			print "  autoload -Uz promptinit"
			print "  promptinit"
			print "  prompt $*[2,-1]"
			shift ;&
		(*) if [[ "$1" == 'random' ]]
			then
				local random_themes
				if (( $#* == 1 ))
				then
					random_themes=($prompt_themes) 
				else
					random_themes=("$@[2,-1]") 
				fi
				local i=$(( ( $RANDOM % $#random_themes ) + 1 )) 
				argv=("${=random_themes[$i]}") 
			fi
			if [[ -z "$1" || -z $prompt_themes[(r)$1] ]]
			then
				print "$usage"
				return
			fi
			local hook
			for hook in chpwd precmd preexec periodic zshaddhistory zshexit zsh_directory_name
			do
				add-zsh-hook -D "$hook" "prompt_*_$hook"
			done
			for hook in isearch-exit isearch-update line-pre-redraw line-init line-finish history-line-set keymap-select
			do
				add-zle-hook-widget -D "$hook" "prompt_*_$hook"
			done
			typeset -ga zle_highlight=(${zle_highlight:#default:*}) 
			(( ${#zle_highlight} )) || unset zle_highlight
			zstyle -t :prompt-theme cleanup
			prompt_$1_setup "$@[2,-1]" && prompt_theme=("$@")  ;;
	esac
}
vcs_info () {
	# undefined
	builtin autoload -XUz
}
# Shell Options
setopt correct
setopt nohashdirs
setopt histfindnodups
setopt histignoredups
setopt histignorespace
setopt histreduceblanks
setopt histverify
setopt incappendhistory
setopt login
setopt nopromptcr
setopt nopromptsp
setopt promptsubst
setopt sharehistory
# Aliases
alias -- blog='cd ~/dev/geekytidbits.com && npx xertz new "TBD"'
alias -- cdh='cd $HOME'
alias -- clip='(){ cat $1 | pbcopy; echo "Copied contents of file ${1} to clipboard."}'
alias -- cls='printf "\033c"'
alias -- d=docker
alias -- dc='docker ps -a'
alias -- dev='cd ~/dev'
alias -- dr='docker run --rm -it'
alias -- drm='docker rm $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias -- drmi='docker rmi $(docker images -q)'
alias -- dus='du -d 1 -h | sort -h'
alias -- eg='cd $YNAB_EVERGREEN_PATH'
alias -- fast='networkQuality -s'
alias -- fixdisplay='displayplacer "id:15C48A1D-FCF9-CEC0-72A1-F00465DB28FA res:1920x1200 color_depth:4 scaling:on origin:(0,0) degree:0" "id:2B06791D-98D8-0CF5-A627-06393098A398 res:2560x1440 hz:60 color_depth:8 scaling:off origin:(-483,-1440) degree:0" "id:88733A9D-FD53-D657-26C2-44A5AE004DEC res:1440x2560 hz:60 color_depth:8 scaling:off origin:(2077,-1898) degree:90"'
alias -- gbc='git switch --create'
alias -- gd='git diff'
alias -- gdt='git difftool -y'
alias -- gf='git fetch --prune --no-tags'
alias -- ghd=github
alias -- gl='git pull'
alias -- glg='git log'
alias -- gmod='git merge origin/develop'
alias -- gmt='git mergetool'
alias -- gp='git push -u'
alias -- grh='git reset --hard HEAD'
alias -- grod='git rebase origin/develop'
alias -- gs='git status -sb'
alias -- gst='git stash --include-untracked'
alias -- gstcf='git checkout stash@{0} --'
alias -- gstd='git stash list -p'
alias -- gstl='git stash list --stat'
alias -- gstp='git stash pop'
alias -- h=heroku
alias -- hg='history | grep'
alias -- ip='curl -4 ifconfig.co && curl -6 ifconfig.co'
alias -- json=' jq -C '\''.'\'' | less -R'
alias -- killport='(){ kill -9 $(lsof -t -i:$1 2> /dev/null);}'
alias -- l='ls -lAh'
alias -- nb='npm run build'
alias -- ncu='npx npm-check-updates'
alias -- nd='npm run dev'
alias -- ni='npm install'
alias -- nr='npm run'
alias -- nt='npm test'
alias -- psql2md=' sed '\''s/+/|/g'\'' | sed '\''s/^/|/'\'' | sed '\''s/$/|/'\'' | grep -v rows | grep -v '\''||'\'
alias -- pubkey='op item get '\''SSH Keypair'\'' --fields label='\''public key'\'' | pbcopy | echo '\''=> Public key copied to clipboard'\'
alias -- r=send-reminder-email
alias -- run-help=man
alias -- ry='SMTP_GMAIL=$YNAB_SMTP_GMAIL send-reminder-email'
alias -- uuid='uuidgen | tr -d '\''\n'\'' | tr '\''[:upper:]'\'' '\''[:lower:]'\'' | pbcopy | echo '\''=> New UUID copied to clipboard'\'
alias -- watch='(){ while sleep $1; do $(fc -ln -1); done ;}'
alias -- which-command=whence
alias -- yi='yarn install'
# Check for rg availability
if ! command -v rg >/dev/null 2>&1; then
  alias rg='/Users/bholt/.vscode/extensions/anthropic.claude-code-2.0.2/resources/claude-code/vendor/ripgrep/arm64-darwin/rg'
fi
export PATH=/Users/bholt/.asdf/plugins/nodejs/shims\:/Users/bholt/.asdf/installs/nodejs/22.14.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/shims\:/opt/homebrew/opt/asdf/libexec/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/bin\:/Users/bholt/.asdf/installs/ruby/3.4.5/lib/ruby/gems/.0/bin\:/Users/bholt/dev/evergreen\:/Users/bholt/Library/Android/sdk/emulator\:/Users/bholt/Library/Android/sdk/tools\:.\:/Users/bholt/bin\:/usr/local/bin\:/usr/local/share/dotnet\:/Users/bholt/Library/Android/sdk/platform-tools\:/Users/bholt/.bin\:/opt/homebrew/bin\:/opt/homebrew/sbin\:/usr/local/bin\:/System/Cryptexes/App/usr/bin\:/usr/bin\:/bin\:/usr/sbin\:/sbin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin\:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin\:/Library/Apple/usr/bin\:/usr/local/share/dotnet\:~/.dotnet/tools\:/Applications/iTerm.app/Contents/Resources/utilities
