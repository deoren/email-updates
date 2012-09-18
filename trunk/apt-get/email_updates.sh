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

verify_dependencies {

    # Verify that all dependencies are present
    # sqlite3, mail|mailx, ?

}

initialize_db {

    # Check if database already exists
    if [[ -f ${DB_FILE} ]]; then
        return 0
    else
            
        # if not, create it
        sqlite3 ${DB_FILE} ${DB_STRUCTURE}
    fi
}

patch_already_reported {

    # $1 should equal the quoted patch that we're checking

    # See if the selected patch has already been reported
    # FIXME: Use proper quoting and comparison
    sqlite3 ${DB_FILE} "select * from data where patch = $1;"

}



# Get list of all available packages for the OS
apt-get update > /dev/null

# This is checked before too much processing happens to see if there are ANY updates available, regardless
# of whether they've already been reported.
RESULT=$(apt-get dist-upgrade -s)



# FIXME: T
ALREADY_REPORTED[0]='icedtea-netx [1.1.3-1ubuntu1.1] (1.2-2ubuntu0.11.10.3 Ubuntu:11.10/oneiric-updates [i386])'


# If updates are available ...
if [[ "${RESULT}" =~ "Inst" ]]; then

    AVAILABLE_UPDATES=($(apt-get dist-upgrade -s | grep -iE '^Inst.*$'|cut -c 6-))

    for i in "${AVAILABLE_UPDATES[@]}" 
    do
        # FIXME: This will need to check if the entry is already in the database from being
        #        previously reported.
        if [[ "$i" == "${ALREADY_REPORTED[0]}" ]]; then
            echo "$i equals the string, skipping this update"
	else
	  # Placeholder for adding the patch to the PATCHES_TO_REPORT
          # array and also to the database
	  :
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

