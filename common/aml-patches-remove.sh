for FILE in ${CFGS}; do
  if [ "$FILE" == "*.conf" ]; then
    sed -i '/v4a_standard_fx {/,/}/d' $AMLPATH$FILE
    sed -i '/v4a_fx {/,/}/d' $AMLPATH$FILE
  elif [ "$FILE" == "*.xml" ]; then
    sed -i '/v4a_standard_fx/d' $AMLPATH$FILE
    sed -i '/v4a_fx/d' $AMLPATH$FILE
  fi
done
# if [ ! -z $XML_PRFX ]; then
  # # Enter xmlstarlet logic here
# fi
