#!/system/bin/sh
# This script will be executed in late_start service mode
# More info in the main Magisk thread

#### v INSERT YOUR CONFIG.SH MODID v ####
MODID=v4afx
#### ^ INSERT YOUR CONFIG.SH MODID ^ ####

########## v DO NOT REMOVE v ##########
rm -rf /cache/magisk/audmodlib

rm -f /magisk/audmodlib/update

rm -f /magisk/.core/service.d/$MODID.sh
########## ^ DO NOT REMOVE ^ ##########

#### v INSERT YOUR REMOVE PATCH OR RESTORE v ####
#### ^ INSERT YOUR REMOVE PATCH OR RESTORE ^ ####