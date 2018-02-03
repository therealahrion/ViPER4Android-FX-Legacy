$MAGISK || { for FILE in ${CFGS}; do
               case $FILE in
                 *.conf) sed -i "/v4a_standard_fx { #$MODID/,/} #$MODID/d" $UNITY$FILE
                         sed -i "/v4a_fx { #$MODID/,/} #$MODID/d" $UNITY$FILE;;
                 *.xml) sed -i "/<!--$MODID-->/d" $UNITY$FILE;;
               esac
             done }
