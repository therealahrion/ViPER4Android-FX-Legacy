(until [ $(getprop sys.boot_completed) -eq 1 ]; do
  sleep 5
done
am start -a android.intent.action.MAIN -n <FACTIVITY>
until [ "$(pidof <ACTIVITY>)" ]; do
  sleep 3
done
killall <ACTIVITY>
killall audioserver
killall mediaserver)&
