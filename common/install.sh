osp_detect() {
  case $1 in
    *.conf) SPACES=$(sed -n "/^output_session_processing {/,/^}/ {/^ *music {/p}" $1 | sed -r "s/( *).*/\1/")
            EFFECTS=$(sed -n "/^output_session_processing {/,/^}/ {/^$SPACES\music {/,/^$SPACES}/p}" $1 | grep -E "^$SPACES +[A-Za-z]+" | sed -r "s/( *.*) .*/\1/g")
            for EFFECT in ${EFFECTS}; do
              SPACES=$(sed -n "/^effects {/,/^}/ {/^ *$EFFECT {/p}" $1 | sed -r "s/( *).*/\1/")
              [ "$EFFECT" != "atmos" ] && sed -i "/^effects {/,/^}/ {/^$SPACES$EFFECT {/,/^$SPACES}/ s/^/#/g}" $1
            done;;
     *.xml) EFFECTS=$(sed -n "/^ *<postprocess>$/,/^ *<\/postprocess>$/ {/^ *<stream type=\"music\">$/,/^ *<\/stream>$/ {/<stream type=\"music\">\|<\/stream>/d; s/<apply effect=\"//g; s/\"\/>//g; p}}" $1)
            for EFFECT in ${EFFECTS}; do
              [ "$EFFECT" != "atmos" ] && sed -ri "s/^( *)<apply effect=\"$EFFECT\"\/>/\1<\!--<apply effect=\"$EFFECT\"\/>-->/" $1
            done;;
  esac
}

rm -rf /data/app/com.pittvandewitt.viperfx* /data/app/com.vipercn.viper4android* /data/app/com.audlabs.viperfx*

# Remove dalvik-cache for any old v4a installs
for FILE in $(find /data/dalvik-cache -type f -name "*4AndroidFX*" -o -name "*viperfx*"); do
  rm -f $FILE
done

if device_check "walleye" || device_check "taimen" || device_check "mata"; then
  test -f $SYS/lib/libstdc++.so && cp_ch $SYS/lib/libstdc++.so $UNITY$VEN/lib/libstdc++.so
fi

# GET OLD/NEW FROM ZIP NAME
OLD=false; NEW=false; MAT=false
case $(basename $ZIP) in
  *old*|*Old*|*OLD*) OLD=true;;
  *new*|*New*|*NEW*) NEW=true;;
  *mat*|*Mat*|*MAT*) MAT=true;;
  *ndrv*|*Ndrv*|*NDRV*) NDRV=true;;
  *odrv*|*Odrv*|*ODRV*) NDRV=false;;
esac

# Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
KEYCHECK=$INSTALLER/common/keycheck
chmod 755 $KEYCHECK

keytest() {
  ui_print " - Vol Key Test -"
  ui_print "   Press Vol Up:"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

chooseport() {
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

chooseportold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $KEYCHECK
  $KEYCHECK
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

mkdir -p $INSTALLER/system/lib/soundfx
ui_print " "
if ! $OLD && ! $NEW && ! $MAT; then
  if keytest; then
    FUNCTION=chooseport
  else
    FUNCTION=chooseportold
    ui_print "   ! Legacy device detected! Using old keycheck method"
    ui_print " "
    ui_print "- Vol Key Programming -"
    ui_print "   Press Vol Up Again:"
    $FUNCTION "UP"
    ui_print "   Press Vol Down"
    $FUNCTION "DOWN"
  fi
  ui_print " "
  ui_print " - Select Version -"
  ui_print "   Choose which V4A you want installed:"
  ui_print "   Vol+ = material (2.6.0.1), Vol- = original)"
  if $FUNCTION; then
    MAT=true
  else
    ui_print " "
    ui_print "   Choose which original V4A you want installed:"
    ui_print "   Old V4A will install super quality driver"
    ui_print "   Vol+ = new (2.5.0.5), Vol- = old (2.3.4.0)"
    if $FUNCTION; then
      NEW=true
    else
      OLD=true
    fi
fi
else
  ui_print "   V4A version specified in zipname!"
fi

V4ALIB=libv4a_fx_ics.so
mkdir -p $INSTALLER/system/lib/soundfx
if $OLD; then
  ui_print "   Old V4A will be installed"
  rm -f $INSTALLER/system/etc/permissions/privapp-permisisons-com.audlabs.viperfx.xml
  cp -f $INSTALLER/custom/privapp-permisisons-com.vipercn.viper4android_v2.xml $INSTALLER/system/etc/permissions/privapp-permisisons-com.vipercn.viper4android_v2.xml
  cp -f $INSTALLER/custom/Old/ViPER4AndroidFX.apk $INSTALLER/system/app/ViPER4AndroidFX/ViPER4AndroidFX.apk
  cp -f $INSTALLER/custom/Old/libv4a_fx_jb_$ABI.so $INSTALLER/system/lib/soundfx/$V4ALIB
  sed -ri "s/version=(.*)/version=\1 (2.3.4.0)/" $INSTALLER/module.prop
  $LATESTARTSERVICE && sed -i 's/<ACTIVITY>/com.vipercn.viper4android_v2/g' $INSTALLER/common/service.sh
  LIBPATCH="\/system"; LIBDIR=$SYS; DYNAMICOREO=false
elif $NEW; then
  ui_print "   Original V4A will be installed"
  cp -f $INSTALLER/custom/libv4a_fx_jb_$ABI.so $INSTALLER/system/lib/soundfx/$V4ALIB
  sed -ri "s/version=(.*)/version=\1 (2.5.0.5)/" $INSTALLER/module.prop
  $LATESTARTSERVICE && sed -i 's/<ACTIVITY>/com.audlabs.viperfx/g' $INSTALLER/common/service.sh
else
  ui_print "   Material V4A will be installed"
  ui_print " "
  ui_print "   Choose which driver you want installed:"
  ui_print "   Vol+ = 2.5.0.4, Vol- = 2.3.4.0"
  V4ALIB=libv4a_fx.so
  if [ -z $NDRV ]; then
    if $FUNCTION; then
      NDRV=true
    else
      NDRV=false
    fi
  else
    ui_print "   Driver version specified in zipname!"
  fi
  if $NDRV; then
    ui_print "   2.5.0.5 driver will be installed"
    cp -f $INSTALLER/custom/libv4a_fx_jb_$ABI.so $INSTALLER/system/lib/soundfx/$V4ALIB
  else
    ui_print "   2.3.4.0 driver will be installed"
    cp -f $INSTALLER/custom/old/libv4a_fx_jb_$ABI.so $INSTALLER/system/lib/soundfx/$V4ALIB
  fi
  case $ABILONG in
    arm64*) JNI=arm64;;
    arm*) JNI=arm;;
    x86_64*) JNI=x86_64; NEW=false; ui_print "   x86 device detected! Using 2.5.0.5 driver!";;
    x86*) JNI=x86; NEW=false; ui_print "   x86 device detected! Using 2.5.0.5 driver!";;
    *64*) JNI=arm64; ui_print "   !Unsupported CPU architecture! App probably won't work!";;
    *) JNI=arm; ui_print "   !Unsupported CPU architecture! App probably won't work!";;
  esac
  rm -f $INSTALLER/system/etc/permissions/privapp-permisisons-com.audlabs.viperfx.xml
  mkdir -p $INSTALLER/system/app/ViPER4AndroidFX/lib/$JNI
  cp -f $INSTALLER/custom/mat/$JNI/libV4AJniUtils.so $INSTALLER/system/app/ViPER4AndroidFX/lib/$JNI/libV4AJniUtils.so
  cp -f $INSTALLER/custom/mat/privapp-permisisons-com.pittvandewitt.viperfx.xml $INSTALLER/system/etc/permissions/privapp-permisisons-com.pittvandewitt.viperfx.xml
  cp -f $INSTALLER/custom/mat/ViPER4AndroidFX.apk $INSTALLER/system/app/ViPER4AndroidFX/ViPER4AndroidFX.apk
  sed -ri -e "s/version=(.*)/version=\1 (2.6.0.1)/" -e "s/name=(.*)/name=\1 Materialized/" $INSTALLER/module.prop
  sed -i "s/author=.*/author=ViPER520, ZhuHang, Team_Dewitt, Ahrion, Zackptg5/" $INSTALLER/module.prop
  $LATESTARTSERVICE && sed -i 's/<ACTIVITY>/com.pittvandewitt.viperfx/g' $INSTALLER/common/service.sh
fi

ui_print " "
ui_print "   Patching existing audio_effects files..."
for FILE in ${CFGS}; do
  cp_ch $ORIGDIR$FILE $UNITY$FILE
  osp_detect $UNITY$FILE
  case $FILE in
    *.conf) sed -i "/v4a_standard_fx {/,/}/d" $UNITY$FILE
            sed -i "/v4a_fx {/,/}/d" $UNITY$FILE
            sed -i "s/^effects {/effects {\n  v4a_standard_fx { #$MODID\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  } #$MODID/g" $UNITY$FILE
            sed -i "s/^libraries {/libraries {\n  v4a_fx { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/$V4ALIB\n  } #$MODID/g" $UNITY$FILE;;
    *.xml) sed -i "/v4a_standard_fx/d" $UNITY$FILE
           sed -i "/v4a_fx/d" $UNITY$FILE
           sed -i "/<libraries>/ a\        <library name=\"v4a_fx\" path=\"$V4ALIB\"\/><!--$MODID-->" $UNITY$FILE
           sed -i "/<effects>/ a\        <effect name=\"v4a_standard_fx\" library=\"v4a_fx\" uuid=\"41d3c987-e6cf-11e3-a88a-11aba5d5c51b\"\/><!--$MODID-->" $UNITY$FILE;;
  esac
done
