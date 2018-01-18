#!/bin/bash

# $Id$
# $HeadURL$

# Purpose: Insert available patches for a CentOS 5.x VM into the SQLite db
#          so we can test ticket #105 related changes. Note the varying
#          non-standard spacing for the entries

DB_FILE="/var/cache/email_updates/reported_updates.db"

# FIXME: Create Bash function instead of using external dirname tool?
DB_FILE_DIR=$(dirname ${DB_FILE})

# Schema for database
DB_STRUCTURE="CREATE TABLE reported_updates (id INTEGER PRIMARY KEY, package TEXT, time TIMESTAMP NOT NULL DEFAULT (datetime('now','localtime')));"

initialize_db() {

    echo -e '\n\n************************'
    echo "Initializing Database"
    echo -e   '************************'

    # Check if cache dir already exists
    if [[ ! -d ${DB_FILE_DIR} ]]; then
        echo "[I] Creating ${DB_FILE_DIR}"
        mkdir ${DB_FILE_DIR}
    fi

    # Check if database already exists
    if [[ -f ${DB_FILE} ]]; then
        echo "[I] ${DB_FILE} already exists, leaving it be."
        return 0
    else
        # if not, create it
        echo "[I] Creating ${DB_FILE}"
        sqlite3 ${DB_FILE} "${DB_STRUCTURE}"
    fi

}

# Create SQLite DB if it doesn't already exist
initialize_db

# Insert test values
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"language-selector-common       [0.79.2]         (0.79.3      Ubuntu:12.04/precise-updates [all])\");"
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"openssh-server [1:5.9p1-5ubuntu1] (1:5.9p1-5ubuntu1.1 Ubuntu:12.04/precise-updates                     [amd64]) []\");"
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"openssh-client [1:5.9p1-5ubuntu1]         (1:5.9p1-5ubuntu1.1 Ubuntu:12.04/precise-updates [amd64])\");"
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"python-problem-report   [2.0.1-0ubuntu17.1] (2.0.1-0ubuntu17.2              Ubuntu:12.04/precise-updates                 [all])\");"
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"python-apport [2.0.1-0ubuntu17.1] (2.0.1-0ubuntu17.2 Ubuntu:12.04/precise-updates       [all])\");"
sqlite3 ${DB_FILE} "INSERT INTO reported_updates (package) VALUES (\"apport [2.0.1-0ubuntu17.1] (2.0.1-0ubuntu17.2 Ubuntu:12.04/precise-updates [all])\");"
