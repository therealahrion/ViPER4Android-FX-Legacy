# External Tools

Addon where external (not already included in unity) tools can be added. Typical use for this will be binaries.

Place arm and x86 compiled binaries into their respective folders inside tools directory and unity will load them/add them to path automatically so you can call them like any other binary (no need to specify path)

Place other cpu architecture independent tools into the other folder and unity will load them/add them to path automatically so you can call them like any other binary (no need to specify path)

If you want to include a binary into your module itself (like for a boot script), the binaries are located at: $INSTALLER/common/unityfiles/tools during the (un)install process

Included binaries:
* sesearch by [xmikos @Github ](https://github.com/xmikos/setools-android)
* xmlstarlet compiled by james34602 @Github
* keycheck compiled for arm by [someone755 @Github](https://github.com/someone755/kerneller/blob/master/extract/tools/keycheck)