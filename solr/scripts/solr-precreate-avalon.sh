#!/bin/bash
#
# This is for docker!
# Creates both a development and test core.
#
# This script was mostly stolen from the official solr-precreate script:
# https://github.com/docker-solr/docker-solr/blob/master/scripts/solr-precreate
set -e

echo "Executing $0 $@"

if [[ "$VERBOSE" = "yes" ]]; then
    set -x
fi

if [[ -z $SOLR_HOME ]]; then
    coresdir="/opt/solr/server/solr/mycores"
    mkdir -p $coresdir
else
    coresdir=$SOLR_HOME
fi

coredir_dev="$coresdir/avalon_development"
if [[ ! -d $coredir_dev ]]; then
    cp -r /config/ $coredir_dev
    touch "$coredir_dev/core.properties"
    echo "created development core at $coredir_dev"
else
    echo "core development already exists"
fi

coredir_test="$coresdir/avalon_test"
if [[ ! -d $coredir_test ]]; then
    cp -r /config/ $coredir_test
    touch "$coredir_test/core.properties"
    echo "created test core at $coredir_test"
else
    echo "core test already exists"
fi
