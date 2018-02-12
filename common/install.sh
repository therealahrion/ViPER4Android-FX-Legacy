rm -rf /data/app/com.pittvandewitt.viperfx /data/app/com.vipercn.viper4android* /data/app/com.audlabs.viperfx*

# Device specific sepolicy patches
if device_check "walleye" || device_check "taimen"; then
  test -f $SYS/lib/libstdc++.so && cp_ch $SYS/lib/libstdc++.so $UNITY$VEN/lib/libstdc++.so
elif device_check "sailfish" || device_check "marlin" || device_check "OnePlus3" || device_check "OnePlus3T"; then
  sed -i 's/#pixel//g' $INSTALLER/common/post-fs-data.sh
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
    getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
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
if [ -f $ORIGDIR/system/etc/audio_effects.conf ] && [ ! -f $ORIGDIR/system/vendor/etc/audio_effects.conf ] && [ ! -f $ORIGDIR/system/vendor/etc/audio_effects.xml ]; then
  cp_ch_nb $ORIGDIR/system/etc/audio_effects.conf $UNITY/system/vendor/etc/audio_effects.conf
  CFGS="${CFGS} /system/vendor/etc/audio_effects.conf"
fi
for FILE in ${CFGS}; do
  $MAGISK && cp_ch $ORIGDIR$FILE $UNITY$FILE
  case $FILE in
    *.conf) [ ! "$(grep '^ *# *music_helper {' $UNITY$FILE)" -a "$(grep '^ *music_helper {' $UNITY$FILE)" ] && sed -i "/effects {/,/^}/ {/music_helper {/,/}/ s/^/#/g}" $UNITY$FILE
            [ ! "$(grep '^ *# *sa3d {' $UNITY$FILE)" -a "$(grep '^ *sa3d {' $UNITY$FILE)" ] && sed -i "/effects {/,/^}/ {/sa3d {/,/^  }/ s/^/#/g}" $UNITY$FILE
            sed -i "/v4a_standard_fx {/,/}/d" $UNITY$FILE
            sed -i "/v4a_fx {/,/}/d" $UNITY$FILE
            sed -i "s/^effects {/effects {\n  v4a_standard_fx { #$MODID\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  } #$MODID/g" $UNITY$FILE
            sed -i "s/^libraries {/libraries {\n  v4a_fx { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libv4a_fx_ics.so\n  } #$MODID/g" $UNITY$FILE;;
    *.xml) [ ! "$(grep '^ *<\!--<effect name=\"music_helper\"*' $UNITY$FILE)" -a "$(grep '^ *<effect name=\"music_helper\"*' $UNITY$FILE)" ] && sed -i "s/^\( *\)<effect name=\"music_helper\"\(.*\)/\1<\!--<effect name=\"music_helper\"\2-->/" $UNITY$FILE
           [ ! "$(grep '^ *<\!--<effect name=\"sa3d\"*' $UNITY$FILE)" -a "$(grep '^ *<effect name=\"sa3d\"*' $UNITY$FILE)" ] && sed -i "s/^\( *\)<effect name=\"sa3d\"\(.*\)/\1<\!--<effect name=\"sa3d\"\2-->/" $UNITY$FILE
           sed -i "/v4a_standard_fx/d" $UNITY$FILE
           sed -i "/v4a_fx/d" $UNITY$FILE
           sed -i "/<libraries>/ a\        <library name=\"v4a_fx\" path=\"libv4a_fx_ics.so\"\/><!--$MODID-->" $UNITY$FILE
           sed -i "/<effects>/ a\        <effect name=\"v4a_standard_fx\" library=\"v4a_fx\" uuid=\"41d3c987-e6cf-11e3-a88a-11aba5d5c51b\"\/><!--$MODID-->" $UNITY$FILE;;
  esac
done
