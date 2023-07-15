export THEOS = /opt/theos
export THEOS_DEVICE_IP=127.0.0.1
export THEOS_DEVICE_PORT=22
ARCHS=armv7 arm64

_THEOS_PLATFORM_DPKG_DEB=dpkg-deb
THEOS_PLATFORM_DEB_COMPRESSION_TYPE=gzip
THEOS_PLATFORM_DEB_COMPRESSION_LEVEL=9

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = debugserver_azj
dbgsysapp_FILES = main.xm
dbgsysapp_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

