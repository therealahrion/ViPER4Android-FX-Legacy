#!/system/bin/sh
# Please don't hardcode /magisk/modname/... ; instead, please use $MODDIR/...
# This will make your scripts compatible even if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in post-fs-data mode
# More info in the main Magisk thread

MODID=v4a
AUDMODLIBPATH=/magisk/audmodlib
source $MODDIR/module.prop

SLOT=$(getprop ro.boot.slot_suffix 2>/tmp/null)
if [ "$SLOT" ]; then
  SYSTEM=/system/system
else
  SYSTEM=/system
fi

if [ ! -d "$SYSTEM/vendor" ] || [ -L "$SYSTEM/vendor" ]; then
  VENDOR=/vendor
elif [ -d "$SYSTEM/vendor" ] || [ -L "/vendor" ]; then
  VENDOR=$SYSTEM/vendor
fi

# FILE LOCATIONS
CONFIG_FILE=$SYSTEM/etc/audio_effects.conf
VENDOR_CONFIG=$VENDOR/etc/audio_effects.conf
HTC_CONFIG_FILE=$SYSTEM/etc/htc_audio_effects.conf
OTHER_VENDOR_FILE=$SYSTEM/etc/audio_effects_vendor.conf
OFFLOAD_CONFIG=$SYSTEM/etc/audio_effects_offload.conf

#### PATCHING FILES ####
ui_print " "
ui_print "- Patching necessary cfg files -"

# REMOVE LIBRARIES & EFFECTS
ui_print "   Removing library & effect lines..."
for CFG in $CONFIG_FILE $OFFLOAD_CONFIG $OTHER_VENDOR_FILE $HTC_CONFIG_FILE $VENDOR_CONFIG; do
  if [ -f $CFG ]; then
    # REMOVE LIBRARIES & EFFECTS
    sed -i '/v4a_fx {/,/}/d' $AUDMODLIBPATH$CFG
    sed -i '/v4a_standard_fx {/,/}/d' $AUDMODLIBPATH$CFG
  fi
done

# ADD LIBRARIES & EFFECTS
ui_print "   Patching existing audio_effects files..."
for CFG in $CONFIG_FILE $OFFLOAD_CONFIG $OTHER_VENDOR_FILE $HTC_CONFIG_FILE $VENDOR_CONFIG; do
  if [ -f $CFG ]; then
    # ADD EFFECTS
    sed -i 's/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g' $AUDMODLIBPATH$CFG
    # ADD LIBRARIES
    sed -i 's/^libraries {/libraries {\n  v4a_fx {\n    path \/system\/lib\/soundfx\/libv4a_fx_ics.so\n  }/g' $AUDMODLIBPATH$CFG
  fi
done