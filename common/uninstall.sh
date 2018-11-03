[ -z $UAE -o -z $ACTIVITYE ] && UAE=false
if [ "$UAE" == "true" ]; then
  if $BOOTMODE && $MAGISK; then
    pm uninstall $ACTIVITYE
  else
    rm -rf /data/app/$ACTIVITYE*
  fi
  rm -rf /data/data/$ACTIVITYE
  rm -f $SDCARD/ViPER4AndroidFX.apk
fi

if ! $MAGISK || $SYSOVERRIDE; then
  for OFILE in ${CFGS}; do
    FILE="$UNITY$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
    case $FILE in
      *.conf) sed -i "/v4a_standard_fx { #$MODID/,/} #$MODID/d" $FILE
              sed -i "/v4a_fx { #$MODID/,/} #$MODID/d" $FILE;;
      *.xml) sed -i "/<!--$MODID-->/d" $FILE;;
    esac
  done
fi
