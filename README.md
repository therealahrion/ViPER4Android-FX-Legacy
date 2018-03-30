# ViPER4Android FX
This module enables ViPER4Android FX. [More details in support thread](https://forum.xda-developers.com/apps/magisk/module-viper4android-fx-2-5-0-5-t3577058).

## Compatibility
* Android Jellybean+
* Selinux enforcing
* All root solutions (requires init.d support if not using magisk or supersu. Try [Init.d Injector](https://forum.xda-developers.com/android/software-hacking/mod-universal-init-d-injector-wip-t3692105))

## Change Log
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

## Source Code
* Module [GitHub](https://github.com/therealahrion/ViPER4Android-FX)
