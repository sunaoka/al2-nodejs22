NODEJS_VERSION := 22.22.2

IMAGE := node-v$(NODEJS_VERSION)-builder

MOUNT := -v ./rpmbuild/SOURCES:/root/rpmbuild/SOURCES \
         -v ./rpmbuild/SPECS:/root/rpmbuild/SPECS \
         -v ./rpmbuild/RPMS:/root/rpmbuild/RPMS \
         -v ./rpmbuild/SRPMS:/root/rpmbuild/SRPMS

INTERMEDIATES := rpmbuild/SOURCES/nodejs-keyring.kbx \
                 rpmbuild/SOURCES/SHASUMS256.txt.asc \
                 rpmbuild/SOURCES/SHASUMS256.txt

SOURCES := rpmbuild/SOURCES/node-v$(NODEJS_VERSION).tar.xz

TARGET := build-arm64 \
          build-amd64

all: build

build: $(SOURCES) $(TARGET)

rpmbuild/SOURCES/nodejs-keyring.kbx:
	curl -fsSLo $@ https://github.com/nodejs/release-keys/raw/HEAD/gpg/pubring.kbx

rpmbuild/SOURCES/SHASUMS256.txt.asc: rpmbuild/SOURCES/nodejs-keyring.kbx
	curl -fsSLo $@ https://nodejs.org/dist/v$(NODEJS_VERSION)/SHASUMS256.txt.asc

rpmbuild/SOURCES/SHASUMS256.txt: rpmbuild/SOURCES/SHASUMS256.txt.asc
	gpgv --keyring=rpmbuild/SOURCES/nodejs-keyring.kbx --output $@ < $<

rpmbuild/SOURCES/node-v$(NODEJS_VERSION).tar.xz: rpmbuild/SOURCES/SHASUMS256.txt
	curl -fsSLo $@ https://nodejs.org/dist/v$(NODEJS_VERSION)/$(@F)
	cd $(@D) && shasum --check $(<F) --ignore-missing

build-%:
	docker build --build-arg PLATFORM=linux/$* -t $(IMAGE):$* .
	docker run --rm $(MOUNT) $(IMAGE):$*

clean:
	-$(RM) -r rpmbuild/{RPMS,SRPMS}
	-$(RM) $(SOURCES) $(INTERMEDIATES)

.INTERMEDIATE: $(INTERMEDIATES)

.PHONY: all build clean
