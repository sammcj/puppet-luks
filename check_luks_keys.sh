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
MESSAGE=""
LUKS_DEVICES=$(blkid -o device -t TYPE="crypto_LUKS")
CRIT=false
WARN=false
OK=false

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
    CRIT=true
    MESSAGE="NO ENABLED KEYS FOUND FOR DEVICE $DEVICE!"
  fi

  # Check for more than the expected number of keys
  if [ "$KEY_SLOTS" != "$EXPECTED_NUM_KEYS" ]; then
    WARN=true
    MESSAGE="The device $DEVICE has $KEY_SLOTS keys!"
  fi

  # Check that the correct number of keys are loaded
  if [ "$KEY_SLOTS" == "$EXPECTED_NUM_KEYS" ]; then
    OK=true
    MESSAGE="The device $DEVICE has $KEY_SLOTS key(s)"
  fi


  if [ $CRIT == true ]; then
    echo "CRITICAL: ${MESSAGE}, expecting ${EXPECTED_NUM_KEYS}"
    exit 2
  elif [ $WARN == true ]; then
    echo "WARNING: ${MESSAGE}, expecting ${EXPECTED_NUM_KEYS}"
    exit 1
  elif [ $OK == true ]; then
    echo "OK: ${MESSAGE}"
    exit 0
  fi

done
