#!/bin/sh

/web/service-phigita/packages/news/bin/tc-dump.sh
rm -rf /web/data/news/tc/*
mkdir /web/data/news/tc/topic
mkdir /web/data/news/tc/edition

/web/service-phigita/packages/news/bin/tc-unfold.tcl /web/data/news/tmp/tc.psv /web/data/news/tc/
/web/service-phigita/packages/news/bin/tc-index.sh

