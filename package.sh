#!/bin/bash

# Use Cadius to create a disk image for distribution
# https://github.com/mach-kernel/cadius

set -e

IMGFILE="basys33.po"
VOLNAME="basys33"

# Create a new disk image.

rm -f "$IMGFILE"
cadius CREATEVOLUME "$IMGFILE" "$VOLNAME" 140KB --quiet --no-case-bits

cp "basis.system.SYS" "basis.system#FF0000"
cadius ADDFILE "$IMGFILE" "/$VOLNAME" "basis.system#FF0000" --quiet --no-case-bits
rm -f "basis.system#FF0000"
