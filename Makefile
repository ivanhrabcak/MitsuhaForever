THEOS_DEVICE_IP = 192.168.178.116
# FINALPACKAGE = 1
# PREFIX = $(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/
THEOS_PACKAGE_SCHEME=rootless
export ADDITIONAL_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc -O3
export TARGET = iphone:16.1
Sushi_INSTALL_PATH = /Library/PreferenceBundles
Sushi_PRIVATE_FRAMEWORKS = Preferences
Sushi_EXTRA_FRAMEWORKS += libmitsuhaforever

include $(THEOS)/makefiles/common.mk

SUBPROJECTS += ASSWatchdog Prefs Spotify Springboard YTMusic
ARCHS = arm64e
INSTALL_TARGET_PROCESSES = SpringBoard Spotify Preferences YTMusic

include $(THEOS_MAKE_PATH)/aggregate.mk
internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist$(ECHO_END)
after-install::
		install.exec "killall -9 SpringBoard"
