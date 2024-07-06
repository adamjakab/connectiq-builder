#!/bin/bash

# Common functions used by multiple scripts.
# Usage from the scripts dir: source "$(dirname "$(realpath "$0")")/helpers/common_functions.sh"

# Try with die / nodie
# Ref.: https://stackoverflow.com/a/25515370/1862564
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }
try_nodie() { "$@" || return 0; }

# Displays a message passed as a parameter of read it from stdin
function loginfo {
	if [[ -n $1 ]]
	then
    if [[ -f $1 ]]
    then
      cat $1
    else
		  echo -e "${1}"
    fi
	fi
}

function debuginfo {
  if [ $VERBOSE -eq 1 ]
  then
    loginfo "$1"
  fi
}

function showhelp {
    loginfo "The following agrguments can be used:"
    loginfo "\t--device=DEVICE [default: fr235] The device for which the application should be tested or built."
    loginfo "\t--devices=DEVICES [default: None] Comma separated list of device IDs for which the app should be tested."
    loginfo "\t--type-check-level=LEVEL [default: 2] Set the type check level."
    loginfo "\t--certificate-path=PATH Set the path for the certificate."
    loginfo "\t--package-name=NAME Set the file name of the package."
}

### The below section will be run as soon as this script is sourced from other scripts

# Set some defaults
VERBOSE=0
DEVICE_ID=fr235
DEVICE_ID_LIST=""
TYPE_CHECK_LEVEL=2
CERTIFICATE_PATH=""
PACKAGE_NAME="package.iq"

# Parse script arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --verbose=*)
      if [ "${1#*=}" = 1 ]
      then
        VERBOSE=1
      fi
      ;;
    --device=*)
      DEVICE_ID="${1#*=}"
      ;;
    --devices=*)
      DEVICE_ID_LIST="${1#*=}"
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
