PREFIX = $(DESTDIR)/usr
SYSCONFDIR=$(DESTDIR)/etc
DATADIR=$(PREFIX)/share
SYSTEMD_DIR=$(PREFIX)/lib/systemd/system
INSTALL = /bin/install -c
MKDIR = /bin/install -c -d
RM = rm -rf
TAR = /usr/bin/tar
TMPDIR := $(shell mktemp -d)
CURRENT_DIR := $(shell pwd)
PKG_MGR := $(shell which yum)
RPMBUILD := $(shell which rpmbuild)

install:
	$(MKDIR) $(PREFIX)/bin
	$(MKDIR) $(SYSCONFDIR)/systemdock/containers.d
	$(MKDIR) $(DATADIR)/systemdock/templates
	$(INSTALL) -m 755 src/usr/bin/systemdock $(PREFIX)/bin/
	$(INSTALL) -m 644 src/usr/share/systemdock/templates/* $(DATADIR)/systemdock/templates/
	$(INSTALL) -m 644 src/etc/systemdock/config.yaml $(SYSCONFDIR)/systemdock/


uninstall:
	$(RM) $(PREFIX)/bin/systemdock
	$(RM) $(DATADIR)/systemdock
	$(RM) $(SYSCONFDIR)/systemdock/config.yaml

rpm:
	$(TAR) \
		cvfz $(TMPDIR)/systemdock.tar.gz \
		--transform 's,^,systemdock/,' \
	       	--exclude=.git \
		--exclude=.gitignore \
		--exclude='*.swp' \
		--exclude=.rpmbuild \
		--exclude=systemdock.tar.gz \
		./
	mkdir -p .rpmbuild/SPEC .rpmbuild/SOURCES .rpmbuild/SRPMS .rpmbuild/RPMS .rpmbuild/BUILD .rpmbuild/BUILDROOT
	mv $(TMPDIR)/systemdock.tar.gz .rpmbuild/SOURCES
	$(RPMBUILD) -tb --define "_topdir $(CURRENT_DIR)/.rpmbuild" .rpmbuild/SOURCES/systemdock.tar.gz
	$(RPMBUILD) -ta --define "_topdir $(CURRENT_DIR)/.rpmbuild" .rpmbuild/SOURCES/systemdock.tar.gz

install-rpm: rpm
	$(PKG_MGR) install -y .rpmbuild/RPMS/noarch/systemdock*

uninstall-rpm:
	$(PKG_MGR) remove -y systemdock || :

reinstall-rpm: uninstall-rpm install-rpm 

clean:
	$(RM) .rpmbuild
