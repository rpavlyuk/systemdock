
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR := $(notdir $(patsubst %/,%,$(dir $(MKFILE_PATH))))

PREFIX = $(DESTDIR)/usr
SYSCONFDIR=$(DESTDIR)/etc
DATADIR=$(PREFIX)/share
SYSTEMD_DIR=$(PREFIX)/lib/systemd/system
INSTALL = $(shell which install) -c
MKDIR = $(shell which install) -c -d
RM = rm -rf
TAR = /usr/bin/tar
TMPDIR := $(shell mktemp -d)
CURRENT_DIR := $(shell pwd)
PKG_MGR := $(shell which yum)
RPMBUILD := $(shell which rpmbuild)
PYTHON3 = $(shell which python3)

VENV_DIR  ?= .venv
VENV_BIN   = $(VENV_DIR)/bin
VPYTHON     = $(VENV_BIN)/python
PIP        = $(VENV_BIN)/pip
VPACKAGES   = pip setuptools wheel docker PyYAML

VAGRANT ?= $(shell which vagrant)
DEV_PATH ?= /srv/systemdock

.PHONY: all venv install uninstall rpm install-rpm uninstall-rpm reinstall-rpm clean dev-up dev-provision dev-sync dev-ssh dev-halt dev-destroy install-dev

venv:
	$(PYTHON3) -m venv "$(VENV_DIR)"
	"$(VPYTHON)" -m pip install --upgrade $(VPACKAGES)

clean-venv:
	rm -rf "$(VENV_DIR)"


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

reinstall-rpm: clean uninstall-rpm install-rpm 

clean: clean-venv
	$(RM) .rpmbuild

dev-init:
	$(VAGRANT) init

dev-up:
	$(VAGRANT) up --provision

dev-provision:
	$(VAGRANT) provision

# Push current repo state into the VM rsync folder
dev-sync:
	$(VAGRANT) rsync

dev-ssh:
	$(VAGRANT) ssh

dev-cmd:
	$(VAGRANT) ssh -c "$(CMD)"

dev-push:
	$(VAGRANT) rsync && $(VAGRANT) ssh -c "cd /srv/systemdock && sudo make install"
	
dev-halt:
	$(VAGRANT) halt

dev-destroy:
	$(VAGRANT) destroy -f

# Build+install inside the VM root FS (DESTDIR empty => install into /)
# Uses your existing 'install' target; runs from the synced folder.
install-dev: dev-up dev-sync
	$(VAGRANT) ssh -c 'cd $(DEV_PATH) && sudo make install && sudo systemctl daemon-reload || true'
	@echo "Installed SystemDock into the VM. You can now test it inside the guest."
