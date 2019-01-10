# Aroma Installer
keytest() {
  ui_print " "
  ui_print "- Vol Key Test -"
  ui_print "   Press a Vol Key:"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}
chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 0
  else
    return 1
  fi
}
chooseportold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  keycheck
  keycheck
  SEL=$?
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 0
  elif [ $SEL -eq $DOWN ]; then
    return 1
  else
    ui_print "   Vol key not detected!"
    abort "   Use name change method in TWRP"
  fi
}

# Get Aroma from zipname
OIFS=$IFS; IFS=\|
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *noaroma*) AROMA=false;;
  *aroma*) AROMA=true;;
esac
IFS=$OIFS
[ -d "/cache/$MODID" ] && AROMA=true
if [ -z $AROMA ]; then
  if keytest; then
    FUNCTION=chooseport
  else
    FUNCTION=chooseportold
    ui_print "   ! Legacy device detected! Using old keycheck method"
    [ "$ARCH32" == "arm" ] || { ui_print "   ! Non-arm device detected!"; ui_print "   ! Keycheck binary only compatible with arm/arm64 devices!"; abort "!   Use name change method in TWRP! Aborting!"; }
    ui_print " "
    ui_print "- Vol Key Programming -"
    ui_print "   Press Vol Up Again:"
    $FUNCTION "UP"
    ui_print "   Press Vol Down"
    $FUNCTION "DOWN"
  fi
  ui_print " "
  ui_print "- Select Install Method -"
  ui_print "   Use Aroma Installer?:"
  ui_print "   Vol Up = Aroma Installer"
  ui_print "   Vol Down = Vol Key Method"
  ui_print "   Select Vol Key Method if Aroma doesn't work on"
  ui_print "   your device or if your device doesn't have TWRP"
  if $FUNCTION; then
    AROMA=true
  else
    AROMA=false
  fi
else
  ui_print "   Install method specified in zipname!"
fi
if $AROMA; then
  if [ -d "/cache/$MODID" ]; then
    ui_print "   Continuing install with aroma options"
    # Save selections to Mod
    for i in /cache/$MODID/*.prop; do
      cp_ch -n $i $UNITY/system/etc/$MODID/$(basename $i)
    done
    rm -f /cache/$MODID.zip /cache/$MODID-Aroma.zip /cache/recovery/openrecoveryscript
    rm -rf /cache/$MODID  
  else
    # Delete space hogging boot_log folder
    rm -rf /cache/boot_log
    if [ -d "$TMPDIR/aroma" ]; then
      # Move previous selections to temp directory for reuse if chosen
      ui_print "   Backup up previous selections..."
      for FILE in $TMPDIR/aroma/*.prop; do
        cp_ch -i $FILE /cache/$MODID/$(basename $FILE)
      done
    fi
    ui_print "   Creating Aroma installer and open recovery script..."
    cp -f $ZIPFILE /cache/$MODID.zip
    cd $INSTALLER/addon/Aroma-Installer
    sed -i "2i MODID=$MODID" META-INF/com/google/android/update-binary-installer
    chmod -R 0755 tools
    cp -R tools $INSTALLER/common/unityfiles 2>/dev/null
    zip -qr0 /cache/$MODID-Aroma META-INF
    cd /
    echo -e "install /cache/$MODID-Aroma.zip\ninstall /cache/$MODID.zip\nreboot recovery" > /cache/recovery/openrecoveryscript
    ui_print "   Will reboot and launch aroma installer"
    cleanup
    sleep 3
    reboot recovery
  fi
else
  rm -rf $INSTALLER/addon/Aroma-Installer
fi
