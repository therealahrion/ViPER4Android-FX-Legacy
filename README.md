# ViPER4Android FX
This module enables ViPER4Android FX. [More details in support thread](https://forum.xda-developers.com/apps/magisk/module-viper4android-fx-2-5-0-5-t3577058).

### Dependencies
* [Audio Modification Library](https://forum.xda-developers.com/apps/magisk/module-audio-modification-library-t3579612) @ XDA Developers

## Compatibility
* Android Jellybean+
* Magisk install (MagiskSU/SuperSU)
* Pixel support
* System install
* Works with [AM3D Zirene Sound](https://forum.xda-developers.com/android/apps-games/mod-zirene-sound-am3d-t3396698/post71580634#post71580634}, [Dolby Atmos](https://github.com/therealahrion/Dolby-Atmos-ZTE-Axon-7), & ViPER4Android XHiFi

## Change Log
v1.4
	- AudModLib v1.4 update which changes SELinux live patching to allow better compatibility between different devices, kernels, and roms; while also keeping the amount of "allowances" to a minumum
	- Changed post-fs-data(.d)/service(.d) shell script names for cosmetic recognition
	- Merge SuperSU shell script with MagiskSU post-fs-data(.d) script for less fragmentation
	- Install script changes that include: major update to Pixel (AB) support, mounting changes, fixes & consolidation
	- App smali hacks

v1.3
	- AudModLib v1.3 update push which includes the script addition to allow various audio mods working with SELinux Enforcing
	- Remove (audmodlib)service.sh and replace with post-fs-data(.d) audmodlib.sh, which should fix when root may be lost upon installing certain mods
	- System install will now have the same script updates as the AudModLib v1.3 to allow to work in SELinux Enforcing

v1.2
	- Added audmodlib.sh post-fs-data.d script
	- Install script fixes
	- post-fs-data.d script fixes
    - Push AudModLib v1.2 hotfixes

v1.1
    - AudModLib v1.1 hotfix for bootloops issues on some devices

v1.0
    - Initial Magisk release

## Credits
* [ViPER's Audio](http://vipersaudio.com/blog/)
* [ViPER520](http://vipersaudio.com/blog/) @ XDA Developers
* [zhuhang](https://forum.xda-developers.com/showthread.php?t=2191223) @ XDA Developers

## Source Code
* Module [GitHub](https://github.com/therealahrion/ViPER4Android-FX)