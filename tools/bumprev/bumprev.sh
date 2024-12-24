#!/usr/bin/env bash

#  BumpRev
#  by Captain Future

#  Will bump the revision number in a file. Pass the file name as the first (and only) parameter.
#
#  Expects a line in the passed file like this:
#
#     REVISION=1234
#
#  In the above example, this script will bump the number from 1234 to 1235

#  NOTE:
#
#  - Requires a shell that supports built-in read with IFS (Internal Field Separator), like bash.
#  - The new REVISION string is always placed at the end of the file
#

# Say hi
echo "BumpRev"

# exit if no param passed
if [ -z "${1}" ]; then
  echo "ERROR: ${0} requires a parameter: the name of the file that contains the REVISION string"
  exit 1
fi

# exit if there's no rev number in this file
REVLINE=$(grep REVISION "$1")
if [ -z "${REVLINE}" ]; then
  echo "ERROR: ${1} does not contain a REVISION string."
  exit 1
fi

# generate the next rev number
IFS="=" read -ra REV <<< "${REVLINE}"
let CURRENTREV="${REV[1]}"
let NEXTREV=CURRENTREV+1
echo "Current rev is   [ ${CURRENTREV} ]."
echo "Bumping to ----> [ ${NEXTREV} ]."

# and replace it in the file
grep -v "${REVLINE}" "${1}" > "${1}.tmp"
echo "REVISION=${NEXTREV}" >> "${1}.tmp"
mv "${1}.tmp" "${1}"