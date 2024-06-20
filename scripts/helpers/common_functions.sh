#!/bin/bash

# Common functions used by multiple scripts.
# Usage from the scripts dir: source "$(dirname "$(realpath "$0")")/helpers/common_functions.sh"


# Displays a message passed as a parameter of read it from stdin
function loginfo {
	if [[ -n $1 ]]
	then
		echo -e "${1}"
	else
		while read -r message
		do
			loginfo "$message"
		done
	fi
}

function showhelp {
    loginfo "The following agrguments can be used:"
    loginfo "\t--device=DEVICE [default: fr235] Select the device for which the application should be built."
    loginfo "\t--type-check-level=LEVEL [default: 2] Set the type check level."
    loginfo "\t--certificate-path=PATH Set the path for the certificate."
    loginfo "\t--package-name=NAME Set the file name of the package."
}

### The below section will be run as soon as this script is sourced from other scripts

# Set some defaults
DEVICE_ID=fr235
TYPE_CHECK_LEVEL=2
CERTIFICATE_PATH=""
PACKAGE_NAME="package.iq"

# Parse script arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --device=*)
      DEVICE_ID="${1#*=}"
      ;;
    --type-check-level=*)
      TYPE_CHECK_LEVEL="${1#*=}"
      ;;
    --certificate-path=*)
      CERTIFICATE_PATH="${1#*=}"
      ;;
    --package-name=*)
      PACKAGE_NAME="${1#*=}"
      ;;
    *)
      loginfo "**********************************************************"
      loginfo "Error: Unknown argument: '${1}'."
      loginfo "**********************************************************"
      showhelp
	    exit 1
  esac
  shift
done
