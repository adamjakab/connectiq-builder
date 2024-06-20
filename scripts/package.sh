#!/bin/bash

# Include common functions
source "$(dirname "$(realpath "$0")")/helpers/common_functions.sh"
loginfo "Welcome to the ConnectIQ Builder ::: Package script!"

# Display parsed arguments 
loginfo "Argument(device): ${DEVICE_ID}"
loginfo "Argument(type-check-level): ${TYPE_CHECK_LEVEL}"
loginfo "Argument(certificate-path): ${CERTIFICATE_PATH}"
loginfo "Argument(package-name): ${PACKAGE_NAME}"

# Fail if any of the commands fails
set -e

# Verify certificate and fail if missing
if [[ -z $CERTIFICATE_PATH ]]
then
	loginfo "The 'certificate-path' argument is not set!"
    exit 1
elif [[ ! -f $CERTIFICATE_PATH ]]
then
	loginfo "The 'certificate-path' argument points to a file which does not exist!"
    exit 2
fi

# Build and package the application
pkgpath="bin/${PACKAGE_NAME}"
loginfo "Packaging the application..."
monkeyc -f monkey.jungle -o ${pkgpath} -y "$CERTIFICATE_PATH" -l "${TYPE_CHECK_LEVEL}" --package-app --release
if [[ ! -f ${pkgpath} ]]; then
	loginfo "Packaging failed!"
	exit 1
fi

loginfo "Package built: '${pkgpath}'."
