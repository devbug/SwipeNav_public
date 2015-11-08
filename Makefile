FW_DEVICE_IP=192.168.1.9
ARCHS = armv7 arm64
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
GO_EASY_ON_ME=1
SDKVERSION = 7.0

PACKAGE_VERSION = 1.0-1

SUBPROJECTS = Preferences

include theos/makefiles/common.mk
include theos/makefiles/aggregate.mk

TWEAK_NAME = SwipeNav
SwipeNav_FILES = Tweak.xm SNPageGestureRecognizer.mm
SwipeNav_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
SwipeNav_FRAMEWORKS = Foundation UIKit CoreGraphics
SwipeNav_LDFLAGS = -Xlinker -unexported_symbol -Xlinker "*"

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"

ri:: remoteinstall
remoteinstall:: all internal-remoteinstall after-remoteinstall
internal-remoteinstall::
	ssh root@$(FW_DEVICE_IP) "rm -f /Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).dylib"
	scp -P 22 "$(FW_PROJECT_DIR)/$(THEOS_OBJ_DIR_NAME)/$(TWEAK_NAME).dylib" root@$(FW_DEVICE_IP):/Library/MobileSubstrate/DynamicLibraries/
	scp -P 22 "$(FW_PROJECT_DIR)/$(TWEAK_NAME).plist" root@$(FW_DEVICE_IP):/Library/MobileSubstrate/DynamicLibraries/
after-remoteinstall::
	ssh root@$(FW_DEVICE_IP) "killall -9 backboardd"

