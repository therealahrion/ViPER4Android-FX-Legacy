MATV4A=$(find /data/app -type d -name "*com.pittvandewitt.viperfx*")
[ "$MATV4A" ] && if $BOOTMODE; then ui_print "   Uninstalling V4A app..."; pm uninstall com.pittvandewitt.viperfx; else ui_print "   Removing V4A app..."; rm -rf $MATV4A; fi
$MAGISK || { for FILE in ${CFGS}; do
               case $FILE in
                 *.conf) sed -i "/v4a_standard_fx { #$MODID/,/} #$MODID/d" $UNITY$FILE
                         sed -i "/v4a_fx { #$MODID/,/} #$MODID/d" $UNITY$FILE;;
                 *.xml) sed -i "/<!--$MODID-->/d" $UNITY$FILE;;
               esac
             done }
