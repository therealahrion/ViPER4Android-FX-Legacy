#!/system/bin/sh

LOG_FILE=/data/local/audiotweaks_run.log;
/system/xbin/supolicy --live "permissive priv_app audioserver" \
"permissive system_app audioserver" \
"permissive priv_app mediaserver" \
"permissive system_app mediaserver" \
"permissive priv_app property_socket" \
"permissive system_app property_socket" \
"allow audioserver audioserver_tmpfs file { open read write execute }" \
"allow mediaserver mediaserver_tmpfs file { open read write execute }" \
"allow priv_app init unix_stream_socket { connectto }" \
"allow system_app init unix_stream_socket { connectto }" \
"allow priv_app property_socket sock_file { getattr open read write execute }" \
"allow system_app property_socket sock_file { getattr open read write execute }"

# LOW POWER AUDIO TWEAKS
setprop lpa.decode false
setprop lpa.releaselock false
setprop lpa.use-stagefright false
setprop tunnel.decode false

# OTHER AUDIO TWEAKS
setprop audio.deep_buffer.media false
setprop tunnel.audiovideo.decode false
setprop persist.sys.media.use-awesome 1
setprop ro.audio.samplerate 48000
setprop ro.audio.pcm.samplerate 48000

if [ -e /data/local/audiotweaks_run.log ]; then
  rm /data/local/audiotweaks_run.log
fi

echo "Universal audio tweaks script has run successfully $(date +"%m-%d-%Y %H:%M:%S")" | tee -a $LOG_FILE;