osp_detect() {
  case $1 in
    *.conf) SPACES=$(sed -n "/^output_session_processing {/,/^}/ {/^ *music {/p}" $1 | sed -r "s/( *).*/\1/")
            EFFECTS=$(sed -n "/^output_session_processing {/,/^}/ {/^$SPACES\music {/,/^$SPACES}/p}" $1 | grep -E "^$SPACES +[A-Za-z]+" | sed -r "s/( *.*) .*/\1/g")
            for EFFECT in ${EFFECTS}; do
              SPACES=$(sed -n "/^effects {/,/^}/ {/^ *$EFFECT {/p}" $1 | sed -r "s/( *).*/\1/")
              [ "$EFFECT" != "atmos" ] && sed -i "/^effects {/,/^}/ {/^$SPACES$EFFECT {/,/^$SPACES}/ s/^/#/g}" $1
            done;;
     *.xml) EFFECTS=$(sed -n "/^ *<postprocess>$/,/^ *<\/postprocess>$/ {/^ *<stream type=\"music\">$/,/^ *<\/stream>$/ {/<stream type=\"music\">/d; /<\/stream>/d; s/<apply effect=\"//g; s/\"\/>//g; p}}" $1)
            for EFFECT in ${EFFECTS}; do
              [ "$EFFECT" != "atmos" ] && sed -ri "s/^( *)<apply effect=\"$EFFECT\"\/>/\1<\!--<apply effect=\"$EFFECT\"\/>-->/" $1
            done;;
  esac
}

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

ui_print "   Decompressing files..."
tar -xf $INSTALLER/custom.tar.xz -C $INSTALLER 2>/dev/null

# Tell user aml is needed if applicable
if $MAGISK && ! $SYSOVERRIDE; then
  if $BOOTMODE; then LOC="/sbin/.core/img/*/system $MOUNTPATH/*/system"; else LOC="$MOUNTPATH/*/system"; fi
  FILES=$(find $LOC -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" 2>/dev/null)
  if [ ! -z "$FILES" ] && [ ! "$(echo $FILES | grep '/aml/')" ]; then
    ui_print " "
    ui_print "   ! Conflicting audio mod found!"
    ui_print "   ! You will need to install !"
    ui_print "   ! Audio Modification Library !"
    sleep 3
  fi
fi

# GET OLD/NEW FROM ZIP NAME
MID=false; NEW=false
case $(basename $ZIP) in
  *old*|*Old*|*OLD*) MAT=false;;
  *mid*|*Mid*|*MID*) MAT=false; MID=true;;
  *new*|*New*|*NEW*) MAT=false; NEW=true;;
  *mat*|*mat*|*MAT*) MAT=true;;
esac

# Check API compatibility
PATCH=true
if [ $API -le 15 ]; then
  DRV=ics_$ABI
else
  DRV=jb_$ABI
fi
if [ $API -le 10 ]; then
  ui_print " "
  ui_print "   Gingerbread rom detected!"
  ui_print "   Only v2.3.4.0 is compatible!"
  MID=false; NEW=false; MAT=false; PATCH=false
  # Detect driver compatibility
  ui_print " "
  ABIVER=$(echo $ABILONG | sed -r 's/.*-v([0-9]*).*/\1/')
  [ -z $ABIVER ] && ABIVER=0
  CPUFEAT=$(cat /proc/cpuinfo | grep 'Features')
  if [ $ABIVER -ge 7 ] || [ "$(echo $CPUFEAT | grep 'neon')" ]; then
    ui_print "   Neon Device detected!"
    DRV=arm
  elif [ "$ABI" == "x86" ]; then
    ui_print "   x86 Device detected!"
    DRV=x86
  elif [ "$(echo $CPUFEAT | grep 'vfp')" ]; then
    ui_print "   Non-neon VFP Device detected!"
    DRV=VFP
  else
    ui_print "   Non-Neon, Non-VFP Device detected!"
    DRV=NOVFP
  fi
elif [ $API -le 13 ]; then
  ui_print " "
  ui_print "   Honeycomb rom detected!"
  ui_print "   Only v2.3.4.0 is compatible!"
  MID=false; NEW=false; MAT=false
fi

# Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
KEYCHECK=$INSTALLER/common/keycheck
chmod 755 $KEYCHECK

ui_print " "
ui_print "   Removing remnants from past v4a installs..."
# Uninstall existing v4a installs
V4AAPPS=$(find /data/app -type d -name "*com.pittvandewitt.viperfx*" -o -name "*com.audlabs.viperfx*" -o -name "*com.vipercn.viper4android_v2*")
if [ "$V4AAPPS" ]; then
  if $BOOTMODE; then
    for APP in ${V4AAPPS}; do
      case $APP in
        *com.pittvandewitt.viperfx*) pm uninstall com.pittvandewitt.viperfx >/dev/null 2>&1;;
        *com.audlabs.viperfx*) pm uninstall com.audlabs.viperfx >/dev/null 2>&1;;
        *com.vipercn.viper4android*) pm uninstall com.vipercn.viper4android_v2 >/dev/null 2>&1;;
      esac
    done
  else
    for APP in ${V4AAPPS}; do
      rm -rf $APP
    done
  fi
fi
# Remove remnants of any old v4a installs
for REMNANT in $(find /data -name "*ViPER4AndroidFX*" -o -name "*com.pittvandewitt.viperfx*" -o -name "*com.audlabs.viperfx*" -o -name "*com.vipercn.viper4android_v2*"); do
  [ "$(echo $REMNANT | cut -d '/' -f-4)" == "/data/media/0" ] && continue
  if [ -d "$REMNANT" ]; then
    rm -rf $REMNANT
  else
    rm -f $REMNANT
  fi
done

ui_print " "
if [ -z $MAT ]; then
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
  ui_print "   Vol+ = new (2.5.0.5), Vol- = older"
  MAT=false
  if $FUNCTION; then
    ui_print " "
    ui_print "   Choose which new V4A you want installed"
    ui_print "   Vol+ = material, Vol- = original"
    if $FUNCTION; then
      MAT=true
    else
      NEW=true
    fi
  else
    ui_print " "
    ui_print "   Choose which older V4A you want installed:"
    ui_print "   2.3.4.0 V4A will install super quality driver"
    ui_print "   Vol+ = 2.4.0.1, Vol- = 2.3.4.0"
    $FUNCTION && MID=true
  fi
else
  ui_print "   V4A version specified in zipname!"
fi

VER="2.5.0.5"
mkdir -p $INSTALLER/system/lib/soundfx $INSTALLER/system/etc/permissions $INSTALLER/system/app/ViPER4AndroidFX/lib/$ABI
if $MAT; then
  ui_print "   Material V4A will be installed"
  cp -f $INSTALLER/custom/mat/privapp-permissions-com.pittvandewitt.viperfx.xml $INSTALLER/system/etc/permissions/privapp-permissions-com.pittvandewitt.viperfx.xml
  sed -ri "s/name=(.*)/name=\1 Materialized/" $INSTALLER/module.prop
  sed -i "s/author=.*/author=ViPER520, ZhuHang, Team_Dewitt, Ahrion, Zackptg5/" $INSTALLER/module.prop
  $LATESTARTSERVICE && sed -i 's/<ACTIVITY>/com.pittvandewitt.viperfx/g' $INSTALLER/common/service.sh
elif $NEW; then
  ui_print "   V4A $VER will be installed"
  cp -f $INSTALLER/custom/$VER/privapp-permissions-com.audlabs.viperfx.xml $INSTALLER/system/etc/permissions/privapp-permissions-com.audlabs.viperfx.xml
  $LATESTARTSERVICE && sed -i 's/<ACTIVITY>/com.audlabs.viperfx/g' $INSTALLER/common/service.sh
elif $MID; then
  VER="2.4.0.1"
  ui_print "   V4A $VER will be installed"
  cp -f $INSTALLER/custom/$VER/privapp-permissions-com.vipercn.viper4android_v2.xml $INSTALLER/system/etc/permissions/privapp-permissions-com.vipercn.viper4android_v2.xml
  $LATESTARTSERVICE && sed -i 's/<ACTIVITY>/com.vipercn.viper4android_v2/g' $INSTALLER/common/service.sh
  LIBPATCH="\/system"; LIBDIR=/system; DYNAMICOREO=false
else
  VER="2.3.4.0"
  ui_print "   V4A $VER will be installed"
  cp -f $INSTALLER/custom/$VER/privapp-permissions-com.vipercn.viper4android_v2.xml $INSTALLER/system/etc/permissions/privapp-permissions-com.vipercn.viper4android_v2.xml
  $LATESTARTSERVICE && sed -i 's/<ACTIVITY>/com.vipercn.viper4android_v2/g' $INSTALLER/common/service.sh
  LIBPATCH="\/system"; LIBDIR=/system; DYNAMICOREO=false
fi

sed -ri "s/version=(.*)/version=\1 ($VER)/" $INSTALLER/module.prop
cp -f $INSTALLER/custom/$VER/libv4a_fx_$DRV.so $INSTALLER/system/lib/soundfx/libv4a_fx_ics.so
cp -f $INSTALLER/custom/$VER/libV4AJniUtils_$ABI.so $INSTALLER/system/app/ViPER4AndroidFX/lib/$ABI/libV4AJniUtils.so
$MAT && VER="mat"
cp -f $INSTALLER/custom/$VER/ViPER4AndroidFX.apk $INSTALLER/system/app/ViPER4AndroidFX/ViPER4AndroidFX.apk

# Lib fix for pixel 2's and essential phone
if device_check "walleye" || device_check "taimen" || device_check "mata"; then
  if [ -f /system/lib/libstdc++.so ] && [ ! -f $VEN/lib/libstdc++.so ]; then
    cp_ch /system/lib/libstdc++.so $UNITY$VEN/lib/libstdc++.so
  elif [ -f $VEN/lib/libstdc++.so ] && [ ! -f /system/lib/libstdc++.so ]; then
    cp_ch $VEN/lib/libstdc++.so $UNITY/system/lib/libstdc++.so
  fi
fi

if $PATCH; then
  ui_print " "
  ui_print "   Patching existing audio_effects files..."
  for OFILE in ${CFGS}; do
    FILE="$UNITY$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
    cp_ch -nn $ORIGDIR$OFILE $FILE
    osp_detect $FILE
    case $FILE in
      *.conf) sed -i "/v4a_standard_fx {/,/}/d" $FILE
              sed -i "/v4a_fx {/,/}/d" $FILE
              sed -i "s/^effects {/effects {\n  v4a_standard_fx { #$MODID\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  } #$MODID/g" $FILE
              sed -i "s/^libraries {/libraries {\n  v4a_fx { #$MODID\n    path $LIBPATCH\/lib\/soundfx\/libv4a_fx_ics.so\n  } #$MODID/g" $FILE;;
      *.xml) sed -i "/v4a_standard_fx/d" $FILE
             sed -i "/v4a_fx/d" $FILE
             sed -i "/<libraries>/ a\        <library name=\"v4a_fx\" path=\"libv4a_fx_ics.so\"\/><!--$MODID-->" $FILE
             sed -i "/<effects>/ a\        <effect name=\"v4a_standard_fx\" library=\"v4a_fx\" uuid=\"41d3c987-e6cf-11e3-a88a-11aba5d5c51b\"\/><!--$MODID-->" $FILE;;
    esac
  done
fi
