# ViPER4Android FX Legacy
This module enables ViPER4Android FX Legacy (You can choose between Material, 2.5.0.5, 2.4.0.1, and 2.3.4.0 during install). [More details in support thread](https://forum.xda-developers.com/apps/magisk/module-viper4android-fx-2-5-0-5-t3577058).

## Compatibility
* Android Jellybean+
* Selinux enforcing
* All root solutions (requires init.d support if not using magisk or supersu. Try [Init.d Injector](https://forum.xda-developers.com/android/software-hacking/mod-universal-init-d-injector-wip-t3692105))

## Change Log

### v4.3 - 5.16.2019
* Update to Unity v4.2
* Make lib workaround apply to all pie devices

### v4.2 - 5.3.2019
* Update to Unity v4.1

### v4.1 - 4.2.2019
* Make app open/close/fc workaround optional
* Added mtk sepolicy
* Misc unity bugfixes

### v4.0 - 3.28.2019
* Fix boot script once and for all
* Don't prompt for lib workaround if device that needs it
* Get rid of aroma option
* Update to Unity v4.0

### v3.4.2 - 2.21.2019
* Added Zuk Z2 Pro to lib workaround
* Made lib workaround a choice so I don't have to keep updating this

### v3.4.1 - 2.19.2019
* Add S9 to lib workaround
* Revert boot script

### v3.4 - 2.8.2019
* Boot script improvement
* Unity v3.3 update - minapi is now 17
* Allow skip of volkeys entirely (if device isn't compatible) by adding 'novk' to zipname

### v3.3 - 1.16.2019
* Forgot to move apk back to priv-app (needed for unity 3.2)

### v3.2 - 1.15.2019
* Unity v3.2 update
* Fix aroma for devices that don't have /cache partition

### v3.1 - 1.11.2019
* Unity hotfix
* Made aroma instructions clearer

### v3.0 - 1.10.2019
* Unity v3.1 update
* Added Aroma Installer option

### v2.4 - 1.5.2019
* Unity v3.0 update

### v2.3 - 12.23.2018
* Unity v2.2 update

### v2.2 - 12.21.2018
* Fix uapp/sapp zipname trigger
* Fix lib workaround
* Update to Unity v2.1

### v2.1 - 12.19.2018
* Remove usb policy patching - it's in a separate module now

### v2.0 - 12.18.2018
* Unity v2.0 update
* Fixed limitation in zipname triggers - you can use spaces in the zipname now and trigger is case insensitive
* Fixed old boot script bug - may fix issues for some users
* Improved boot script for user app install - should fix bootloop issues
* Removed really old stuff

### v1.8.2 - 12.6.2018
* Add usb audio fix - donjoe0 @xda-developers

### v1.8.1 - 11.8.2018
* Add libstdc++ workaround for pixel 3 and 3xl

### v1.8 - 11.3.2018
* Added capability to install app as user app. See xda thread for zipname options

### v1.7.5 - 10.23.2018
* Unity v1.7.2 update

### v1.7.4 - 9.20.2018
* Unity v1.7.1 update

### v1.7.3 - 9.2.2018
* Unity v1.7 update

### v1.7.2 - 8.30.2018
* Unity v1.6.1 update

### v1.7.1 - 8.24.2018
* Unity v1.6 update

### v1.7 - 7.17.2018
* Unity v1.5.5 update

### v1.6.9 - 5.7.2018
* Add mediaserver kill to boot script
* Unity v1.5.4 update

### v1.6.8 - 4.28.2018
* Removed new material apk - go to the app thread for it

### v1.6.7 - 4.26.2018
* Added compatibility to match what apks are compatible with (back to ics for all but 2.3 which goes back to gb) cause why not
* Added 2.4 v4a for completeness
* Unity v1.5.3 update

### v1.6.6 - 4.23.2018
* Updated new material apk

### v1.6.5 - 4.21.2018
* Update new material to v2.6.0.4

### v1.6.4 - 4.16.2018
* Unity 1.5.2 update
* Add AML detection/notification
* Update old material to latest repo version (no longer trips play protect)

### v1.6.3 - 4.13.2018
* Fix typo for pixel2/eph1 lib copy

### v1.6.2 - 4.12.2018
* Reworking/fixing of audio file patching

### v1.6.1 - 4.12.2018
* Unity 1.5.1 update
* Pixel2/EP1 fix

### v1.6 - 4.12.2018
* Backtracked version numbers - removed buggy/broken builds
* Add jni for all v4as
* Use priv-app only for v4a
* Various bug fixes and improvements
* Unity v1.5 update
* Updated new material apk

### v1.5.5 - 3.30.2018
* Fix effect removals

### v1.5.4 - 3.29.2018
* Unity v1.4.1 update

### v1.5.3 - 3.18.2018
* Remove dalvik cache for old v4a installs - should fix weird app issues
* Unity v1.4 update

### v1.5.2 - 3.1.2018
* Real fix for vol key logic

### v1.5.1 - 2.26.2018
* Quick fix for vol key logic

### v1.5 - 2.25.2018
* Fix for essential phone oreo
* Fixed vendor files in bootmode for devices with separate vendor partitions
* Bring back old keycheck method or devices that don't like the newer chainfire method
* Fix seg faults on system installs

### v1.4 - 2.16.2018
* Add file backup on system installs
* Fine tune unity prop logic
* Update util_functions with magisk 15.4 stuff
* Fix music_helper/sa3d removal in xml files

### v1.3.1/1.3.2 - 2.12.18
* No need for permissive selinux anymore for op 3/3t on oos oreo

### v1.3 - 2.12.2018
* Fix vendor cfg creation for devices that don't have it
* Fix sepolicy patching

### v1.2 - 2.10.2018
* Added sa3d removal for samsung devices

### v1.1 - 2.6.2018
* Fixes for xml cfg files

### v1.0 - 2.5.2018
* Initial rerelease

## Credits
* [ViPER's Audio](http://vipersaudio.com/blog/)
* [ViPER520](http://vipersaudio.com/blog/) @ XDA Developers
* [zhuhang](https://forum.xda-developers.com/showthread.php?t=2191223) @ XDA Developers
* [Team_DeWitt](https://forum.xda-developers.com/android/apps-games/app-viper4android-fx-2-6-0-0-t3774651) @ XDA Developers

## Source Code
* Module [GitHub](https://github.com/therealahrion/ViPER4Android-FX)
