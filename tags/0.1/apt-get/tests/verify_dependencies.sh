#!/bin/bash

# $Id$
# $HeadURL$

# Purpose:
#   Test verify_dependencies function for main email_updates.sh script


#########################
# Settings
#########################

DEBUG_ON=1

# Just in case it's not already there (for sqlite3)
PATH="${PATH}:/usr/bin"

DEPENDENCIES=(

    sqlite3
    mailx

)

#########################
# Functions
#########################

verify_dependencies() {

    # Verify that all dependencies are present
    # sqlite3, mail|mailx, ?

    for dependency in ${DEPENDENCIES[@]} 
    do
        # Debug output
        #echo "$(which ${dependency}) ${dependency}"

        # Try to locate the dependency within the path. If found, compare
        # the basename of the dependency against the full path. If there
        # is a match, consider the required dependency present on the system
        if [[ "$(which ${dependency})" =~ "${dependency}" ]]; then
            if [[ "${DEBUG_ON}" -ne 0 ]]; then
                echo "[I] ${dependency} found."
            fi
        else
            echo "[!] ${dependency} missing. Please install then try again."
            exit 1
        fi

    done
}


#############################
# Main Code
#############################

verify_dependencies
