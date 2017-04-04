#!/system/bin/sh
# This script will be executed in late_start service mode
# More info in the main Magisk thread

#### v INSERT YOUR CONFIG.SH MODID v ####
MODID=v4afx
#### ^ INSERT YOUR CONFIG.SH MODID ^ ####

########## v DO NOT REMOVE v ##########
rm -rf /cache/magisk/audmodlib

if [ ! -d /magisk/$MODID ]; then
  AUDMODLIBPATH=/magisk/audmodlib

  # DETERMINE IF PIXEL (AB) DEVICE
  ABDeviceCheck=$(cat /proc/cmdline | grep slot_suffix | wc -l)
  if [ "$ABDeviceCheck" -gt 0 ]; then
    isABDevice=true
    SLOT=$(for i in `cat /proc/cmdline`; do echo $i | grep slot_suffix | awk -F "=" '{print $2}';done)
    SYSTEM=/system/system
    VENDOR=/vendor
  else
    isABDevice=false
    SYSTEM=/system
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

  rm -f /magisk/.core/service.d/$MODID.sh
fi
