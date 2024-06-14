#!/bin/bash

# Include common functions
source "$(dirname "$(realpath "$0")")/helpers/common_functions.sh"
loginfo "Welcome to the ConnectIQ Builder - Test script!"

# Display parsed arguments 
printf "Argument(device): ${DEVICE_ID}\n"
printf "Argument(certificate-path): ${CERTIFICATE_PATH}\n"
printf "Argument(type-check-level): ${TYPE_CHECK_LEVEL}\n"

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
fi

# Compile the application
loginfo "Compiling application..."
monkeyc -f monkey.jungle -d "$DEVICE_ID" -o bin/app.prg -y "$CERTIFICATE_PATH" -t -l "${TYPE_CHECK_LEVEL}"
if [[ ! -f bin/app.prg ]]; then
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
monkeydo bin/app.prg "$DEVICE_ID" -t > $result_file
loginfo < $result_file
result=$(tail -1 $result_file)
if [[ $result == PASSED* ]]
then
	loginfo "Success!"
	exit 0
else
	loginfo "Failure!"
	exit 1
fi
