#!/bin/bash

# Common functions used by multiple scripts.
# Usage: source helpers/common_functions.sh

# Displays a message passed as a parameter of read it from stdin
function loginfo {
	if [[ -n $1 ]]
	then
		echo -e "${1}"
	else
		while read -r message
		do
			info "$message"
		done
	fi
}
