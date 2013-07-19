#!/bin/bash

# $Id$
# $HeadURL$

# Purpose: Determine what string manipulation steps I can combine into
#          sanitize_string() that won't break that function on CentOS/RHEL

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

    echo ${1} | sed -r 's/[ \t ]{2,}/ /g' | sed -r 's/^\s+//'

    
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
            apt-get dist-upgrade -s \
            | grep 'Inst' \
            | cut -d' ' -f2,3 \
            | sed -r 's/[][(]/ /g' \
            | tr -s ' ' \
            | sed 's/ /-/'
        )
    )

    for update in "${RAW_UPDATES_ARRAY[@]}"
    do
        # Return cleaned up string
        #echo $(sanitize_string ${update})
        echo $update
    done

}

calculate_updates_via_apt
