export IPHONE_SIMULATOR_ROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator7.0.sdk

TARGET = iphone
ARCHS = armv7 arm64
TWEAK_NAME = SpotLock
SpotLock_FILES = Tweak.xm
SpotLock_PRIVATE_FRAMEWORKS = GraphicsServices UIKit
THEOS_DEVICE_IP = 192.168.2.103

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

sync: all
	scp ./obj/SpotLock.dylib root@$(THEOS_DEVICE_IP):/Library/MobileSubstrate/DynamicLibraries/
	scp ./SpotLock.plist root@$(THEOS_DEVICE_IP):/Library/MobileSubstrate/DynamicLibraries/
	install.exec "killall -9 SpringBoard"
