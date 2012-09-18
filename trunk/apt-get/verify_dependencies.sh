#!/bin/bash

# $Id$
# $HeadURL$

# Purpose:
#   Test verify_dependencies function for main email_updates.sh script


#########################
# Settings
#########################

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

        if [[ "$(which ${dependency})" =~ "${dependency}" ]]; then
           echo "Found ${dependency}"
        fi

    done
}


#############################
# Main Code
#############################

verify_dependencies
