TIMEOFEXEC=1

# Device specific sepolicy patches
if device_check "walleye" || device_check "taimen"; then
  sed -i 's/#pixel2//g' $INSTALLER/common/unity-audmodlib/$MODID-post-fs-data.sh
  test -f $SYS/lib/libstdc++.so && $CP_PRFX $SYS/lib/libstdc++.so $VEN/lib/libstdc++.so
elif device_check "sailfish" || device_check "marlin"; then
  sed -i 's/#pixel//g' $INSTALLER/common/unity-audmodlib/$MODID-post-fs-data.sh
fi

# Temp fix for oos oreo devices
if $OREONEW && [ "$(grep_prop ro.product.brand)" == "OnePlus" ]; then
  ui_print "   ! Oneplus Oreo device detected !"
  ui_print "   Setting selinux to permissive..."
  if $MAGISK; then echo "#!/system/bin/sh" > $INSTALLER/common/unity-audmodlib/$MODID-post-fs-data.sh; else echo "$SHEBANG" > $INSTALLER/common/unity-audmodlib/$MODID-post-fs-data.sh; fi
  echo "setenforce 0" >> $INSTALLER/common/unity-audmodlib/$MODID-post-fs-data.sh
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
  cp -f $INSTALLER/custom/Old/libv4a_fx_jb_$DRVARCH.so $INSTALLER/system/lib/soundfx/libv4a_fx_ics.so
  sed -ri "s/version=(.*)/version=\1 (2.3.4.0)/" $INSTALLER/module.prop
  $OREONEW && { sed -i "s|/vendor|/system|g" $INSTALLER/common/aml-patches.sh; LIBDIR=$SYS; OREONEW=false; }
else
  $NEW || $MAT || { chooseport mn && MAT=true; }
  cp -f $INSTALLER/custom/libv4a_fx_jb_$DRVARCH.so $INSTALLER/system/lib/soundfx/libv4a_fx_ics.so
  if $MAT; then
    ui_print "   Material V4A will be installed"
    cp -f $INSTALLER/custom/ViPER4AndroidFXMaterial.apk $INSTALLER/system/app/ViPER4AndroidFX/ViPER4AndroidFX.apk
    sed -ri -e "s/version=(.*)/version=\1 (2.5.0.5)/" -e "s/author=(.*)/author=\1, pittvandewitt/" -e "s/name=(.*)/name=\1 Materialized/" $INSTALLER/module.prop
  else
    ui_print "   Orignal V4A will be installed"
    sed -ri "s/version=(.*)/version=\1 (2.5.0.5)/" $INSTALLER/module.prop
  fi
fi

