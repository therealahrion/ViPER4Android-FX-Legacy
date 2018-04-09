if $BOOTMODE; then
  ui_print "   Uninstalling V4A app..."
  case $(find /data/app -type d -name "*com.pittvandewitt.viperfx*" -o -name "*com.audlabs.viperfx*" -o -name "*com.vipercn.viper4android_v2*") in
    *com.pittvandewitt.viperfx*) /system/bin/pm uninstall com.pittvandewitt.viperfx;;
    *com.audlabs.viperfx*) /system/bin/pm uninstall com.audlabs.viperfx;;
    *com.vipercn.viper4android*) /system/bin/pm uninstall com.vipercn.viper4android_v2;;
  esac
else
  ui_print "   V4A apk will need uninstalled manually!"
fi

$MAGISK || { for FILE in ${CFGS}; do
               case $FILE in
                 *.conf) sed -i "/v4a_standard_fx { #$MODID/,/} #$MODID/d" $UNITY$FILE
                         sed -i "/v4a_fx { #$MODID/,/} #$MODID/d" $UNITY$FILE;;
                 *.xml) sed -i "/<!--$MODID-->/d" $UNITY$FILE;;
               esac
             done }
