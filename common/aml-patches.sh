ui_print "    Patching existing audio_effects files..."
for FILE in ${CFGS}; do
  if [ ! "$(grep "v4a_fx" $AMLPATH$FILE)" ] && [ ! "$(grep "v4a_standard_fx" $AMLPATH$FILE)" ]; then
    sed -i "s/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g" $AMLPATH$FILE
    sed -i "s/^libraries {/libraries {\n  v4a_fx {\n    path $LIBPATCH\/lib\/soundfx\/libv4a_fx_ics.so\n  }/g" $AMLPATH$FILE
  fi
done
for FILE in ${CFGSXML}; do
  if [ ! "$(grep "v4a_fx" $AMLPATH$FILE)" ] && [ ! "$(grep "v4a_standard_fx" $AMLPATH$FILE)" ]; then
    sed -i "/<libraries>/ a\        <library name=\"v4a_fx\" path=\"libv4a_fx_ics.so\"\/>" $AMLPATH$FILE
    sed -i "/<effects>/ a\        <effect name=\"v4a_standard_fx\" library=\"v4a_fx\" uuid=\"41d3c987-e6cf-11e3-a88a-11aba5d5c51b\"\/>" $AMLPATH$FILE
  fi
done
