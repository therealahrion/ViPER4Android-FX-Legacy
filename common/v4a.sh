#!/system/bin/sh
pm install /data/ViPER4AndroidFX.apk >/dev/null 2>&1
rm -f /data/ViPER4AndroidFX.apk
mount -o rw,remount /system
rm -f /system/etc/init/v4a.rc
mount -o ro,remount /system
for APP in $(find /data/app -type d -name "*com.pittvandewitt.viperfx*" -o -name "*com.audlabs.viperfx*" -o -name "*com.vipercn.viper4android_v2*"); do
  case $APP in
    *com.pittvandewitt.viperfx*) pm uninstall com.pittvandewitt.viperfx >/dev/null 2>&1;;
    *com.audlabs.viperfx*) pm uninstall com.audlabs.viperfx >/dev/null 2>&1;;
    *com.vipercn.viper4android*) pm uninstall com.vipercn.viper4android_v2 >/dev/null 2>&1;;
  esac
done
rm -f /data/v4a.sh
reboot
exit 0
