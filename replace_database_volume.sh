#!/bin/bash

die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='h'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS


print_help()
{
	printf '%s\n' "Replaces a volume in database container with the specified one"
	printf 'Usage: %s [-h|--help] <volume_name>\n' "$0"
	printf '\t%s\n' "<volume_name>: A name of a volume that should be used as a replacement"
	printf '\t%s\n' "-h, --help: Prints help"
}


parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_last_positional="$1"
				_positionals+=("$_last_positional")
				_positionals_count=$((_positionals_count + 1))
				;;
		esac
		shift
	done
}


handle_passed_args_count()
{
	local _required_args_string="'volume_name'"
	test "${_positionals_count}" -ge 1 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 1 (namely: $_required_args_string), but got only ${_positionals_count}." 1
	test "${_positionals_count}" -le 1 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 1 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names="_arg_volume_name "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# OTHER STUFF GENERATED BY Argbash

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

docker volume inspect --format 'Volume $_arg_volume_name was created at {{ .CreatedAt }}' $_arg_volume_name >/dev/null
if [ $? != 0 ];
then
    bash "$(dirname $0)"/create_database_volume.sh $_arg_volume_name
fi

echo -e "\nStopping incremental_backups container..."
docker stop incremental_backups >/dev/null
echo -e "\nCopying incremental_backups from $_arg_volume_name volume to incremental_backups container..."
docker run --rm \
           --volumes-from incremental_backups \
           -v $_arg_volume_name:/$_arg_volume_name \
           eeacms/rsync rsync -a --delete /$_arg_volume_name/ /var/lib/mysql/ >/dev/null
echo -e "\nStarting incremental_backups container..."
docker start incremental_backups >/dev/null

# ] <-- needed because of Argbash
