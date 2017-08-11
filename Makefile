PACKAGE_VERSION = 1.0.9

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest:6.0
	ARCHS = x86_64 i386
else
	TARGET = iphone:clang:latest:5.0
	ARCHS = armv7 armv7s arm64
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libEmojiLibrary
libEmojiLibrary_FILES = PSEmojiUtilities.m PSEmojiUtilities+Emoji.m PSEmojiUtilities+Functions.m

include $(THEOS_MAKE_PATH)/library.mk
include ../preferenceloader/locatesim.mk

setup:: all
	@cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib $(THEOS)/vendor/lib/
ifeq ($(SIMULATOR),1)
	@sudo cp -v $(THEOS_OBJ_DIR)/$(LIBRARY_NAME).dylib $(PL_SIMULATOR_ROOT)/usr/lib/
endif
