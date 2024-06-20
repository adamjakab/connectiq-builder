#!/bin/bash

# Include common functions
source "$(dirname "$(realpath "$0")")/helpers/common_functions.sh"
loginfo "Welcome to the ConnectIQ Builder ::: Info script!"

# Display parsed arguments 
loginfo "Argument(device): ${DEVICE_ID}"
loginfo "Argument(type-check-level): ${TYPE_CHECK_LEVEL}"
loginfo "Argument(certificate-path): ${CERTIFICATE_PATH}"
loginfo "Argument(package-name): ${PACKAGE_NAME}"

foldersize=$(du -sh .)
loginfo "App folder size: ${foldersize}"

exit 0
