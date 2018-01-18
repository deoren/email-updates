#!/bin/bash

# $Id$
# $HeadURL$

# Purpose:
#   Testing is_patch_already_reported() function

# References:
#   * http://quickies.andreaolivato.net/post/133473114/using-sqlite3-in-bash
#   * The Definitive Guide to SQLite, 2e
#   * http://stackoverflow.com/questions/5431909/bash-functions-return-boolean-to-be-used-in-if
#   * http://mywiki.wooledge.org/BashPitfalls


#########################
# Settings
#########################

DEBUG_ON=1

# Just in case it's not already there (for sqlite3)
PATH="${PATH}:/usr/bin"

# In which field in the database is patch information stored?
DB_PATCH_FIELD=2

DB_FILE="/var/cache/email_updates/apt-get.db"

# FIXME: Create Bash function instead of using external dirname tool?
DB_FILE_DIR=$(dirname ${DB_FILE})

#------------------------------
# Internal Field Separator
#------------------------------
# Backup of IFS
OIFS=${IFS}

# Set to newlines only so spaces won't trigger a new array entry and so loops
# will only consider items separated by newlines to be the next in the loop
IFS=$'\n'

#########################
# Functions
#########################


is_patch_already_reported() {

    # $1 should equal the quoted patch that we're checking

    query_result=$(sqlite3 "${DB_FILE}" "SELECT * FROM data WHERE patch = \"$1\";" | cut -d '|' -f ${DB_PATCH_FIELD})

    # See if the selected patch has already been reported
    if [[ "$query_result" == "${1}" ]]; then
        # The goal is to report a match
        #echo "Match"
        return 0
    else
        # Report no match
        #echo "No match"
        return 1
    fi
}


#############################
# Main Code
#############################

test_result=$(is_patch_already_reported 'libkactivities-bin [4:4.8.4-0ubuntu0.1] (4:4.8.5-0ubuntu0.1 Ubuntu:12.04/precise-updates [i386])')
echo $test_result

#is_patch_already_reported 'libkactivities-bin [4:4.8.4-0ubuntu0.1] (4:4.8.5-0ubuntu0.1 Ubuntu:12.04/precise-updates [i386])'

# This form doesn't work
if [[ $test_result ]]
then
  echo "First attempt succeeds"
else
  echo "First attempt fails"
fi

# This one does?
if $test_result
then
  echo "Second attempt works"
else
  echo "Second attempt fails"
fi

# Create an array containing all updates, one per array member
AVAILABLE_UPDATES=($(apt-get dist-upgrade -s | grep -iE '^Inst.*$'|cut -c 6-))

echo "${#AVAILABLE_UPDATES[@]} updates are available"

for update in "${AVAILABLE_UPDATES[@]}" 
do
    # Check to see if the patch has been previously reported
    # Note: If the value were assigned to a variable and then tested
    #       the test would fail. I don't remember why (it's been too long
    #       since I used Bash regularly).
    if $(is_patch_already_reported ${update})
    then
        echo "[S] ${update}"
    else
        echo "[I] ${update}"
    fi
done

