TIMEOFEXEC=3
$CP_PRFX $INSTALLER/custom/libv4a_fx_jb_$DRVARCH.so $UNITY$LIBDIR/lib/soundfx/libv4a_fx_ics.so
# Fix for pixel 2 devices
test -f $SYS/lib/libstdc++.so && $CP_PRFX $SYS/lib/libstdc++.so $UNITY$VEN/lib/libstdc++.so
# Temp fix for oos oreo devices
if $OREONEW && [ "$(grep_prop ro.product.brand)" == "OnePlus" ]; then
  ui_print "   ! Oneplus Oreo device detected !"
  ui_print "   Setting selinux to permissive..."
  sed -i '/# SEPOLICY SETTING FUNCTION/,/# d' $MODPATH/post-fs-data.sh
  echo "setenforce 0" >> $MODPATH/post-fs-data.sh
fi
