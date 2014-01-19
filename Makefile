include theos/makefiles/common.mk
TWEAK_NAME = SpotLock
SpotLock_FILES = Tweak.xm
SpotLock_PRIVATE_FRAMEWORKS = GraphicsServices
include $(THEOS_MAKE_PATH)/tweak.mk
