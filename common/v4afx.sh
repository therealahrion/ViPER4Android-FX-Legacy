(
while [ $(getprop sys.boot_completed) -ne 1 ] || [ "$(getprop init.svc.bootanim | tr '[:upper:]' '[:lower:]')" != "stopped" ]; do
  sleep 1
done

APP=$(pm list packages -3 | grep <ACTIVITY>)

if [ ! -d "$MODPATH" ]; then
  if [ "$APP" ]; then
    pm uninstall <ACTIVITY>
    rm -rf /data/data/<ACTIVITY>
  fi
  rm $0
  exit 0
elif [ "$APP" ]; then
  STATUS="$(pm list packages -d | grep '<ACTIVITY>')"
  if [ -f "$MODPATH/disable" ] && [ ! "$STATUS" ]; then
    pm disable <ACTIVITY>
  elif [ ! -f "$MODPATH/disable" ] && [ "$STATUS" ]; then
    pm enable <ACTIVITY>
  fi
elif [ ! -f "$MODPATH/disable" ] && [ ! "$APP" ]; then
  pm install $MODPATH/ViPER4AndroidFX.apk
  pm disable <ACTIVITY>
  pm enable <ACTIVITY>
fi
)&
