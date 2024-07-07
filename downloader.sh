#!/bin/bash

#retrieve parameters
PATH=$1
VERSION=$2

#check parameters
if [ -z $PATH ] || [ -z $VERSION ]
then
	echo "Usage: $0 path version"
	exit 1
fi

# Retrieve SDK file name from the version
CONNECTIQ_SDK_URL="https://developer.garmin.com/downloads/connect-iq/sdks"
CONNECTIQ_SDK_INFO_URL="${CONNECTIQ_SDK_URL}/sdks.json"
filename=$(/usr/bin/curl -s "${CONNECTIQ_SDK_INFO_URL}" | /usr/bin/jq -r --arg version "$VERSION" '.[] | select(.version==$version) | .linux')
url="${CONNECTIQ_SDK_URL}/${filename}"
echo "Downloading from ${url}..."
/usr/bin/wget -q "${url}" -O /tmp/connectiq.zip;

# Extract to destination
/usr/bin/unzip -qo /tmp/connectiq.zip -d "${PATH}"
/usr/bin/rm /tmp/connectiq.zip

# Done
echo "Connect IQ SDK version ${VERSION} was downloaded and extracted to ${PATH}"
exit 0

