#!/system/bin/sh
# This script will be executed in post-fs-data mode
# More info in the main Magisk thread

#### v INSERT YOUR CONFIG.SH MODID v ####
MODID=v4afx
#### ^ INSERT YOUR CONFIG.SH MODID ^ ####

rm -rf /cache/magisk/audmodlib

if [ ! -d /magisk/$MODID ]; then
  ########## v DO NOT REMOVE v ##########
  AUDMODLIBPATH=/magisk/audmodlib

  safe_mount() {
    IS_MOUNTED=$(cat /proc/mounts | grep "$1")
    if [ "$IS_MOUNTED" ]; then
      mount -o rw,remount $1
    else
      mount $1
    fi
  }

  safe_mount /system

  SLOT=$(getprop ro.boot.slot_suffix 2>/tmp/null)
  if [ "$SLOT" ]; then
    SYSTEM=/system/system
  else
    SYSTEM=/system
  fi

  if [ ! -d "$SYSTEM/vendor" ] || [ -L "$SYSTEM/vendor" ]; then
    safe_mount /vendor
    VENDOR=/vendor
  elif [ -d "$SYSTEM/vendor" ] || [ -L "/vendor" ]; then
    VENDOR=$SYSTEM/vendor
  fi

  ### FILE LOCATIONS ###
  # AUDIO EFFECTS
  CONFIG_FILE=$SYSTEM/etc/audio_effects.conf
  VENDOR_CONFIG=$VENDOR/etc/audio_effects.conf
  HTC_CONFIG_FILE=$SYSTEM/etc/htc_audio_effects.conf
  OTHER_VENDOR_FILE=$SYSTEM/etc/audio_effects_vendor.conf
  OFFLOAD_CONFIG=$SYSTEM/etc/audio_effects_offload.conf
  # AUDIO POLICY
  AUD_POL=$SYSTEM/etc/audio_policy.conf
  AUD_POL_CONF=$SYSTEM/etc/audio_policy_configuration.xml
  AUD_OUT_POL=$VENDOR/etc/audio_output_policy.conf
  V_AUD_POL=$VENDOR/etc/audio_policy.conf
  ########## ^ DO NOT REMOVE ^ ##########

  #### v INSERT YOUR REMOVE PATCH OR RESTORE v ####
  # REMOVE LIBRARIES & EFFECTS
  for CFG in $CONFIG_FILE $OFFLOAD_CONFIG $OTHER_VENDOR_FILE $HTC_CONFIG_FILE $VENDOR_CONFIG; do
    if [ -f $CFG ]; then
      # REMOVE EFFECTS
	  sed -i '/v4a_standard_fx {/,/}/d' $AUDMODLIBPATH$CFG
	  # REMOVE LIBRARIES
      sed -i '/v4a_fx {/,/}/d' $AUDMODLIBPATH$CFG
    fi
  done
  #### ^ INSERT YOUR REMOVE PATCH OR RESTORE ^ ####

  rm -f /magisk/.core/post-fs-data.d/$MODID.sh
fi
