$MAGISK || { for OFILE in ${CFGS}; do
               FILE="$UNITY$(echo $OFILE | sed "s|^/vendor|/system/vendor|g")"
               case $FILE in
                 *.conf) sed -i "/v4a_standard_fx { #$MODID/,/} #$MODID/d" $FILE
                         sed -i "/v4a_fx { #$MODID/,/} #$MODID/d" $FILE;;
                 *.xml) sed -i "/<!--$MODID-->/d" $FILE;;
               esac
             done }
