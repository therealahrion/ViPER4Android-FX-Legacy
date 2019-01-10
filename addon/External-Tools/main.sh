# External Tools

chmod -R 0755 $INSTALLER/addon/External-Tools
cp -R $INSTALLER/addon/External-Tools/tools $INSTALLER/common/unityfiles 2>/dev/null
[ -d "$INSTALLER/common/unityfiles/tools/other" ] && PATH=$INSTALLER/common/unityfiles/tools/other:$PATH
