#!/bin/bash

# @FIXME: no more backward compatibility is needed here.

# Allow deprecated positional argument usage and set some defaults
DEVICE_ID=${1:-fenix7}
CERTIFICATE_PATH=$2
TYPE_CHECK_LEVEL=${3:-3}

# Sanitize deprecated positional arguments if named arguments are used 
# Ex.: /test.sh --type-check-level=2 will pick up DEVICE_ID = '-type-check-level=2'
# This sanitization can be removed once positional arguments are truely deprecated
if  [[ $DEVICE_ID == --* ]]; then DEVICE_ID=""; fi
if  [[ $CERTIFICATE_PATH == --* ]]; then CERTIFICATE_PATH=""; fi

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --device=*)
      DEVICE_ID="${1#*=}"
      ;;
    --certificate-path=*)
      CERTIFICATE_PATH="${1#*=}"
      ;;
    --type-check-level=*)
      TYPE_CHECK_LEVEL="${1#*=}"
      ;;
    # Warn about deprecated usage
    *)
      printf "**********************************************************\n"
      printf "Warning: Deprecated positional argument usage: '${1}'.\n"
      printf "**********************************************************\n"
  esac
  shift
done

# Display parsed arguments 
printf "Argument(device): ${DEVICE_ID}\n"
printf "Argument(certificate-path): ${CERTIFICATE_PATH}\n"
printf "Argument(type-check-level): ${TYPE_CHECK_LEVEL}\n"

# Fail if any of the commands fails
set -e

# Kill child processes when this scripts exists
trap 'kill $(jobs -p)' EXIT

# Displays a message passed as a parameter of read it from stdin
function info {
	if [[ -n $1 ]]
	then
		message="$1"
		echo -e "$message"
	else
		while read -r message
		do
			info "$message"
		done
	fi
}

# Generate temporary certificate if required
if [[ -z $CERTIFICATE_PATH ]]
then
	info "Generating temporary certificate..."
	openssl genrsa -out /tmp/key.pem 4096 && openssl pkcs8 -topk8 -inform PEM -outform DER -in /tmp/key.pem -out /tmp/key.der -nocrypt
	CERTIFICATE_PATH=/tmp/key.der
fi

# Compile the application
info "Compiling application..."
monkeyc -f monkey.jungle -d "$DEVICE_ID" -o bin/app.prg -y "$CERTIFICATE_PATH" -t -l "${TYPE_CHECK_LEVEL}"
if [[ ! -f bin/app.prg ]]; then
	info "Compilation failed!"
	exit 1
fi

# Create a fake display and run the simulator
info "Launching simulator..."
export DISPLAY=:1
Xvfb "${DISPLAY}" -screen 0 1280x1024x24 &
simulator > /dev/null 2>&1 &
# TODO: alternatively one could check the output and wait for "Debug: SetLayout" message from the simulator
sleep 5
info "Simulator ready."


# Run tests
info "Running tests..."
result_file=/tmp/result.txt
monkeydo bin/app.prg "$DEVICE_ID" -t > $result_file
info < $result_file
result=$(tail -1 $result_file)
if [[ $result == PASSED* ]]
then
	info "Success!"
	exit 0
else
	info "Failure!"
	exit 1
fi
