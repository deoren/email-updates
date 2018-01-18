#!/bin/bash

# $Id$
# $HeadURL$

# Purpose: Determine which distro this script is running on and
#          call the correct function

# Match settings used in main script
OIFS=${IFS}
IFS=$'\n'

# From a RHEL4 box on extended support
# Red Hat Enterprise Linux AS release 4 (Nahant Update 9)

# From an Ubunut 12.04.x LTS system
#DISTRIB_ID=Ubuntu
#DISTRIB_RELEASE=12.04
#DISTRIB_CODENAME=precise
#DISTRIB_DESCRIPTION="Ubuntu 12.04.1 LTS"

MATCH_RHEL4='Red Hat Enterprise Linux.*4'
MATCH_RHEL5='Red Hat Enterprise Linux.*5'
MATCH_UBUNTU='Ubuntu'
MATCH_CENTOS='CentOS'

# Mash the contents into a single string - not creating an array via ()
RELEASE_INFO=$(cat /etc/*release)

echo "RELEASE_INFO is $RELEASE_INFO"


detect_supported_distros () {

    if [[ "${RELEASE_INFO}" =~ ${MATCH_RHEL4} ]]; then
        echo "up2date"
    fi

    if [[ "${RELEASE_INFO}" =~ ${MATCH_RHEL5} ]]; then
        echo "yum"
    fi

    if [[ "${RELEASE_INFO}" =~ ${MATCH_CENTOS} ]]; then
        echo "yum"
    fi

    if [[ "${RELEASE_INFO}" =~ ${MATCH_UBUNTU} ]]; then
        echo "apt"
    fi

}

#detect_supported_distros

THIS_DISTRO=$(detect_supported_distros)



case "${THIS_DISTRO}" in
    up2date ) echo "We'll use up2date to patch this distro"
        ;;
    apt     ) echo "We'll use apt-get to patch this distro"
        ;;
    yum     ) echo "We'll use yum to patch this distro"
        ;;
esac
