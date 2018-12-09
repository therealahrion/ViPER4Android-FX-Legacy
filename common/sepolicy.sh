# Put sepolicy statements here
# Example: allow { audioserver mediaserver } audioserver_tmpfs file { read write open }
allow { audioserver mediaserver } { audioserver_tmpfs mediaserver_tmpfs } file { read write execute }
allow { audioserver mediaserver } system_file file execmod
allow audioserver unlabeled file { read write execute open getattr }
allow hal_audio_default hal_audio_default process execmem
allow hal_audio_default hal_audio_default_tmpfs file execute
allow hal_audio_default audio_data_file dir search
allow <SOURCE> app_data_file file execute_no_trans
