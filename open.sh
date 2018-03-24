#!/bin/sh

cmd=$1
shift
if ! which $cmd ; then
    open -a $cmd --args $@
else
    $cmd $@
fi
