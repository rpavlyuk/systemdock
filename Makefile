PREFIX = $(DESTDIR)/usr
SYSCONFDIR=$(DESTDIR)/etc
DATADIR=$(PREFIX)/share
SYSTEMD_DIR=$(PREFIX)/lib/systemd/system
INSTALL = /bin/install -c
MKDIR = /bin/install -c -d
RM = rm -rf

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

