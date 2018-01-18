#!/bin/bash

# $Id$
# $HeadURL$

# Purpose: Determine what string manipulation steps I can combine into
#          sanitize_string() that won't break that function on CentOS/RHEL

#------------------------------
# Internal Field Separator
#------------------------------
# Backup of IFS
# FIXME: Needed for anything?
OIFS=${IFS}

# Set to newlines only so spaces won't trigger a new array entry and so loops
# will only consider items separated by newlines to be the next in the loop
IFS=$'\n'

echoerr() { echo "$@" 1>&2; }

sanitize_string () {

    # This process removes extraneous spaces from update strings in order to
    # change lines like these:
    #
    # xorg-x11-server-Xnest.i386              1.1.1-48.91.el5_8.2               update
    # libxml2-dev [2.7.6.dfsg-1ubuntu1.9] (2.7.6.dfsg-1ubuntu1.10 Ubuntu:10.04/lucid-updates) []
    #
    # into lines like these:
    # xorg-x11-server-Xnest.i386-1.1.1-48.91.el5_8.2
    # libxml2-dev-2.7.6.dfsg-1ubuntu1.9
    #
    # It does this by:
    # ------------------------------------------------------------------------
    #  #1) Filtering out lines that do not include numbers (they're not kept)
    #  #2) Replacing instances of multiple spaces with only one instance
    #  #3) Using a single space as a delimiter, grab fields 1 and 2
    #  #4) Replace any of '[', ']', '(', ')' or a leading spaces with nothing
    #  #5) Replace the first space encountered with a '-' character
    # ------------------------------------------------------------------------

    if $(echo "${1}" | grep -qE '[0-9]'); then
        echo "${1}" \
            | grep -Ev '^[:blank:]{1,}$' \
            | tr -s ' ' \
            | cut -d' ' -f1,2 \
            | sed -r 's/([][(\)]|^\s)//g' \
            | sed -r 's/ /-/'
    fi

}

# POC for Ubuntu:
# apt-get dist-upgrade -s \
  # | grep 'Inst' \
  # | cut -d' ' -f2,3 \
  # | sed -r 's/[][(]/ /g' \
  # | tr -s ' ' \
  # | sed 's/ /-/'
      
calculate_updates_via_apt() {
    local -a RAW_UPDATES_ARRAY

    # apt_get_filter="grep 'Inst' " \
        # "| cut -d' ' -f2,3 " \
        # "| sed -r 's/[][(]/ /g' tr -s ' ' " \
        # "| sed 's/ /-/'"

    # Capture output in array so we can clean and return it
    RAW_UPDATES_ARRAY=(
        $(
            apt-get dist-upgrade -s | grep 'Inst' | cut -c 6-
        )
    )

    for update in "${RAW_UPDATES_ARRAY[@]}"
    do
        # Return cleaned up string
        echo $(sanitize_string ${update})
        #echo $update
    done

}

calculate_updates_via_yum() {

    # TODO: Consider trimming trailing update type. I'll need a better approach
    #       than something like this however:
    # sed -r 's/-[@]{0,1}(update|lockss|base|rhel-.-server-rpms|i386|noarch)[\s]{0,1}$//'

    declare -a YUM_CHECKUPDATE_OUTPUT
 
    # Capturing output in array so we can more easily filter out what we're not 
    # interested in considering an "update". Don't toss lines without a number;
    # sanitize_string() handles that since we need to leave "Obsoleting Packages"
    # in place as a cut-off marker
    YUM_CHECKUPDATE_OUTPUT=($(cat sample_yum_check-update_output.txt))

    for line in "${YUM_CHECKUPDATE_OUTPUT[@]}"
     do
        # If we've gotten this far it means we have passed all available
        # updates and yum is telling us what old packages it will remove
        if [[ "${line}" =~ "Obsoleting Packages" ]]; then
            echo "Hit marker, breaking loop"
            break
        else
            echo $(sanitize_string ${line})
        fi
     done

}

calculate_updates_via_apt
calculate_updates_via_yum

# echo "libxml2-dbg [2.7.6.dfsg-1ubuntu1.9] (2.7.6.dfsg-1ubuntu1.10 Ubuntu:10.04/lucid-updates) []" \
    # | cut -d' ' -f1,2 \
    # | tr -s ' ' \
    # | sed -r 's/([][(\)]|^\s+)//g' \
    # | sed -r 's/ /-/'

#echo "xorg-x11-server-Xnest.i386              1.1.1-48.91.el5_8.2               update" | tr -s ' ' | sed -r 's/([][(\)]|^\s+)//g' | sed -r 's/ /-/'
# echo "xorg-x11-server-Xnest.i386              1.1.1-48.91.el5_8.2               update" \
    # | tr -s ' ' \
    # | sed -r 's/([][(\)]|^\s+)//g' \
    # | sed -r 's/ /-/'

#sanitize_string "xorg-x11-server-Xnest.i386              1.1.1-48.91.el5_8.2               update"
