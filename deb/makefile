bindir = /usr/bin
version = 1.7.5

all:
	: # do nothing

install:
	rm -rf $(DESTDIR)
	mkdir -p  $(DESTDIR)
	mkdir -p $(DESTDIR)$(bindir)
	cp -a etc/ $(DESTDIR)
	cp -a etc/ $(DESTDIR)
	mkdir -p $(DESTDIR)/etc/45drives/server_info
	echo $(version) > $(DESTDIR)/etc/45drives/server_info/tools_version
	cd opt/45drives/tools/
	ln -sf /opt/45drives/tools/lsdev $(DESTDIR)$(bindir)
	ln -sf /opt/45drives/tools/dmap $(DESTDIR)$(bindir)
	ln -sf /opt/45drives/tools/findosd $(DESTDIR)$(bindir)
	ln -sf /opt/45drives/tools/zcreate $(DESTDIR)$(bindir)
	ln -sf /opt/45drives/tools/cephfs-dir-stats $(DESTDIR)$(bindir)
	ln -sf /opt/45drives/tools/server_identifier $(DESTDIR)$(bindir)
	cd -

clean:
	rm -rf $(DESTDIR)

distclean: clean

uninstall:
	rm -rf /etc/45drives/server_info
	rmdir /etc/45drives > /dev/null 2>&1 || true
	rm -rf /opt/45drives/tools
	rmdir /opt/45drives > /dev/null 2>&1 || true

.PHONY: all install clean distclean uninstall