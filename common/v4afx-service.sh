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

  # DETERMINE IF PIXEL (A/B OTA) DEVICE
  ABDeviceCheck=$(cat /proc/cmdline | grep slot_suffix | wc -l)
  if [ "$ABDeviceCheck" -gt 0 ]; then
    isABDevice=true
    if [ -d "/system_root" ]; then
        ROOT=/system_root
        SYSTEM=$ROOT/system
    else
        ROOT=""
        SYSTEM=$ROOT/system/system
    fi
  else
    isABDevice=false
    ROOT=""
    SYSTEM=$ROOT/system
  fi

  if [ $isABDevice == true ] || [ ! -d $SYSTEM/vendor ]; then
    VENDOR=/vendor
  else
    VENDOR=$SYSTEM/vendor
  fi

  ### FILE LOCATIONS ###
  # AUDIO EFFECTS
  CONFIG_FILE=$SYSTEM/etc/audio_effects.conf
  HTC_CONFIG_FILE=$SYSTEM/etc/htc_audio_effects.conf
  OTHER_V_FILE=$SYSTEM/etc/audio_effects_vendor.conf
  OFFLOAD_CONFIG=$SYSTEM/etc/audio_effects_offload.conf
  V_CONFIG_FILE=$VENDOR/etc/audio_effects.conf
  # AUDIO POLICY
  A2DP_AUD_POL=$SYSTEM/etc/a2dp_audio_policy_configuration.xml
  AUD_POL=$SYSTEM/etc/audio_policy.conf
  AUD_POL_CONF=$SYSTEM/etc/audio_policy_configuration.xml
  AUD_POL_VOL=$SYSTEM/etc/audio_policy_volumes.xml
  SUB_AUD_POL=$SYSTEM/etc/r_submix_audio_policy_configuration.xml
  USB_AUD_POL=$SYSTEM/etc/usb_audio_policy_configuration.xml
  V_AUD_OUT_POL=$VENDOR/etc/audio_output_policy.conf
  V_AUD_POL=$VENDOR/etc/audio_policy.conf
  # MIXER PATHS
  MIX_PATH=$SYSTEM/etc/mixer_paths.xml
  MIX_PATH_TASH=$SYSTEM/etc/mixer_paths_tasha.xml
  STRIGG_MIX_PATH=$SYSTEM/sound_trigger_mixer_paths.xml
  STRIGG_MIX_PATH_9330=$SYSTEM/sound_trigger_mixer_paths_wcd9330.xml
  V_MIX_PATH=$VENDOR/etc/mixer_paths.xml
  ########## ^ DO NOT REMOVE ^ ##########

  #### v INSERT YOUR REMOVE PATCH OR RESTORE v ####
  # REMOVE LIBRARIES & EFFECTS
  for CFG in $CONFIG_FILE $HTC_CONFIG_FILE $OTHER_V_FILE $OFFLOAD_CONFIG $V_CONFIG_FILE; do
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
