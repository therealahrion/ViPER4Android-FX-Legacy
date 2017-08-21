# v DO NOT MODIFY v
# See instructions file for predefined variables
# Add patches (such as audio config) here (starting at line 9)
# NOTE: Destination variable must have '$AMLPATH' in front of it
# Patch Ex: sed -i '/v4a_standard_fx {/,/}/d' $AMLPATH$CONFIG_FILE
#
#
# ^ DO NOT MODIFY ^
unity_patches_remove() {
for CFG in $CONFIG_FILE $HTC_CONFIG_FILE $OTHER_V_FILE $OFFLOAD_CONFIG $V_CONFIG_FILE; do
  if [ -f $CFG ]; then
	sed -i '/v4a_standard_fx {/,/}/d' $AMLPATH$CFG
	sed -i '/v4a_fx {/,/}/d' $AMLPATH$CFG
  fi
done
}
