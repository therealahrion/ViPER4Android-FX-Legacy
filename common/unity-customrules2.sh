TIMEOFEXEC=1

# GET OLD/NEW FROM ZIP NAME
case $(basename $ZIP) in
  *old*|*Old*|*OLD*) UI=21; MAT=21;;
  *new*|*New*|*NEW*) UI=42; MAT=21;;
  *mat*|*Mat*|*MAT*) UI=42; MAT=42;;
esac

# Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
KEYCHECK=$INSTALLER/common/keycheck
chmod 755 $KEYCHECK

chooseport() {
  $KEYCHECK
  INPUT=$?
  if [[ $INPUT -eq 42 ]] || [[ $INPUT -eq 21 ]]; then
    UI=$INPUT
  else
    ui_print "   ! Unrecognized key!"
    UI=42
  fi
  shift
}

ui_print " "
ui_print "- Select Version -"
if [ -z $MAT ]; then
  ui_print "   Choose which V4A you want installed:"
  ui_print "   Vol+ = new (2.5.0.5), Vol- = old (2.3.4.0)"
  ui_print "   Old V4A will install super quality driver"
  chooseport
else
  ui_print "   V4A version specified in zipname!"
fi
if [[ $UI -eq 21 ]]; then
  ui_print "   Old V4A will be installed"
  cp -f $INSTALLER/custom/Old/ViPER4AndroidFX.apk $INSTALLER/system/app/ViPER4AndroidFX/ViPER4AndroidFX.apk
  cp -f $INSTALLER/custom/Old/libv4a_fx_jb_NEON.so $INSTALLER/custom/libv4a_fx_jb_NEON.so
  cp -f $INSTALLER/custom/Old/libv4a_fx_jb_X86.so $INSTALLER/custom/libv4a_fx_jb_X86.so
  sed -ri "s/version=(.*)/version=\1 (2.3.4.0)/" $INSTALLER/module.prop
else
  if [ -z $MAT ]; then
    sleep 1
    ui_print "   Choose which new V4A you want installed:"
    ui_print "   Vol+ = material, Vol- = original"
    chooseport
  else
    UI=$MAT
  fi
  if [[ $UI -eq 42 ]]; then
    ui_print "   Material V4A will be installed"
    cp -f $INSTALLER/custom/ViPER4AndroidFXMaterial.apk $INSTALLER/system/app/ViPER4AndroidFX/ViPER4AndroidFX.apk
    sed -ri -e "s/version=(.*)/version=\1 (2.5.0.5)/" -e "s/author=(.*)/author=\1, pittvandewitt/" -e "s/name=(.*)/name=\1 Materialized/" $INSTALLER/module.prop
  else
    ui_print "   Orignal V4A will be installed"
    sed -ri "s/version=(.*)/version=\1 (2.5.0.5)/" $INSTALLER/module.prop
  fi
fi
