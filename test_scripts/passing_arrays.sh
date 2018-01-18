#!/bin/bash

# $Id: is_patch_already_reported.sh 17 2012-09-19 01:02:05Z deoren $
# $HeadURL: https://svn.whyaskwhy.org/whyaskwhy.org/projects/email_updates/trunk/apt-get/is_patch_already_reported.sh $

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

DEBUG_ON=0

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


print_patches_array() {

    # This function is kind of redundant, but I'm leaving it in anyway for now
    
    #FIXME: Test with a LARGE number of available updates
    #       Q: 
    updates=(${@})

    echo "${#updates[@]} unreported update(s) are available"

    for update in "${updates[@]}" 
    do
        echo "  * ${update}"
    done

}


#############################
# Main Code
#############################


# Create an array containing all updates, one per array member
AVAILABLE_UPDATES=($(apt-get dist-upgrade -s | grep -iE '^Inst.*$'|cut -c 6-))

echo "${#AVAILABLE_UPDATES[@]} updates are available"

declare -a UNREPORTED_UPDATES

for update in "${AVAILABLE_UPDATES[@]}" 
do
    # Check to see if the patch has been previously reported
    if $(is_patch_already_reported ${update}); then

        # Skip the update
        if [[ "${DEBUG_ON}" -ne 0 ]]; then                
            echo "[S] ${update}"
        fi
    else
        # Add the update to an array to be reported
        # FIXME: There is a bug here that results in a duplicate item
        UNREPORTED_UPDATES=("${UNREPORTED_UPDATES[@]}" "${update}")
        
        if [[ "${DEBUG_ON}" -ne 0 ]]; then                
            echo "[I] ${update}"
        fi            
    fi
done

print_patches_array "${UNREPORTED_UPDATES[@]}"

