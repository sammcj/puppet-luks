#!/bin/bash

# This Nagios check will alert for more than X number of keys are enabled for all detected LUKS devices
#
# Usage:
# check_luks_keys.sh [expected number of keys]
#
# Example:
#
# ./check_luks_keys.sh 5
#
# Author: Sam McLeod https://github.com/sammcj https://smcleod.net

EXPECTED_NUM_KEYS=$1
LUKS_DEVICES=$(blkid -o device -t TYPE="crypto_LUKS")
MESSAGE=""
EXITCODE=0

function usage () {
  cat <<-EOF
    Usage: ./check_luks_keys.sh [ expected number of keys ]

    Example
            ./check_luks_keys.sh 5

EOF
}

if [ -z "$EXPECTED_NUM_KEYS" ]; then
  usage
  exit 2
fi

for DEVICE in $LUKS_DEVICES; do
  CRYPTS=$(cryptsetup luksDump "$DEVICE")
  KEY_SLOTS=$(echo "$CRYPTS" | grep -o ': ENABLED' | wc -l)

  # Check for no enabled keys
  if [[ "$KEY_SLOTS" == 0 && "$EXPECTED_NUM_KEYS" != 0 ]]; then
    MESSAGE=$MESSAGE"NO ENABLED KEYS FOUND FOR DEVICE $DEVICE, expecting ${EXPECTED_NUM_KEYS}! "
    EXITCODE=$EXITCODE+2
  fi

  # Check for more than the expected number of keys
  if [ "$KEY_SLOTS" != "$EXPECTED_NUM_KEYS" ]; then
    MESSAGE=$MESSAGE"The device $DEVICE has $KEY_SLOTS key(s), expecting ${EXPECTED_NUM_KEYS}. "
    EXITCODE=$EXITCODE+1
  fi

  # Check that the correct number of keys are loaded
  if [ "$KEY_SLOTS" == "$EXPECTED_NUM_KEYS" ]; then
    MESSAGE=$MESSAGE"The device $DEVICE has $KEY_SLOTS key(s) "
    EXITCODE=$EXITCODE+0
  fi

done

if [[ $EXITCODE -ge 2 ]]; then
  echo "CRITICAL: ${MESSAGE}"
  exit 2
elif [[ $EXITCODE -eq 1 ]]; then
  echo "WARNING: ${MESSAGE}"
  exit 1
elif [[ $EXITCODE -eq 0 ]]; then
  echo "OK: ${MESSAGE}"
  exit 0
fi
