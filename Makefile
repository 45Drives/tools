all:

install:
	mkdir -p $(DESTDIR)/opt/45drives/tools
	mkdir -p $(DESTDIR)/etc/45drives/server_info
	mkdir -p $(DESTDIR)/usr/bin
	cp -a src/fakeroot/opt/45drives/tools/* $(DESTDIR)/opt/45drives/tools
ifdef($(TOOLS_VERSION))
	echo $(TOOLS_VERSION) > $(DESTDIR)/etc/45drives/server_info/tools_version
endif
	ln -sf /opt/45drives/tools/cephfs-dir-stats $(DESTDIR)/usr/bin/cephfs-dir-stats
	ln -sf /opt/45drives/tools/dmap $(DESTDIR)/usr/bin/dmap
	ln -sf /opt/45drives/tools/findosd $(DESTDIR)/usr/bin/findosd
	ln -sf /opt/45drives/tools/lsdev $(DESTDIR)/usr/bin/lsdev
	ln -sf /opt/45drives/tools/server_identifier $(DESTDIR)/usr/bin/server_identifier
	ln -sf /opt/45drives/tools/zcreate $(DESTDIR)/usr/bin/zcreate

uninstall:
	rm -rf $(DESTDIR)/etc/45drives/server_info
	rm -rf $(DESTDIR)/opt/45drives/tools
	rm -f $(DESTDIR)/usr/bin/cephfs-dir-stats
	rm -f $(DESTDIR)/usr/bin/dmap
	rm -f $(DESTDIR)/usr/bin/findosd
	rm -f $(DESTDIR)/usr/bin/lsdev
	rm -f $(DESTDIR)/usr/bin/server_identifier
	rm -f $(DESTDIR)/usr/bin/zcreate

