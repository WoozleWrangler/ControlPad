VERSION=3.2

BUNDLE=ControlPad.app
RESOURCE_DIR=Resources
PACKAGE_DIR=package-dir
PACKAGE_CONTROL=package-control.txt
PACKAGE_FILE=ControlPad.deb

NIB_FILES = $(RESOURCE_DIR)/MainWindow.nib $(RESOURCE_DIR)/SNESControllerViewController.nib $(RESOURCE_DIR)/SessionController.nib
RESOURCES = $(wildcard $(RESOURCE_DIR)/*.png) $(wildcard $(RESOURCE_DIR)/snes-*.txt) $(NIB_FILES)
PLIST_FILE = ControlPad-Info.plist
OBJS = Classes/SessionController.o Classes/SNESControllerAppDelegate.o Classes/SNESControllerViewController.o main.o


COPT = -F/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${VERSION}.sdk/System/Library/Frameworks -F/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${VERSION}.sdk/System/Library/PrivateFrameworks -I. -I./Classes/ -I/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.0.sdk/usr/lib/gcc/arm-apple-darwin9/4.2.1/include -isysroot /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${VERSION}.sdk  -L/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS${VERSION}.sdk/usr/lib
COPT += -march=armv6 -miphoneos-version-min=${VERSION} -O3 

GCC = /Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/arm-apple-darwin10-gcc-4.2.1
GXX = /Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/arm-apple-darwin10-g++-4.2.1
STRIP = /Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/strip
IBTOOL = ibtool
LDID = /usr/local/bin/ldid
DPKG_DEB = /opt/local/bin/dpkg-deb



# Inopia's menu system, hacked for the GP2X under rlyeh's sdk
PRELIBS = -multiply_defined suppress -lobjc -fobjc-exceptions \
          -framework CoreFoundation \
		  -framework CoreGraphics \
          -framework Foundation \
          -framework UIKit \
          -framework AVFoundation \
          -framework MediaPlayer \
          -lIOKit \
          -framework GameKit \
          -allow_stack_execute

all: bundle
clean: tidy



%.o: %.m
	$(GCC) ${COPT} -c $< -o $@

%.nib: %.xib
	$(IBTOOL) --compile $@ $<

ControlPad: $(OBJS)
	$(GXX) $(COPT) $(OBJS) $(PRELIBS) -o $@
	
bundle: ControlPad $(NIB_FILES)
	mkdir -p $(BUNDLE)
	$(STRIP) ControlPad -o $(BUNDLE)/ControlPad
	$(LDID) -S $(BUNDLE)/ControlPad
	cp $(RESOURCES) $(BUNDLE)
	cp $(PLIST_FILE) $(BUNDLE)/Info.plist
	
package: bundle
	mkdir -p $(PACKAGE_DIR)/Applications
	mkdir -p $(PACKAGE_DIR)/DEBIAN
	cp -r $(BUNDLE) $(PACKAGE_DIR)/Applications
	cp $(PACKAGE_CONTROL) $(PACKAGE_DIR)/DEBIAN/control
	export COPYFILE_DISABLE 
	export COPY_EXTENDED_ATTRIBUTES_DISABLE
	$(DPKG_DEB) -b $(PACKAGE_DIR) $(PACKAGE_FILE)
	
tidy:
	rm -f *.o Classes/*.o
	rm -rf $(BUNDLE)
	rm -rf $(PACKAGE_DIR)
	rm -f ControlPad
	rm -f ControlPad.deb
