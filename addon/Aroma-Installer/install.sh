# Aroma Installer

# Get Aroma from zipname
OIFS=$IFS; IFS=\|
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *noaroma*) AROMA=false;;
  *aroma*) AROMA=true;;
esac
IFS=$OIFS
[ -d "/cache/$MODID" ] && AROMA=true
if [ -z $AROMA ]; then
  ui_print "- Select Install Method -"
  ui_print "   Use Aroma Installer?:"
  ui_print " "
  ui_print "   Select Vol Key Method if Aroma doesn't work on"
  ui_print "   your device or if your device doesn't have TWRP"
  ui_print "   If you choose aroma, installer will reboot to TWRP"
  sleep 3
  ui_print " "
  ui_print "   Vol Up = Aroma Installer (Only if you know aroma works)"
  ui_print "   Vol Down = Vol Key Method (Recommended)"
  if $VKSEL; then
    AROMA=true
  else
    AROMA=false
  fi
else
  [ -d "/cache/$MODID" ] || ui_print "   Install method specified in zipname!"
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
