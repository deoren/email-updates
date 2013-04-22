#!/bin/bash

# $Id$
# $HeadURL$

# Purpose: Insert available patches for a CentOS 5.x VM into the SQLite db
#          so we can test ticket #105 related changes. Note the varying
#          non-standard spacing for the entries

DB_FILE="/var/cache/email_updates/reported_updates.db"

sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"kernel.i686               2.6.18-308.16.1.el5               update\");"
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"kernel-devel.i686               2.6.18-308.16.1.el5                update\");"
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"kernel-headers.i386                         2.6.18-308.16.1.el5                  update\");"
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"tzdata.i386                  2012f-1.el5     update\");"
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"xorg-x11-server-Xnest.i386       1.1.1-48.91.el5_8.2 update\");"
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"xorg-x11-server-Xorg.i386       1.1.1-48.91.el5_8.2            update\");"
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"xorg-x11-server-Xvfb.i386                   1.1.1-48.91.el5_8.2 update\");"
