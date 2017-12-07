TIMEOFEXEC=3
$CP_PRFX $INSTALLER/custom/libv4a_fx_jb_$DRVARCH.so $UNITY$LIBDIR/lib/soundfx/libv4a_fx_ics.so
# Fix for pixel 2 devices
test -f $SYS/lib/libstdc++.so && $CP_PRFX $SYS/lib/libstdc++.so $UNITY$VEN/lib/libstdc++.so