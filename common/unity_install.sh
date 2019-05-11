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

ui_print "   Decompressing files..."
tar -xf $TMPDIR/custom.tar.xz -C $TMPDIR 2>/dev/null

# Tell user aml is needed if applicable
if $MAGISK && ! $SYSOVER; then
  if $BOOTMODE; then LOC="$MOUNTEDROOT/*/system $MODULEROOT/*/system"; else LOC="$MODULEROOT/*/system"; fi
  FILES=$(find $LOC -type f -name "*audio_effects*.conf" -o -name "*audio_effects*.xml" 2>/dev/null)
  if [ ! -z "$FILES" ] && [ ! "$(echo $FILES | grep '/aml/')" ]; then
    ui_print " "
    ui_print "   ! Conflicting audio mod found!"
    ui_print "   ! You will need to install !"
    ui_print "   ! Audio Modification Library !"
    sleep 3
  fi
fi

# Get old/new from zip name
OIFS=$IFS; IFS=\|; MID=false; NEW=false
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *old*) MAT=false;;
  *mid*) MAT=false; MID=true;;
  *new*) MAT=false; NEW=true;;
  *mat*) MAT=true;;
esac
# Get userapp from zip name
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *uapp*) UA=true;;
  *sapp*) UA=false;;
esac
# Get lib workaround from zip name
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *lib*) LIBWA=true;;
  *nlib*) LIBWA=false;;
esac
# Get open/close workaround from zip name
case $(echo $(basename $ZIPFILE) | tr '[:upper:]' '[:lower:]') in
  *ocw*) OCW=true;;
  *nocw*) OCW=false;;
esac
IFS=$OIFS

# Check for devices that need lib workaround
if [ $API -ge 28 ] || device_check "walleye" || device_check "taimen" || device_check "crosshatch" || device_check "blueline" || device_check "mata" || device_check "jasmine" || device_check "star2lte" || device_check "z2_row" || device_check "beyond2lte"; then
  LIBWA=true
fi

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
if [ -z $MAT ] || [ -z $UA ] || [ -z $LIBWA ] || [ -z $OCW ]; then
  if [ -z $VKSEL ]; then
    ui_print "  ! Some options not specified in zipname!"
    ui_print "  Using defaults if not specified in zipname!"
    [ -z $MAT ] && MAT=false; NEW=true
    [ -z $UA ] && UA=false
    [ -z $LIBWA ] && LIBWA=false
    [ -z $OCW ] && OCW=true
  else
    if [ -z $MAT ]; then
      ui_print " - Select Version -"
      ui_print "   Choose which V4A you want installed:"
      ui_print "   Vol+ = new (2.5.0.5), Vol- = older"
      MAT=false
      if $VKSEL; then
        ui_print " "
        ui_print "   Choose which new V4A you want installed"
        ui_print "   Vol+ = material, Vol- = original"
        if $VKSEL; then
          MAT=true
        else
          NEW=true
        fi
      else
        ui_print " "
        ui_print "   Choose which older V4A you want installed:"
        ui_print "   2.3.4.0 V4A will install super quality driver"
        ui_print "   Vol+ = 2.4.0.1, Vol- = 2.3.4.0"
        $VKSEL && MID=true
      fi
    else
      ui_print "   V4A version specified in zipname!"
    fi
    if [ -z $UA ]; then
      ui_print " "
      ui_print " - Select App Location -"
      ui_print "   Choose how V4A you want installed"
      ui_print " "
      ui_print "   Note that: user app can get killed by android,"
      ui_print "   system app doesn't work with some convolvers:"
      sleep 2
      ui_print "   Vol+ = system app, Vol- = user app"
      if $VKSEL; then
        UA=false
      else
        UA=true
      fi
    else
      ui_print "   V4A install method specified in zipname!"
    fi
    if [ -z $LIBWA ]; then
      ui_print " "
      ui_print " - Use lib workaround? -"
      ui_print " "
      ui_print "   Only choose yes if you're having issues"
      ui_print "   Vol+ = yes, Vol- = no (recommended)"
      if $VKSEL; then
        LIBWA=true
      else
        LIBWA=false
      fi
    fi
    if [ -z $OCW ]; then
      ui_print " "
      ui_print " - Use killall audioserver workaround? -"
      ui_print "   Needed for some devices"
      ui_print "   Vol+ = yes (recommended), Vol- = no"
      if $VKSEL; then
        OCW=true
      else
        OCW=false
      fi
    else
      ui_print "   app open/close/fc workaround specified in zipname!"
    fi
  fi
else
  ui_print "   Options specified in zipname!"
fi

ui_print " "
VER="2.5.0.5"
mkdir -p $TMPDIR/system/lib/soundfx $TMPDIR/system/etc/permissions $TMPDIR/system/priv-app/ViPER4AndroidFX/lib/$ABI
if $MAT; then
  ui_print "   Material V4A will be installed"
  cp -f $TMPDIR/custom/mat/privapp-permissions-com.pittvandewitt.viperfx.xml $TMPDIR/system/etc/permissions/privapp-permissions-com.pittvandewitt.viperfx.xml
  sed -ri "s/name=(.*)/name=\1 Materialized/" $TMPDIR/module.prop
  sed -i "s/author=.*/author=ViPER520, ZhuHang, Team_Dewitt, Ahrion, Zackptg5/" $TMPDIR/module.prop
  ACTIVITY="com.pittvandewitt.viperfx"
  FACTIVITY="com.pittvandewitt.viperfx/com.audlabs.viperfx.main.MainActivity"
elif $NEW; then
  ui_print "   V4A $VER will be installed"
  cp -f $TMPDIR/custom/$VER/privapp-permissions-com.audlabs.viperfx.xml $TMPDIR/system/etc/permissions/privapp-permissions-com.audlabs.viperfx.xml
  ACTIVITY="com.audlabs.viperfx"
  FACTIVITY="com.audlabs.viperfx/.main.StartActivity"
elif $MID; then
  VER="2.4.0.1"
  ui_print "   V4A $VER will be installed"
  cp -f $TMPDIR/custom/$VER/privapp-permissions-com.vipercn.viper4android_v2.xml $TMPDIR/system/etc/permissions/privapp-permissions-com.vipercn.viper4android_v2.xml
  ACTIVITY="com.vipercn.viper4android_v2"
  FACTIVITY="com.vipercn.viper4android_v2/.activity.ViPER4Android"
  LIBPATCH="\/system"; LIBDIR=/system; DYNAMICLIB=false
else
  VER="2.3.4.0"
  ui_print "   V4A $VER will be installed"
  cp -f $TMPDIR/custom/$VER/privapp-permissions-com.vipercn.viper4android_v2.xml $TMPDIR/system/etc/permissions/privapp-permissions-com.vipercn.viper4android_v2.xml
  ACTIVITY="com.vipercn.viper4android_v2"
  FACTIVITY="com.vipercn.viper4android_v2/.activity.ViPER4Android"
  LIBPATCH="\/system"; LIBDIR=/system; DYNAMICLIB=false
fi

# Sanity-check to avoid rm -rf /data/data disaster in v4afx.sh.
[ -n "ACTIVITY" ] || abort " "

sed -i "s/<SOURCE>/$SOURCE/g" $TMPDIR/common/sepolicy.sh
$OCW && sed -i -e "s/<ACTIVITY>/$ACTIVITY/g" -e "s|<FACTIVITY>|$FACTIVITY|g" $TMPDIR/common/service.sh || rm -f $TMPDIR/common/service.sh
sed -i "s/<ACTIVITY>/$ACTIVITY/g" $TMPDIR/common/v4afx.sh
sed -ri "s/version=(.*)/version=\1 ($VER)/" $TMPDIR/module.prop
echo -e "UA=$UA\nACTIVITY=$ACTIVITY" >> $TMPDIR/module.prop
cp -f $TMPDIR/custom/$VER/libv4a_fx_jb_$ABI.so $TMPDIR/system/lib/soundfx/libv4a_fx_ics.so
cp -f $TMPDIR/custom/$VER/libV4AJniUtils_$ABI.so $TMPDIR/system/priv-app/ViPER4AndroidFX/lib/$ABI/libV4AJniUtils.so
$MAT && VER="mat"
if $UA; then
  if $MAGISK; then
    ui_print "   V4A will be installed as user app"
    install_script -l $TMPDIR/common/v4afx.sh
    cp_ch $TMPDIR/custom/$VER/ViPER4AndroidFX.apk $UNITY/ViPER4AndroidFX.apk
  else
    cp -f $TMPDIR/custom/$VER/ViPER4AndroidFX.apk $SDCARD/ViPER4AndroidFX.apk
    ui_print " "
    ui_print "   ViPER4AndroidFX.apk copied to root of internal storage (sdcard)"
    ui_print "   Install manually after booting"
    sleep 2
  fi
  rm -rf $TMPDIR/system/priv-app
else
  ui_print "   V4A will be installed as system app"
  cp -f $TMPDIR/custom/$VER/ViPER4AndroidFX.apk $TMPDIR/system/priv-app/ViPER4AndroidFX/ViPER4AndroidFX.apk
fi

# Lib fix for pixel 2's, 3's, and essential phone
if $LIBWA; then
  ui_print "   Applying lib workaround..."
  if [ -f $ORIGDIR/system/lib/libstdc++.so ] && [ ! -f $ORIGVEN/lib/libstdc++.so ]; then
    cp_ch $ORIGDIR/system/lib/libstdc++.so $UNITY$VEN/lib/libstdc++.so
  elif [ -f $ORIGVEN/lib/libstdc++.so ] && [ ! -f $ORIGDIR/system/lib/libstdc++.so ]; then
    cp_ch $ORIGVEN/lib/libstdc++.so $UNITY/system/lib/libstdc++.so
  fi
fi

ui_print " "
ui_print "   Patching existing audio_effects files..."
for OFILE in ${CFGS}; do
  FILE="$UNITY$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
  cp_ch -i $ORIGDIR$OFILE $FILE
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
