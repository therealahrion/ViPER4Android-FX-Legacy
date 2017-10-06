# v DO NOT MODIFY v
# See instructions file for predefined variables
# User defined custom rules
# Can have multiple ones based on when you want them to be run
# You can create copies of this file and name is the same as this but with the next number after it (ex: unity-customrules2.sh)
# See instructions for TIMEOFEXEC values, do not remove it
# ^ DO NOT MODIFY ^
TIMEOFEXEC=2
$CP_PRFX $INSTALLER/custom/libv4a_fx_jb_$DRVARCH.so $UNITY$SYS/lib/soundfx/libv4a_fx_ics.so
