#!/sbin/sh
# 
# /system/addon.d/v4afx.sh
#

. /tmp/backuptool.functions

#### v INSERT YOUR CONFIG.SH MODID v ####
MODID=v4afx
AUDMODLIBID=audmodlib
#### ^ INSERT YOUR CONFIG.SH MODID ^ ####

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

########## v DO NOT REMOVE v ##########
if [ -d $SYSTEM/priv-app ]; then
  APPDIR=priv-app
else
  APPDIR=app
fi
########## ^ DO NOT REMOVE ^ ##########

list_files() {
cat <<EOF
$(cat /tmp/addon.d/$MODID-files)
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/$FILE
    done
  ;;
  restore)+
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/$FILE $R
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
	# Stub
  ;;
  post-restore)
    #### v INSERT YOUR FILE PATCHES v ####
    # REMOVE LIBRARIES & EFFECTS
    for CFG in $CONFIG_FILE $OFFLOAD_CONFIG $OTHER_V_FILE $HTC_CONFIG_FILE $V_CONFIG_FILE; do
      if [ -f $CFG ]; then
        # REMOVE EFFECTS
        sed -i '/v4a_standard_fx {/,/}/d' $CFG
        # REMOVE LIBRARIES
        sed -i '/v4a_fx {/,/}/d' $CFG
      fi
    done

    # ADD LIBRARIES & EFFECTS
    for CFG in $CONFIG_FILE $OFFLOAD_CONFIG $OTHER_V_FILE $HTC_CONFIG_FILE $V_CONFIG_FILE; do
      if [ -f $CFG ]; then
        # ADD EFFECTS
        sed -i 's/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g' $CFG
        # ADD LIBRARIES
        sed -i 's/^libraries {/libraries {\n  v4a_fx {\n    path \/system\/lib\/soundfx\/libv4a_fx_ics.so\n  }/g' $CFG
      fi
    done

    # COPY OVER MAIN AUDIO_EFFECTS CFG FILE TO VENDOR FILE
    if [ -f $V_CONFIG_FILE ]; then
      cp -af $CONFIG_FILE $V_CONFIG_FILE
    fi
    #### ^ INSERT YOUR FILE PATCHES ^ ####
  ;;
esac
