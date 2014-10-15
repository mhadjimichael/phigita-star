#!/bin/bash


###################################################################

WEBHOME=/web
source ${WEBHOME}/bin/install-env.sh

###################################################################

# for shell
${WEBHOME}/bin/install-tcl.sh ${TCLHOME} local-
${WEBHOME}/bin/install-libthread.sh ${TCLHOME} local-
${WEBHOME}/bin/install-tdom.sh ${TCLHOME} local-
${WEBHOME}/bin/install-xotcl.sh ${TCLHOME} local-
${WEBHOME}/bin/install-tcllib.sh ${TCLHOME} local-
${WEBHOME}/bin/install-tclcurl.sh ${TCLHOME} local-
${WEBHOME}/bin/install-tclgd.sh ${TCLHOME} local-
${WEBHOME}/bin/install-ttext-deps.sh ${TCLHOME} local-

