ARCHS = arm64
TARGET = iphone:clang:latest:15.0
FINALPACKAGE = 1
THEOS_PACKAGE_SCHEME = roothide # rootless
IPHONEOS_DEPLOYMENT_TARGET = 15.0
INSTALL_TARGET_PROCESSES = MGInspector

# Install Destination
THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

include $(THEOS)/makefiles/common.mk

XCODE_SCHEME = MGInspector
XCODEPROJ_NAME = MGInspector

$(XCODE_SCHEME)_XCODEFLAGS = \
	IPHONEOS_DEPLOYMENT_TARGET="$(IPHONEOS_DEPLOYMENT_TARGET)" \
	CODE_SIGN_IDENTITY="" \
	AD_HOC_CODE_SIGNING_ALLOWED=YES
$(XCODE_SCHEME)_XCODE_SCHEME = $(XCODE_SCHEME)
$(XCODE_SCHEME)_CODESIGN_FLAGS = -Sentitlements.plist
$(XCODE_SCHEME)_INSTALL_PATH = /Applications

include $(THEOS_MAKE_PATH)/xcodeproj.mk

# Extract version from control file
define VERSION
$(shell awk -F': ' '/^Version:/ {print $$2}' control)
endef

before-package::
ifdef BUILD_TIPA
	mkdir -p ./packages/Payload
	cp -R ./.theos/_/Applications/MGInspector.app ./packages/Payload
	ldid -Sentitlements.plist ./packages/Payload/MGInspector.app/MGInspector
	cd ./packages && zip -mry ./MGInspector_$(VERSION).tipa ./Payload
	mkdir -p ./.theos/_/tmp
	cp ./packages/MGInspector_$(VERSION).tipa ./.theos/_/tmp/
endif