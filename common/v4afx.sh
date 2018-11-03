#!/system/bin/sh
MODID=<MODID>
pm list packages -3
while [ $? -ne 0 ]; do
  sleep 1
  pm list packages -3
done
APP=$(pm list packages -3 | grep <ACTIVITY>)

if [ ! -d "$UNITY/$MODID" ]; then
  if [ "$APP" ]; then
    pm uninstall <ACTIVITY>
    rm -rf /data/data/<ACTIVITY>
  fi
  rm $0
  exit 0
elif [ "$APP" ]; then
  STATUS="$(pm list packages -d | grep '<ACTIVITY>')"
  if [ -f "$UNITY/$MODID/disable" ] && [ ! "$STATUS" ]; then
    pm disable <ACTIVITY>
  elif [ ! -f "$UNITY/$MODID/disable" ] && [ "$STATUS" ]; then
    pm enable <ACTIVITY>
  fi
elif [ ! -f "$UNITY/$MODID/disable" ] && [ ! "$APP" ]; then
  pm install $UNITY/$MODID/ViPER4AndroidFX.apk
  while [ $? -ne 0 ]; do
    sleep 1
    pm install $UNITY/$MODID/ViPER4AndroidFX.apk
  done
  pm disable <ACTIVITY>
  pm enable <ACTIVITY>
fi
