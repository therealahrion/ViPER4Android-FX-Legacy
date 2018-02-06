if [ -d /system/priv-app ]; then SOURCE=priv_app; else SOURCE=system_app; fi

if [ "$SEINJECT" != "/sbin/sepolicy-inject" ]; then
  $SEINJECT --live "permissive audioserver"
  $SEINJECT --live "allow mediaserver mediaserver_tmpfs file { read write execute }"
  $SEINJECT --live "allow mediaserver system_file file execmod"
  $SEINJECT --live "allow hal_audio_default hal_audio_default process execmem"
  #pixel$SEINJECT --live "allow hal_audio_default hal_audio_default_tmpfs file execute"
  #pixel$SEINJECT --live "allow hal_audio_default audio_data_file dir search"
else
  $SEINJECT -Z audioserver -l
  $SEINJECT -s mediaserver -t mediaserver_tmpfs -c file -p read,write,execute -l
  $SEINJECT -s mediaserver -t system_file -c file -p execmod -l
  $SEINJECT -s hal_audio_default -t hal_audio_default -c process -p execmem -l
  #pixel$SEINJECT -s hal_audio_default -t hal_audio_default_tmpfs -c file -p execmem -l
  #pixel$SEINJECT -s hal_audio_default -t audio_data_file -c dir -p search -l
fi
