#!/usr/bin/env bash

# Simple script to copy WAL archives from one server to another
# to be called as archive_command (call this as wal_archive "%p" "%f")

# Version 1.6.  Last updated 2011-02-17.

# Copyright (c) 2010-2011, PostgreSQL, Experts, Inc.
# Licensed under The PostgreSQL License; see
# http://www.postgresql.org/about/licence
# or the end of this file for details.

# source config file

. /var/lib/postgresql/pitr-replication.conf

SOURCE="$1" # %p

FILE="$2" # %f

DEST="${WALDIR}/${FILE}"
TEMPDEST="${WALDIR}/.${FILE}"

# See whether we want all archiving off

test -f ${NOARCHIVEFILE} && exit 0

# Copy the file to the spool area on the replica, error out if the file is

# already there or ends up as length 0


cat ${SOURCE} | ssh ${SSH_OPT} ${REPLICA} \
        "cat - > ${TEMPDEST}; if test -s ${TEMPDEST}; then if test -e ${DEST} ; then echo "${DEST} already exists, removing" >> ${REPLICATION_LOG};     rm -f ${DEST} ;   fi;   mv -f ${TEMPDEST} ${DEST}; else   exit 1; fi"
if [ $? -ne 0 ]; then
        exit 1
fi

# Copy elsewhere if you like.

if [ -f ${LOCAL_DESTINATIONS_LIST} ]; then
        while read LDEST ; do
                DEST="${LDEST}/${FILE}"
                ${CP} "${SOURCE}" ${DEST} || exit $?
        done < ${LOCAL_DESTINATIONS_LIST}
fi

# -----------------------------------------------------------------------------
# The replication-tools package is licensed under the PostgreSQL License:
#
# Copyright (c) 2010-2011, PostgreSQL, Experts, Inc.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose, without fee, and without a written agreement is
# hereby granted, provided that the above copyright notice and this paragraph
# and the following two paragraphs appear in all copies.
#
# IN NO EVENT SHALL POSTGRESQL EXPERTS, INC. BE LIABLE TO ANY PARTY FOR DIRECT,
# INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST
# PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN
# IF POSTGRESQL EXPERTS, INC. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.
#
# POSTGRESQL EXPERTS, INC. SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT
# NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS,
# AND POSTGRESQL EXPERTS, INC. HAS NO OBLIGATIONS TO PROVIDE MAINTENANCE,
# SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
