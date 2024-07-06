#!/bin/bash

# Include common functions
source "$(dirname "$(realpath "$0")")/helpers/common_functions.sh"
loginfo "Welcome to the ConnectIQ Builder ::: Test script"

# Display parsed arguments 
loginfo "Argument(device): ${DEVICE_ID}"
loginfo "Argument(devices): ${DEVICE_ID_LIST}"
loginfo "Argument(type-check-level): ${TYPE_CHECK_LEVEL}"
loginfo "Argument(certificate-path): ${CERTIFICATE_PATH}"

if [[ -z $DEVICE_ID_LIST ]]
then
	DEVICE_ID_LIST=${DEVICE_ID}
fi
IFS=',' read -r -a DEVICE_ID_ARRAY <<< "${DEVICE_ID_LIST}"
debuginfo "Device list: ${DEVICE_ID_LIST}"


# Fail if any of the commands fails
set -e

# Kill child processes when this scripts exists
trap 'kill $(jobs -p)' EXIT

# Generate temporary certificate if required
check_generate_certificate() {
	if [[ -z $CERTIFICATE_PATH ]]
	then
		keyname="autogenerated"
		debuginfo "Generating temporary certificate..."
		openssl genrsa -out /tmp/${keyname}.pem 4096 && openssl pkcs8 -topk8 -inform PEM -outform DER -in /tmp/${keyname}.pem -out /tmp/${keyname}.der -nocrypt
		CERTIFICATE_PATH=/tmp/${keyname}.der
	fi
	loginfo "Using certificate: ${CERTIFICATE_PATH}"
}


# Compile the application
compile_application () {
	apppath="bin/testapp_${DEVICE_ID}.prg"
	result_file="/tmp/result_${DEVICE_ID}.txt"
	loginfo "Compiling application for device ${DEVICE_ID}..."
	try_nodie monkeyc -f monkey.jungle -d "$DEVICE_ID" -o ${apppath} -y "$CERTIFICATE_PATH" --build-stats 1 -t -l "${TYPE_CHECK_LEVEL}" > $result_file 2>&1
	if [[ ! -f ${apppath} ]]; then
		loginfo "Compilation failed!"
		loginfo $result_file
		exit 1
	else
		debuginfo $result_file
	fi
}

launch_simulator () {
	# Create a fake display and run the simulator
	loginfo "Launching simulator..."
	export DISPLAY=:1
	Xvfb "${DISPLAY}" -screen 0 1280x1024x24 &
	simulator > /dev/null 2>&1 &
	# TODO: alternatively one could check the output and wait for "Debug: SetLayout" message from the simulator
	sleep 5
	loginfo "Simulator ready."
}

# Run tests
run_tests () {
	apppath="bin/testapp_${DEVICE_ID}.prg"
	result_file="/tmp/tests_${DEVICE_ID}.txt"
	loginfo "Running tests on application(${apppath}) for device ${DEVICE_ID}..."
	try_nodie monkeydo ${apppath} "$DEVICE_ID" -t > $result_file 2>&1
	result=$(tail -1 $result_file)
	if [[ $result != PASSED* ]]
	then
		loginfo "Tests for device ${DEVICE_ID} failed!"
		loginfo $result_file
		exit 1
	else
		debuginfo $result_file
		loginfo "Tests for ${DEVICE_ID}: Passed."
	fi
}


# MAIN RUN
check_generate_certificate

# Compile application for all devices
for DEVICE_ID in "${DEVICE_ID_ARRAY[@]}"
do
	compile_application
done

launch_simulator

# Run tests for all devices
for DEVICE_ID in "${DEVICE_ID_ARRAY[@]}"
do
	run_tests
done


exit 0











