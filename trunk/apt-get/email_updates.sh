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
#   * http://www.thegeekstuff.com/2010/06/bash-array-tutorial/
#   * http://stackoverflow.com/questions/5431909/bash-functions-return-boolean-to-be-used-in-if
#   * http://mywiki.wooledge.org/BashPitfalls
#   * http://stackoverflow.com/questions/1063347/passing-arrays-as-parameters-in-bash
#   * http://wiki.bash-hackers.org/commands/classictest


#########################
# Settings
#########################

# Not a bad idea to run with this enabled for a while after big changes
# and have cron deliver the output to you for verification
DEBUG_ON=1

# Usually not needed
VERBOSE_DEBUG_ON=0

# Useful for testing where we don't want to bang on upstream servers too much
SKIP_APT_GET_UPDATE=0

# Just in case it's not already there (for sqlite3)
PATH="${PATH}:/usr/bin"

# Redmine tags
EMAIL_TAG_PROJECT="server-support"
EMAIL_TAG_CATEGORY="Patch"
EMAIL_TAG_STATUS="Assigned"

# Set this to a valid email address if you want to have this
# report appear to come from that address.
SENDER_EMAIL=""

# Where should the email containing the list of updates go?
DEST_EMAIL="updates-notification@example.org"
TEMP_FILE="/tmp/updates_list_$$.tmp"
TODAY=$(date "+%B %d %Y")

# Schema for database:
DB_STRUCTURE="CREATE TABLE data (id INTEGER PRIMARY KEY,patch TEXT,time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP);"

# In which field in the database is patch information stored?
DB_PATCH_FIELD=2

DB_FILE="/var/cache/email_updates/reported_updates.db"

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
# FIXME: Needed for anything?
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
    if [[ "${DEBUG_ON}" -ne 0 ]]; then
        echo -e '\n\n************************'
        echo "Dependency checks"
        echo -e   '************************'
    fi

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


initialize_db() {

    if [[ "${DEBUG_ON}" -ne 0 ]]; then
        echo -e '\n\n************************'
        echo "Initializing Database"
        echo -e   '************************'
    fi

    # Check if cache dir already exists
    if [[ ! -d ${DB_FILE_DIR} ]]; then
        if [[ "${DEBUG_ON}" -ne 0 ]]; then
            echo "[I] Creating ${DB_FILE_DIR}"
        fi
        mkdir ${DB_FILE_DIR}
    fi

    # Check if database already exists
    if [[ -f ${DB_FILE} ]]; then
        if [[ "${DEBUG_ON}" -ne 0 ]]; then
            echo "[I] ${DB_FILE} already exists, leaving it be."
        fi
        return 0
    else
        # if not, create it
        if [[ "${DEBUG_ON}" -ne 0 ]]; then
            echo "[I] Creating ${DB_FILE}"
        fi
        sqlite3 ${DB_FILE} ${DB_STRUCTURE}
    fi

}


is_patch_already_reported() {

    # $1 should equal the quoted patch that we're checking

    query_result=$(sqlite3 "${DB_FILE}" "SELECT * FROM data WHERE patch = \"$1\";" | cut -d '|' -f ${DB_PATCH_FIELD})

    # See if the selected patch has already been reported
    if [[ "$query_result" == "${1}" ]]; then
        # Report a match
        return 0
    else
        # Report no match
        return 1
    fi
}


print_patch_arrays() {

    # This function is useful for getting debug output "on demand"
    # when the global debug option is disabled

    #NOTE: Relies on global variables

    echo -e '\n\n***************************************************'
    #echo "${#UNREPORTED_UPDATES[@]} unreported update(s) are available"
    echo "UNREPORTED UPDATES"
    echo -e '***************************************************\n'
    echo -e "  ${#UNREPORTED_UPDATES[@]} unreported update(s) are available\n"

    for unreported_update in "${UNREPORTED_UPDATES[@]}"
    do
        echo "  * ${unreported_update}"
    done

    echo -e '\n***************************************************'
    #echo "${#SKIPPED_UPDATES[@]} skipped update(s) are available"
    echo "SKIPPED UPDATES"
    echo -e '***************************************************\n'
    echo -e "  ${#SKIPPED_UPDATES[@]} skipped update(s) are available\n"

    for skipped_update in "${SKIPPED_UPDATES[@]}"
    do
        echo "  * ${skipped_update}"
    done

}


email_report() {

    # $@ is ALL arguments to this function, i.e., the unreported patches
    updates=(${@})

    # Use $1 array function argument
    NUMBER_OF_UPDATES="${#updates[@]}"
    EMAIL_SUBJECT="${HOSTNAME}: ${NUMBER_OF_UPDATES} update(s) are available"

    # Write updates to the temp file
    for update in "${updates[@]}"
    do
        echo "${update}" >> ${TEMP_FILE}
    done

    echo " " >> ${TEMP_FILE}

    # Tag report with Redmine compliant keywords
    # http://www.redmine.org/projects/redmine/wiki/RedmineReceivingEmails
    echo "Project: ${EMAIL_TAG_PROJECT}" >> ${TEMP_FILE}
    echo "Category: ${EMAIL_TAG_CATEGORY}" >> ${TEMP_FILE}
    echo "Status: ${EMAIL_TAG_STATUS}" >> ${TEMP_FILE}

    # Send the report via email
    # If user chose to masquerade this email as a specific user, set the value
    if [[ ! -z ${SENDER_EMAIL} ]]; then
        mail -s "${EMAIL_SUBJECT}" --append=FROM:${SENDER_EMAIL} ${DEST_EMAIL} < ${TEMP_FILE}
    else
        # otherwise, just use whatever user account this script runs as
        # (which is usually root)
        mail -s "${EMAIL_SUBJECT}" ${DEST_EMAIL} < ${TEMP_FILE}
    fi

}


record_reported_patches() {

    # $@ is ALL arguments to this function, i.e., the unreported patches
    updates=(${@})

    # Add reported patches to the database

    for update in "${updates[@]}"
    do
        sqlite3 ${DB_FILE} "insert into data (patch) values (\"${update}\");"
    done

}


#############################
# Setup
#############################

# Make sure we have sqlite3, mailx and other necessary tools installed
verify_dependencies

# Create SQLite DB if it doesn't already exist
initialize_db


if [[ "${DEBUG_ON}" -ne 0 ]]; then
    echo -e '\n\n************************'
    echo "Checking for updates ..."
    echo -e   '************************'
fi


# Get list of all available packages for the OS if running in production mode
if [[ "${SKIP_APT_GET_UPDATE}" -eq 0 ]]; then
    apt-get update > /dev/null
fi

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

    declare -a UNREPORTED_UPDATES SKIPPED_UPDATES

    for update in "${AVAILABLE_UPDATES[@]}"
    do
        # Check to see if the patch has been previously reported
        if $(is_patch_already_reported ${update}); then

            # Skip the update, but log it for troubleshooting purposes
            SKIPPED_UPDATES=("${SKIPPED_UPDATES[@]}" "${update}")

            if [[ "${VERBOSE_DEBUG_ON}" -ne 0 ]]; then
                echo "[SKIP] ${update}"
            fi

        else
            # Add the update to an array to be reported
            # FIXME: There is a bug here that results in a duplicate item
            UNREPORTED_UPDATES=("${UNREPORTED_UPDATES[@]}" "${update}")

            if [[ "${VERBOSE_DEBUG_ON}" -ne 0 ]]; then
                echo "[INCL] ${update}"
            fi
        fi
    done

    print_patch_arrays

    # If we're not in debug mode, send an email
    if [[ "${DEBUG_ON}" -eq 0 ]]; then    
        # If there are no updates, DON'T send an email
        if [[ ! ${#UNREPORTED_UPDATES[@]} -gt 0 ]]; then
            :
        else
            # There ARE updates, so send the email
            email_report "${UNREPORTED_UPDATES[@]}"
        fi
    fi

    record_reported_patches "${UNREPORTED_UPDATES[@]}"

else

    if [[ "${DEBUG_ON}" -ne 0 ]]; then
        echo -e '\n\n************************'
        echo "No updates found"
        echo -e   '************************'
    fi

    # The "do nothing" operator in case DEBUG_ON is off
    # FIXME: Needed?
    :

fi
