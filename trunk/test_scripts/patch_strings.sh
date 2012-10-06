#!/bin/bash

# $Id$
# $HeadURL$

# Purpose: Testing approaches to resolving ticket #105.
#     http://projects.whyaskwhy.org/issues/105)

# References (didn't use most of them, but they were informative):
# ---------------------------------
# http://stackoverflow.com/questions/1891797/capturing-groups-from-a-grep-regex
# http://stackoverflow.com/questions/2777579/sed-group-capturing
# http://stackoverflow.com/questions/6326049/grep-capture-regex



regex="[a-zA-z_0-9.-]+"

test_strings=()
test_strings[0]="kernel.x86_64                     2.6.18-308.16.1.el5                     update"
test_strings[1]="kernel.x86_64                            2.6.18-308.16.1.el5              update"
test_strings[2]="tzdata.x86_64                            2012f-1.el5                      update"
test_strings[3]="xorg-x11-server-Xnest.x86_64             1.1.1-48.91.el5_8.2              update"
test_strings[4]="xorg-x11-server-Xorg.x86_64              1.1.1-48.91.el5_8.2              update"

for test_string in "${test_strings[@]}"
do
    tmp_array=($(echo "${test_string}" | grep -Eio ${regex}))
    #echo $(echo "${test_string}" | grep -Eio ${regex})
    #echo "The size of \$tmp_array is ${#tmp_array[@]}"
    echo ${tmp_array[@]}
done
