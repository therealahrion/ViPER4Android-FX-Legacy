for FILE in ${CFGS}; do
  sed -i '/v4a_standard_fx {/,/}/d' $AMLPATH$FILE
  sed -i '/v4a_fx {/,/}/d' $AMLPATH$FILE
done
