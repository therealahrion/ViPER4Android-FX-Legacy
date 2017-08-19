# v DO NOT MODIFY v
# See instructions file for predefined variables
# Add patches (such as audio config) here (starting at line 9)
# NOTE: Destination variable must have '$UNITYPATCH' in front of it
# Patch Ex: sed -i '/v4a_standard_fx {/,/}/d' $UNITYPATCH$CONFIG_FILE
#
#
# ^ DO NOT MODIFY ^
for CFG in $CONFIG_FILE $HTC_CONFIG_FILE $OTHER_V_FILE $OFFLOAD_CONFIG $V_CONFIG_FILE; do
  if [ -f $CFG ]; then
    sed -i '/v4a_standard_fx {/,/}/d' $UNITYPATCH$CFG
    sed -i '/v4a_fx {/,/}/d' $UNITYPATCH$CFG
  fi
done
ui_print "    Patching existing audio_effects files..."
for CFG in $CONFIG_FILE $HTC_CONFIG_FILE $OTHER_V_FILE $OFFLOAD_CONFIG $V_CONFIG_FILE; do
  if [ -f $CFG ]; then
    sed -i 's/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g' $UNITYPATCH$CFG
    sed -i 's/^libraries {/libraries {\n  v4a_fx {\n    path \/system\/lib\/soundfx\/libv4a_fx_ics.so\n  }/g' $UNITYPATCH$CFG
  fi
done