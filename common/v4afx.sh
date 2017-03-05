#!/system/bin/sh
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread

#### v THIS SHOULD MATCH YOUR CONFIG.SH MODID v #####
MODID=v4afx
#### ^ THIS SHOULD MATCH YOUR CONFIG.SH MODID ^ #####

################ v DO NOT REMOVE v ################
TMPAUDMODLIBPATH=/magisk/audmodlib

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
################ ^ DO NOT REMOVE ^ ################

uninstall() {
  # REMOVE LIBRARIES & EFFECTS
  ui_print "   Removing library & effect lines..."
  for CFG in $CONFIG_FILE $OFFLOAD_CONFIG $OTHER_VENDOR_FILE $HTC_CONFIG_FILE $VENDOR_CONFIG; do
    if [ -f $CFG ]; then
      # REMOVE LIBRARIES & EFFECTS
      sed -i '/v4a_fx {/,/}/d' $TMPAUDMODLIBPATH$CFG
      sed -i '/v4a_fx {/,/}/d' $CFG
      sed -i '/v4a_standard_fx {/,/}/d' $TMPAUDMODLIBPATH$CFG
      sed -i '/v4a_standard_fx {/,/}/d' $CFG
    fi
  done
}

if [ ! -d /magisk/$MODID ] ; then
  uninstall
  sed -i '/source \/magisk\/.core\/post-fs-data.d\/v4afx.sh/d' $TMPAUDMODLIBPATH/post-fs-data.sh
  rm -f /magisk/.core/post-fs-data.d/$MODID.sh
fi

source $TMPAUDMODLIBPATH/post-fs-data.sh