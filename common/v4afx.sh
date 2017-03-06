#!/system/bin/sh
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread

#### v THIS SHOULD MATCH YOUR CONFIG.SH MODID v #####
MODID=v4afx
#### ^ THIS SHOULD MATCH YOUR CONFIG.SH MODID ^ #####

################ v DO NOT REMOVE v ################
AUDMODLIBPATH=/magisk/audmodlib

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
  for CFG in $CONFIG_FILE $OFFLOAD_CONFIG $OTHER_VENDOR_FILE $HTC_CONFIG_FILE $VENDOR_CONFIG; do
    if [ -f $CFG ]; then
	  # REMOVE EFFECTS
      sed -i '/v4a_standard_fx {/,/}/d' $AUDMODLIBPATH$CFG
      # REMOVE LIBRARIES
      sed -i '/v4a_fx {/,/}/d' $AUDMODLIBPATH$CFG
	  # REPLACE OLD FILE WITH NEW
	  cp -af $AUDMODLIBPATH$CFG $CFG
    fi
  done
}

if [ ! -d /magisk/$MODID ]; then
  uninstall
  rm -f /magisk/.core/post-fs-data.d/$MODID.sh
fi

rm -rf /cache/magisk/audmodlib
