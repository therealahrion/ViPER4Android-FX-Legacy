(
while [ $(getprop sys.boot_completed) -ne 1 ] || [ "$(getprop init.svc.bootanim | tr '[:upper:]' '[:lower:]')" != "stopped" ]; do
  sleep 1
done
sleep 3
am start -a android.intent.action.MAIN -n <FACTIVITY>
sleep 1
killall <ACTIVITY>
killall audioserver
killall mediaserver
)&