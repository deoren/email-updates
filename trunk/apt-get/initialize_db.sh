#!/bin/bash

# $Id$
# $HeadURL$

# Purpose:
#   Test initialize_db function for main email_updates.sh script

# References:
#   * http://quickies.andreaolivato.net/post/133473114/using-sqlite3-in-bash
#   * The Definitive Guide to SQLite, 2e


#########################
# Settings
#########################

DEBUG_ON=1

# Just in case it's not already there (for sqlite3)
PATH="${PATH}:/usr/bin"
TODAY=$(date "+%B %d %Y")

# Schema for database:
DB_STRUCTURE="CREATE TABLE data (id INTEGER PRIMARY KEY,patch TEXT,time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);"

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

#############################
# Main Code
#############################

initialize_db
