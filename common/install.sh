rm -rf /data/app/com.pittvandewitt.viperfx /data/app/com.vipercn.viper4android* /data/app/com.audlabs.viperfx*

# Device specific sepolicy patches
if device_check "walleye" || device_check "taimen"; then
  test -f $SYS/lib/libstdc++.so && cp_ch $SYS/lib/libstdc++.so $UNITY$VEN/lib/libstdc++.so
elif device_check "sailfish" || device_check "marlin"; then
  sed -i 's/#pixel//g' $INSTALLER/common/post-fs-data.sh
fi

# Temp fix for op3/3t oreo devices
if [ $API -ge 26 ] && ( device_check "OnePlus3" || device_check "OnePlus3T" ); then
  ui_print "   ! Oneplus 3/3T Oreo device detected !"
  ui_print "   Setting selinux to permissive..."
  if $MAGISK; then echo "#!/system/bin/sh" > $INSTALLER/common/post-fs-data.sh; else echo "$SHEBANG" > $INSTALLER/common/post-fs-data.sh; fi
  echo "setenforce 0" >> $INSTALLER/common/post-fs-data.sh
  echo "" >> $INSTALLER/common/post-fs-data.sh
fi

OLD=false; NEW=false; MAT=false
# GET OLD/NEW FROM ZIP NAME
case $(basename $ZIP) in
  *old*|*Old*|*OLD*) OLD=true;;
  *new*|*New*|*NEW*) NEW=true;;
  *mat*|*Mat*|*MAT*) MAT=true;;
esac

chooseport() {
  if [ "$1" == "on" ]; then
    ui_print "   Choose which V4A you want installed:"
    ui_print "   Vol+ = new (2.5.0.5), Vol- = old (2.3.4.0)"
    ui_print "   Old V4A will install super quality driver"
  elif [ "$1" == "mn" ]; then
    ui_print "   Choose which new V4A you want installed:"
    ui_print "   Vol+ = material, Vol- = original"
  fi
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while (true); do
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

mkdir -p $INSTALLER/system/lib/soundfx
ui_print " "
ui_print "- Select Version -"
if ! $OLD && ! $NEW && ! $MAT; then
  chooseport on || OLD=true
else
  ui_print "   V4A version specified in zipname!"
fi
if $OLD; then
  ui_print "   Old V4A will be installed"
  cp -f $INSTALLER/custom/Old/ViPER4AndroidFX.apk $INSTALLER/system/app/ViPER4AndroidFX/ViPER4AndroidFX.apk
  cp -f $INSTALLER/custom/Old/libv4a_fx_jb_$ABI.so $INSTALLER/system/lib/soundfx/libv4a_fx_ics.so
  sed -ri "s/version=(.*)/version=\1 (2.3.4.0)/" $INSTALLER/module.prop
  $LATESTARTSERVICE && sed -i 's/<ACTIVITY>/com.vipercn.viper4android_v2/g' $INSTALLER/common/service.sh
  LIBPATCH="\/system"; LIBDIR=$SYS; DYNAMICOREO=false
else
  $NEW || $MAT || { chooseport mn && MAT=true; }
  cp -f $INSTALLER/custom/libv4a_fx_jb_$ABI.so $INSTALLER/system/lib/soundfx/libv4a_fx_ics.so
  if $MAT; then
    ui_print "   Material V4A will be installed"
    cp -f $INSTALLER/custom/ViPER4AndroidFXMaterial.apk $INSTALLER/system/app/ViPER4AndroidFX/ViPER4AndroidFX.apk
    sed -ri -e "s/version=(.*)/version=\1 (2.5.0.5)/" -e "s/name=(.*)/name=\1 Materialized/" $INSTALLER/module.prop
    $LATESTARTSERVICE && sed -i 's/<ACTIVITY>/com.pittvandewitt.viperfx/g' $INSTALLER/common/service.sh
  else
    ui_print "   Original V4A will be installed"
    sed -ri "s/version=(.*)/version=\1 (2.5.0.5)/" $INSTALLER/module.prop
    $LATESTARTSERVICE && sed -i 's/<ACTIVITY>/com.audlabs.viperfx/g' $INSTALLER/common/service.sh
  fi
fi

ui_print "   Patching existing audio_effects files..."
# Create vendor audio_effects.conf if missing
if $MAGISK && [ -f $ORIGDIR/system/etc/audio_effects.conf ] && [ ! -f $ORIGDIR/system/vendor/etc/audio_effects.conf ]; then
  cp_ch $ORIGDIR/system/etc/audio_effects.conf $UNITY/system/vendor/etc/audio_effects.conf
fi
for FILE in ${CFGS}; do
  $MAGISK && cp_ch $ORIGDIR$FILE $UNITY$FILE
  case $FILE in
    *.conf) [ ! "$(grep '^ *# *music_helper {' $UNITY$FILE)" -a "$(grep '^ *music_helper {' $UNITY$FILE)" ] && sed -i "/effects {/,/^}/ {/music_helper {/,/}/ s/^/#/g}" $UNITY$FILE
            sed -i "/v4a_standard_fx {/,/}/d" $UNITY$FILE
            sed -i "/v4a_fx {/,/}/d" $UNITY$FILE
            sed -i "s/^effects {/effects {\n  v4a_standard_fx { #$MODID\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  } #$MODID/g" $UNITY$FILE
            sed -i "s/^libraries {/libraries {\n  v4a_fx { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libv4a_fx_ics.so\n  } #$MODID/g" $UNITY$FILE;;
    *.xml) [ ! "$(grep '^ *<\!--<stream type=\"music\">' $UNITY$FILE)" -a "$(grep '^ *<stream type=\"music\">' $UNITY$FILE)" ] && sed -i "/^ *<postprocess>$/,/<\/postprocess>/ {/<stream type=\"music\">/,/<\/stream>/ s/<stream type=\"music\">/<\!--<stream type=\"music\">/; s/<\/stream>/<\/stream>-->/}" $UNITY$FILE
           sed -i "/v4a_standard_fx/d" $UNITY$FILE
           sed -i "/v4a_fx/d" $UNITY$FILE
           sed -i "/<libraries>/ a\        <library name=\"v4a_fx\" path=\"libv4a_fx_ics.so\"\/><!--$MODID-->" $UNITY$FILE
           sed -i "/<effects>/ a\        <effect name=\"v4a_standard_fx\" library=\"v4a_fx\" uuid=\"41d3c987-e6cf-11e3-a88a-11aba5d5c51b\"\/><!--$MODID-->" $UNITY$FILE;;
  esac
done
