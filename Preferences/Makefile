FW_DEVICE_IP = 192.168.1.9

ARCHS = armv7 arm64
SDKVERSION = 7.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 4.0
GO_EASY_ON_ME=1

include theos/makefiles/common.mk

BUNDLE_NAME = swipenav
swipenav_FILES = SwipeNav.m \
				 SwipeNavListController.m \
				 SNExceptedAppListController.m \
				 ../../FilteredAppListTableView/PSFilteredAppListCell.m \
				 ../../FilteredAppListTableView/PSFilteredAppListListController.m
swipenav_INSTALL_PATH = /Library/PreferenceBundles
swipenav_FRAMEWORKS = UIKit
swipenav_PRIVATE_FRAMEWORKS = Preferences SpringBoardServices

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SwipeNav.plist$(ECHO_END)

ri:: remoteinstall
remoteinstall:: all internal-remoteinstall after-remoteinstall
internal-remoteinstall::
	ssh root@$(FW_DEVICE_IP) "rm -f /Library/PreferenceBundles/$(BUNDLE_NAME).bundle/$(BUNDLE_NAME)"
	scp "$(FW_PROJECT_DIR)/$(THEOS_OBJ_DIR_NAME)/$(BUNDLE_NAME).bundle/$(BUNDLE_NAME)" root@$(FW_DEVICE_IP):/Library/PreferenceBundles/$(BUNDLE_NAME).bundle/
	scp "$(FW_PROJECT_DIR)/$(THEOS_OBJ_DIR_NAME)/$(BUNDLE_NAME).bundle/en.lproj/Advanced.strings" root@$(FW_DEVICE_IP):/Library/PreferenceBundles/$(BUNDLE_NAME).bundle/en.lproj
	scp "$(FW_PROJECT_DIR)/$(THEOS_OBJ_DIR_NAME)/$(BUNDLE_NAME).bundle/ko.lproj/Advanced.strings" root@$(FW_DEVICE_IP):/Library/PreferenceBundles/$(BUNDLE_NAME).bundle/ko.lproj
after-remoteinstall::
	ssh root@$(FW_DEVICE_IP) "killall -9 Preferences"
