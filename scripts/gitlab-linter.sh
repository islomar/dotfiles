#!/bin/bash

###########################
# Validate .gitlab-ci.yml #
#    by  Peter Weinert    #
###########################

# https://gitlab.lrz.de/snippets/234

GITLAB_URL=https://gitlab.lrz.de
GITLAB_API_LINT="${GITLAB_URL}/api/v4/ci/lint"
GITLAB_WEB_LINT="${GITLAB_URL}/ci/lint"

ANSI_RED="\e[31m"
ANSI_YELLOW="\e[33m"
ANSI_LIGHT="\e[1m"
ANSI_OFF="\e[0m"

# Check if .gitlab-ci.yml is added or modified in index
CI_CHANGED=`git diff-index --name-only --diff-filter MA HEAD | grep '^.gitlab-ci.yml$'`

if [ ! -z "$CI_CHANGED" ]
then
	# checkout from index to a temporary file named $temp_file
	temp_file_assoc=$(git checkout-index --temp -- .gitlab-ci.yml)
	set -f
	temp_file=($temp_file_assoc)
	set +f
	temp_file=${temp_file[0]}
	trap "rm -f $temp_file" EXIT INT TERM
	
	# Sanitize: read the whole file in a loop (:a;N;$!ba), see https://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed
	# and escape special json characters (\ \f \n \r \t / ") with a backslash.
	SANE_CONTENT="$( cat "$temp_file" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\\/\\\\/g' -e 's/\f/\\f/g' -e 's/\n/\\n/g' -e 's/\r/\\r/g' -e 's/\t/\\t/g' -e 's/\//\\\//g' -e 's/"/\\"/g' )"
	# Pack YAML in JSON
	JSON="{\"content\": \"${SANE_CONTENT}\"}"
	
	# Use Lint - if timeout is reached the validation will succeed nevertheless
	ANSWER=`curl -s --connect-timeout 2 --max-time 4 --header "Content-Type: application/json" ${GITLAB_API_LINT} --data "$JSON"`
	ERROR_CODE=$?
	if [[ "$ERROR_CODE" != "0" ]]; then
		echo -e "${ANSI_LIGHT}${ANSI_YELLOW}WARNING: .gitlab-ci.yml not validated!${ANSI_OFF} Curl failed with error code ${ANSI_LIGHT}${ANSI_RED}${ERROR_CODE}${ANSI_OFF}" >&2
	else
		if [[ $ANSWER =~ "invalid" ]]; then
			echo -e "${ANSI_LIGHT}${ANSI_RED}ERROR: Invalid .gitlab-ci.yml.${ANSI_OFF} Lint reports ${ANSWER}." >&2
			echo -e "Use your Gitlab Lint (${GITLAB_WEB_LINT}) for more information." >&2
			echo -e "Aborting commit." >&2
			exit 1
		elif [[ ! $ANSWER =~ "valid" ]]; then
			echo -e "${ANSI_LIGHT}${ANSI_YELLOW}WARNING: No regular answer received.${ANSI_OFF} Lint reports '${ANSWER}'." >&2
			echo -e "This is most likely a bug in the JSON to YAML converter section of this script." >&2
			echo -e "Please report includung the exact .gitlab-ci.yml." >&2
			echo -e "Data send was (backslashes escaped) $( echo "$JSON" | sed -e 's/\\/\\\\/g' )" >&2
#		else
#			echo -e "File .gitlab-ci.yml is valid."
		fi
	fi
fi
