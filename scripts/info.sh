#!/bin/bash

# Include common functions
source helpers/common_functions.sh

loginfo "Welcome to the ConnectIQ Builder - Info script!"

foldersize=$(du -sh .)
loginfo "App folder size: ${foldersize}"

exit 0
