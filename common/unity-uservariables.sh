# v DO NOT MODIFY v
# Uncomment AUDMODLIB=true if using audio modifcation library (if you're using a sound module). Otherwise, comment it
# Uncomment and change 'MINAPI' and 'MAXAPI' to the minimum and maxium android version for your mod (note that magisk has it's own minimum api: 21 (lollipop))
# ^ DO NOT MODIFY ^
#MINAPI=21
#MAXAPI=25
AUDMODLIB=true

# Temp fix for oos oreo devices
if $OREONEW && [ "$(grep_prop ro.product.brand)" == "OnePlus" ]; then
  ui_print "   ! Oneplus Oreo device detected !"
  ui_print "   Setting selinux to permissive..."
  echo "setenforce 0" > $INSTALLER/common/post-fs-data.sh
fi
