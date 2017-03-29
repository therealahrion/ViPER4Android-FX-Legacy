#!/system/bin/sh

LOG_FILE=/data/local/v4a_run.log;

if [ -e /data/local/v4a_run.log ]; then
  rm /data/local/v4a_run.log
fi

echo "ViPER4Android script has run successfully $(date +"%m-%d-%Y %H:%M:%S")" | tee -a $LOG_FILE;

# Keep ViPER4Android in Memory
setprop sys.keep_app_1 com.vipercn.viper4android_v2
PPID=$(pidof com.vipercn.viper4android_v2)
echo "-17" > /proc/$PPID/oom_adj
renice -18 $PPID