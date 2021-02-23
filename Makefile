all:

install:
	mkdir -p $(DESTDIR)/opt/45drives/tools
	mkdir -p $(DESTDIR)/etc/45drives/server_info
	mkdir -p $(DESTDIR)/usr/bin
	cp -a src/fakeroot/opt/45drives/tools/* $(DESTDIR)/opt/45drives/tools
	cp -a src/fakeroot/etc/45drives/server_info/tools_version $(DESTDIR)/etc/45drives/server_info/tools_version
	cp -a src/fakeroot/usr/bin/cephfs-dir-stats $(DESTDIR)/usr/bin/cephfs-dir-stats
	cp -a src/fakeroot/usr/bin/dmap $(DESTDIR)/usr/bin/dmap
	cp -a src/fakeroot/usr/bin/findosd $(DESTDIR)/usr/bin/findosd
	cp -a src/fakeroot/usr/bin/lsdev $(DESTDIR)/usr/bin/lsdev
	cp -a src/fakeroot/usr/bin/server_identifier $(DESTDIR)/usr/bin/server_identifier
	cp -a src/fakeroot/usr/bin/zcreate $(DESTDIR)/usr/bin/zcreate

uninstall:
	rm -rf $(DESTDIR)/etc/45drives/server_info
	rm -rf $(DESTDIR)/opt/45drives/tools
	rm -f $(DESTDIR)/usr/bin/cephfs-dir-stats
	rm -f $(DESTDIR)/usr/bin/dmap
	rm -f $(DESTDIR)/usr/bin/findosd
	rm -f $(DESTDIR)/usr/bin/lsdev
	rm -f $(DESTDIR)/usr/bin/server_identifier
	rm -f $(DESTDIR)/usr/bin/zcreate

