#!/sbin/sh
# 
# /system/addon.d/99dax.sh
#
. /tmp/backuptool.functions

SLOT=$(for i in $(cat /proc/cmdline); do echo $i | grep slot | dd bs=1 skip=24 2>/dev/null; done)
if [ $SLOT != "" ]; then
    echo "slotnum=$SLOT" > /tmp/slotsel
elif [ $(cat /etc/recovery.fstab 2>/dev/null | grep boot_a) != "" ]; then
    echo "slotnum=_a" > /tmp/slotsel
else
    echo "none" > /tmp/slotsel
fi

safe_mount() {
 IS_MOUNTED=$(cat /proc/mounts | grep "$1")
 if [ "$IS_MOUNTED" ]; then
  mount -o rw,remount $1
 else
  mount $1
 fi
}

safe_mount /system

if [ -d "/system/system" ]; then
	SYS=/system/system
else
	SYS=/system
fi

if [ ! -d "$SYS/vendor" ] || [ -L "$SYS/vendor" ]; then
	safe_mount /vendor
	VEN=/vendor
elif [ -d "$SYS/vendor" ] || [ -L "/vendor" ]; then
	VEN=$SYS/vendor
fi

if [ -e "$VEN/build.prop" ] && [ ! -e "$SYS/build.prop" ]; then
	BUILDPROP=$VEN/build.prop
elif [ -e "$SYS/build.prop" ] && [ ! -e "$VEN/build.prop" ]; then
	BUILDPROP=$SYS/build.prop
elif [ -e "$SYS/build.prop" ] && [ -e "$VEN/build.prop" ]; then
	if [ $(wc -c < "$SYS/build.prop") -ge $(wc -c < "$VEN/build.prop") ]; then
		BUILDPROP=$SYS/build.prop
	else
		BUILDPROP=$VEN/build.prop
	fi
fi

if [ -d "/sdcard0" ]; then
	SDCARD=/sdcard0
elif [ -d "/sdcard/0" ]; then
	SDCARD=/sdcard/0
else
	SDCARD=/sdcard
fi

# FILE LOCATIONS

CONFIG_FILE=$SYS/etc/audio_effects.conf
OFFLOAD_CONFIG=$SYS/etc/audio_effects_offload.conf
OTHER_VENDOR_FILE=$SYS/etc/audio_effects_vendor.conf
HTC_CONFIG_FILE=$SYS/etc/htc_audio_effects.conf
VENDOR_CONFIG=$VEN/vendor/etc/audio_effects.conf

AUD_POL=$SYS/etc/audio_policy.conf
AUD_POL_CONF=$SYS/etc/audio_policy_configuration.xml
AUD_OUT_POL=$VEN/etc/audio_output_policy.conf
V_AUD_POL=$VEN/etc/audio_policy.conf

list_files() {
cat <<EOF
addon.d/99dax.sh
app/Ax.apk
app/AxUI.apk
app/Ax/Ax.apk
app/AxUI/AxUI.apk
etc/dolby/dax-default.xml
lib/soundfx/libswdax.so
priv-app/Ax/Ax.apk
priv-app/AxUI/AxUI.apk
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

# BACKUP CONFIGS

for BACKUP in $CONFIG_FILE $OFFLOAD_CONFIG $OTHER_VENDOR_FILE $HTC_CONFIG_FILE $VENDOR_CONFIG; do
	if [ -f $BACKUP ]; then
		cp -f $BACKUP $BACKUP.bak
	fi
done

for BACKUP in $AUD_POL $AUD_POL_CONF $AUD_OUT_POL $V_AUD_POL; do
	if [ -f $BACKUP ]; then
		cp -f $BACKUP $BACKUP.bak
	fi
done

# REMOVE LIBRARIES & EFFECTS

for CFG in $CONFIG_FILE $OFFLOAD_CONFIG $OTHER_VENDOR_FILE $HTC_CONFIG_FILE $VENDOR_CONFIG; do
	if [ -f $CFG ]; then
		# REMOVE EFFECTS
		sed -i 'H;1h;$!d;x; s/[[:blank:]]*dax {[^{}]*\({[^}]*}[^{}]*\)*}[[:blank:]]*\n//g' $CFG
		# REMOVE LIBRARIES
		sed -i '/dap {/,/}/d' $CFG
		sed -i '/dax {/,/}/d' $CFG
		sed -i '/dax_sw {/,/}/d' $CFG
		sed -i '/dax_hw {/,/}/d' $CFG
	fi
done

# ADD LIBRARIES & EFFECTS

for CFG in $CONFIG_FILE $OFFLOAD_CONFIG $OTHER_VENDOR_FILE $HTC_CONFIG_FILE $VENDOR_CONFIG; do
	if [ -f $CFG ]; then
		# ADD EFFECTS
		sed -i 's/^effects {/effects {\n  dax {\n    library dax\n    uuid 9d4921da-8225-4f29-aefa-6e6f69726861\n  }/g' $CFG
		# ADD LIBRARIES
		sed -i 's/^libraries {/libraries {\n  dax {\n    path \/system\/lib\/soundfx\/libswdax.so\n  }/g' $CFG
	fi
done

# COPY OVER MAIN AUDIO_EFFECTS CFG FILE TO VENDOR FILE

if [ -f $VENDOR_CONFIG ]; then
	cp -f $CONFIG_FILE $VENDOR_CONFIG
fi

# REMOVE DEEP_BUFFER LINES

if [ -f $AUD_OUT_POL ] && [ -f $AUD_POL_CONF ]; then
	# REMOVE DEEP_BUFFER
	sed -i '/Speaker/{n;s/deep_buffer,//;}' $AUD_POL_CONF
else
	for CFG in $AUD_POL $AUD_POL_CONF $AUD_OUT_POL $V_AUD_POL; do
		if [ -f $CFG ]; then
			# REMOVE DEEP_BUFFER
			sed -i '/deep_buffer {/,/}/d' $CFG
		fi
	done
fi

  ;;
  
esac
