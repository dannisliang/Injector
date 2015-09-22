#!/bin/bash

REPOROOT=$(pwd)

DAEMON=tw.edu.mcu.cce.nrl.InjectorDaemon_1.0-1_iphoneos-arm.deb
#AGENT=tw.edu.mcu.cce.nrl.InjectorAgent_1.0-1_iphoneos-arm.deb
PREFERENCELOADER=tw.edu.mcu.cce.nrl.InjectorPreferenceLoader_1.0-1_iphoneos-arm.deb
#AppWithAgent=tw.edu.mcu.cce.nrl.Injector_1.0_iphoneos-arm_agent.deb
App=tw.edu.mcu.cce.nrl.Injector_1.0_iphoneos-arm.deb
FOREGROUND=tw.edu.mcu.cce.nrl.InjectorForeground_1.0-1_iphoneos-arm.deb
APP=tw.edu.mcu.cce.nrl.Injector_1.0_iphoneos-arm.deb
UPLOADER=tw.edu.mcu.cce.nrl.InjectorUploader_1.0-1_iphoneos-arm.deb

rm -rf output/
mkdir output

#cp InjectorDaemon/Packages/${DAEMON} output/${Daemon}

# extract daemon
dpkg-deb -x InjectorDaemon/Packages/${DAEMON} ${REPOROOT}/output/daemon
dpkg-deb -e InjectorDaemon/Packages/${DAEMON} ${REPOROOT}/output/daemon/DEBIAN

# extract agent
#dpkg-deb -x InjectorAgent/Packages/${AGENT} ${REPOROOT}/output/agent
#dpkg-deb -e InjectorAgent/Packages/${AGENT} ${REPOROOT}/output/agent/DEBIAN

# extract PreferenceLoader
dpkg-deb -x InjectorPreferenceLoader/Packages/${PREFERENCELOADER} ${REPOROOT}/output/preference
dpkg-deb -e InjectorPreferenceLoader/Packages/${PREFERENCELOADER} ${REPOROOT}/output/preference/DEBIAN

# extract foreground
dpkg-deb -x InjectorForeground/Packages/${FOREGROUND} ${REPOROOT}/output/foreground
dpkg-deb -e InjectorForeground/Packages/${FOREGROUND} ${REPOROOT}/output/foreground/DEBIAN

# extract uploader
dpkg-deb -x InjectorUploader/Packages/${UPLOADER} ${REPOROOT}/output/uploader
dpkg-deb -e InjectorUploader/Packages/${UPLOADER} ${REPOROOT}/output/uploader/DEBIAN

# extract app
dpkg-deb -x InjectorApp/Packages/${APP} ${REPOROOT}/output/app
dpkg-deb -e InjectorApp/Packages/${APP} ${REPOROOT}/output/app/DEBIAN

# move files
cd output

#make dir
mkdir -p app/Library/PreferenceBundles
mkdir -p app/Library/PreferenceLoader/Preferences
mkdir -p app/Library/LaunchDaemons
mkdir -p app/var/mobile/Library/Preferences


#move preference
mv preference/Library/PreferenceBundles/InjectorPreferenceLoader.bundle app/Library/PreferenceBundles/InjectorPreferenceLoader.bundle
mv preference/Library/PreferenceLoader/Preferences/InjectorPreferenceLoader.plist app/Library/PreferenceLoader/Preferences/InjectorPreferenceLoader.plist
mv preference/var/mobile/Library/Preferences/tw.edu.mcu.cce.nrl.InjectorPreferenceLoader.plist app/var/mobile/Library/Preferences/tw.edu.mcu.cce.nrl.InjectorPreferenceLoader.plist
#move foreground
mv foreground/usr/sbin/InjectorForeground app/Applications/Injector.app/InjectorForeground
#move daemon
mv daemon/Library/LaunchDaemons/tw.edu.mcu.cce.nrl.InjectorDaemon.plist app/Library/LaunchDaemons/tw.edu.mcu.cce.nrl.InjectorDaemon.plist
mv daemon/usr/sbin/InjectorDaemon app/Applications/Injector.app/InjectorDaemon
#move uploader
mv uploader/Library/LaunchDaemons/tw.edu.mcu.cce.nrl.InjectorUploader.plist app/Library/LaunchDaemons/tw.edu.mcu.cce.nrl.InjectorUploader.plist
mv uploader/usr/sbin/InjectorUploader app/Applications/Injector.app/InjectorUploader

#copy the icon on cydia
cp ../App\ Icon\ \[Rounded\]/Icon-Small-50@2x.png app/Applications/Injector.app/CydiaIcon.png

# create deb, daemon and preferenceloadr
dpkg-deb -b -Zgzip 'app' ${App}

#move agent
#mv agent/usr/sbin/InjectorAgent app/Applications/Injector.app/InjectorAgent
#mv agent/Library/LaunchDaemons/tw.edu.mcu.cce.nrl.InjectorAgent.plist app/Library/LaunchDaemons/tw.edu.mcu.cce.nrl.InjectorAgent.plist

# create deb, daemon, preferenceloadr, agent
#dpkg-deb -b -Zgzip 'app' ${AppWithAgent}

#rm -rf agent/
rm -rf daemon/
rm -rf preference/
rm -rf foreground/
rm -rf app/
rm -rf uploader/

if [ "$1" = "upload" ]; then
#scp ${AppWithAgent} injector@120.125.86.7:~/www/Release/${AppWithAgent}
scp ${App} injector@120.125.86.7:~/www/Release/${App}
fi

