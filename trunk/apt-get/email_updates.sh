#!/bin/bash

# $Id$
# $HeadURL$

# Purpose:
#   This script is intended to be run once daily to report any patches
#   available for the OS. If a particular patch has been reported previously
#   the goal is to NOT report it again unless requested (via FLAG).

# References:
#   * http://quickies.andreaolivato.net/post/133473114/using-sqlite3-in-bash
#   * The Definitive Guide to SQLite, 2e


#########################
# Settings
#########################

DEBUG_ON=1

# Just in case it's not already there (for sqlite3)
PATH="${PATH}:/usr/bin"

# Redmine tags
EMAIL_TAG_PROJECT="server-support"
EMAIL_TAG_CATEGORY="Patch"
EMAIL_TAG_STATUS="Assigned"

DEST_EMAIL="updates-notification@example.org"
TEMP_FILE="/tmp/updates_list_$$.tmp"
TODAY=$(date "+%B %d %Y")

# Schema for database:
DB_STRUCTURE="CREATE TABLE data (id INTEGER PRIMARY KEY,patch TEXT,time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);"

DB_FILE="/var/cache/email_updates/apt-get.db"

# FIXME: Create Bash function instead of using external dirname tool?
DB_FILE_DIR=$(dirname ${DB_FILE})

# Anything required for this script to run properly
DEPENDENCIES=(

    sqlite3
    mailx

)

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
            if [ ${DEBUG_ON} ]; then
                echo "[I] ${dependency} found."
            fi
        else
            echo "[!] ${dependency} missing. Please install then try again."
            exit 1
        fi

    done
}


initialize_db() {

    # Check if cache dir already exists
    if [[ ! -d ${DB_FILE_DIR} ]]; then
        if [ ${DEBUG_ON} ]; then
            echo "Creating ${DB_FILE_DIR}"
        fi
        mkdir ${DB_FILE_DIR}
    fi

    # Check if database already exists
    if [[ -f ${DB_FILE} ]]; then
        if [ ${DEBUG_ON} ]; then
            echo "${DB_FILE} already exists"
        fi
        return 0
    else
        # if not, create it
        if [ ${DEBUG_ON} ]; then
            echo "Creating ${DB_FILE}"
        fi
        sqlite3 ${DB_FILE} ${DB_STRUCTURE}
    fi
}


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
# Setup
#############################

# Make sure we have sqlite3, mailx and other necessary tools installed
verify_dependencies

# Create SQLite DB if it doesn't already exist
initialize_db

# Get list of all available packages for the OS
# FIXME: Enable this later. During testing I don't want to hammer other servers
#        and will run this once manually prior to testing script changes.
#apt-get update > /dev/null

# This is checked before too much processing happens to see if there are ANY 
# updates available, regardless of whether they've already been reported.
RESULT=$(apt-get dist-upgrade -s)


#############################
# Main Code
#############################


# If updates are available ...
if [[ "${RESULT}" =~ "Inst" ]]; then

    # Create an array containing all updates, one per array member
    AVAILABLE_UPDATES=($(apt-get dist-upgrade -s | grep -iE '^Inst.*$'|cut -c 6-))

    for update in "${AVAILABLE_UPDATES[@]}" 
    do
        # Check to see if the patch has been previously reported
        if $(is_patch_already_reported ${update})
        then
            echo "[S] ${update}"
        else
            echo "[I] ${update}"
        fi
    done

    # Write list of applicable updates to temp file
#    apt-get dist-upgrade -s | grep 'Inst' | cut -c 6-500 | sort > ${TEMP_FILE}
#    NUMBER_OF_UPDATES=`cat ${TEMP_FILE} | wc -l`

#    EMAIL_SUBJECT="${HOSTNAME}: ${NUMBER_OF_UPDATES} updates are available"

    # Tag report with Redmine compliant keywords
    # http://www.redmine.org/projects/redmine/wiki/RedmineReceivingEmails
#    echo "Project: ${EMAIL_TAG_PROJECT}" >> ${TEMP_FILE}
#    echo "Category: ${EMAIL_TAG_CATEGORY}" >> ${TEMP_FILE}
#    echo "Status: ${EMAIL_TAG_STATUS}" >> ${TEMP_FILE}

    # Send the report via email
#    cat ${TEMP_FILE} | mail -s "${EMAIL_SUBJECT}" ${DEST_EMAIL}
fi

