#   PASMO Compiler script Copyright (C) since 1972 by Satanico, Inc.

variable scriptPath [file dirname [info script]] ;

set fdFile1 $scriptPath/diskb ;

proc norma {} {
  set throttle on
  type "dir /w\r"
}

bind F6,release "set throttle on"
bind F6 "set throttle off"
# set power off
# ext ide
# ext ram512k
# hda $hdFile
# diska $fdFile1
diskb $fdFile1
#ext msxdos2
# set power on
set fullspeedwhenloading on
# set throttle off
# after 1200 norma
