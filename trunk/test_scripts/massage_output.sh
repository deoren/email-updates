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


sanitize_string () {

    # This process removes extraneous spaces from update strings in order to
    # change something like this:
    #
    # xorg-x11-server-Xnest.i386              1.1.1-48.91.el5_8.2               update
    #
    # into this:
    # xorg-x11-server-Xnest.i386 1.1.1-48.91.el5_8.2 update
    #
    # It does this by replacing every instance of two spaces with one,
    # repeating until finished AND then replaces all leading spaces

    echo "${1}" \
        | grep '[0-9]' \
        | tr -s ' ' \
        | cut -d' ' -f1,2 \
        | sed -r 's/([][(\)]|^\s+)//g' \
        | sed -r 's/ /-/'
    
            # apt-get dist-upgrade -s \
            # | grep 'Inst' \
            # | cut -d' ' -f2,3 \
            # | sed -r 's/[][(]/ /g' \
            # | tr -s ' ' \
            # | sed 's/ /-/'

    
    # NOTE: This is a stub entry for later use (see #112).
    
    # yum check-update -C \
       # | grep -i -E "[0-9]" \
       # | tr -s ' ' \
       # | sed -r 's/^\s+//g' \
       # | cut -d' ' -f1,2 \
       # | sed -r 's/\s/-/g'


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

    local -a YUM_CHECKUPDATE_OUTPUT
 
    # Capturing output in array so we can more easily filter out what we're not 
    # interested in considering an "update"
    YUM_CHECKUPDATE_OUTPUT=($(cat sample_yum_check-update_output.txt | grep '[0-9]'))
 
    if [[ "${DEBUG_ON}" -ne 0 ]]; then
        echoerr "Contents of \"$YUM_CHECKUPDATE_OUTPUT\":"
    fi

    for line in "${YUM_CHECKUPDATE_OUTPUT[@]}"
     do
        # If we've gotten this far it means we have passed all available
        # updates and yum is telling us what old packages it will remove
        if [[ "${line}" =~ "Obsoleting Packages" ]]; then
            break
        else
            if [[ "${DEBUG_ON}" -ne 0 ]]; then
                echoerr $line
            fi

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
