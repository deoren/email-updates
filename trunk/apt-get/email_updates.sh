#!/bin/bash

# $Id$
# $HeadURL$

# Purpose:
#   This script is intended to be run once daily to report any patches
#   available for the OS. If a particular patch has been reported previously
#   the goal is to NOT report it again unless requested (via FLAG).

# Get list of all available packages for the OS
apt-get update > /dev/null

RESULT=$(apt-get dist-upgrade -s)

# Redmine tags
EMAIL_TAG_PROJECT="server-support"
EMAIL_TAG_CATEGORY="Patch"
EMAIL_TAG_STATUS="Assigned"

DEST_EMAIL="updates-notification@example.org"
TEMP_FILE="/tmp/updates_list_$$.tmp"
TODAY=`date "+%B %d %Y"`

TEST_UPDATE='Inst libexchange-storage1.2-3 [2.28.3.1-0ubuntu6] (2.28.3.1-0ubuntu6.1 Ubuntu:10.04/lucid-updates)'

# If updates are available ...
if [[ "${RESULT}" =~ "Inst" ]]; then

    IFS=$'\n'
    testing=($(apt-get dist-upgrade -s | grep -iE '^Inst.*$'))
    #echo ${testing[@]}

    for i in "${testing[@]}" 
    do
        if [[ "$i" == "${TEST_UPDATE}" ]]; then
            echo "$i equals the string" 
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

