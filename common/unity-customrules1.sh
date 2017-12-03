TIMEOFEXEC=3
if [ $API -ge 26 ]; then
  $CP_PRFX $INSTALLER/custom/libv4a_fx_jb_$DRVARCH.so $UNITY$VEN/lib/soundfx/libv4a_fx_ics.so
else
  $CP_PRFX $INSTALLER/custom/libv4a_fx_jb_$DRVARCH.so $UNITY$SYS/lib/soundfx/libv4a_fx_ics.so
fi
