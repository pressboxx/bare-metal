#!/usr/bin/env bash

source "/home/boxx/Config/includes/constants.sh"
source "/home/boxx/Config/includes/functions.sh"

#
# Copy database files to RAM Disk
#
if [ "${BOXX_HAS_RAM_DATA}" == "" ]; then
    sudo rsync -av "${BOXX_SAFE_DATA_ROOT}" "${BOXX_RAM_DATA_ROOT}"
fi

