#!/bin/bash

# Include common functions
source "$(dirname "$(realpath "$0")")/helpers/common_functions.sh"
loginfo "Welcome to the ConnectIQ Builder ::: Test script!"

# Display parsed arguments 
loginfo "Argument(device): ${DEVICE_ID}"
loginfo "Argument(type-check-level): ${TYPE_CHECK_LEVEL}"
loginfo "Argument(certificate-path): ${CERTIFICATE_PATH}"

# Fail if any of the commands fails
set -e

# Kill child processes when this scripts exists
trap 'kill $(jobs -p)' EXIT

# Generate temporary certificate if required
if [[ -z $CERTIFICATE_PATH ]]
then
	loginfo "Generating temporary certificate..."
	openssl genrsa -out /tmp/key.pem 4096 && openssl pkcs8 -topk8 -inform PEM -outform DER -in /tmp/key.pem -out /tmp/key.der -nocrypt
	CERTIFICATE_PATH=/tmp/key.der
else
	loginfo "Using provided certificate: ${CERTIFICATE_PATH}"
fi

# Compile the application
apppath="bin/testapp.prg"
loginfo "Compiling application(${apppath}) for device ${DEVICE_ID}..."
monkeyc -f monkey.jungle -d "$DEVICE_ID" -o ${apppath} -y "$CERTIFICATE_PATH" --build-stats 1 -t -l "${TYPE_CHECK_LEVEL}"
if [[ ! -f ${apppath} ]]; then
	loginfo "Compilation failed!"
	exit 1
fi

# Create a fake display and run the simulator
loginfo "Launching simulator..."
export DISPLAY=:1
Xvfb "${DISPLAY}" -screen 0 1280x1024x24 &
simulator > /dev/null 2>&1 &
# TODO: alternatively one could check the output and wait for "Debug: SetLayout" message from the simulator
sleep 5
loginfo "Simulator ready."


# Run tests
loginfo "Running tests..."
result_file=/tmp/result.txt
monkeydo ${apppath} "$DEVICE_ID" -t > $result_file
loginfo < $result_file
result=$(tail -1 $result_file)
if [[ $result != PASSED* ]]
then
	loginfo "Failure!"
	exit 1
fi
