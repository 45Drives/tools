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
        mkdir -p $(DESTDIR)/etc/45drives/server_info/tools_version
        echo $(version) > $(DESTDIR)/etc/45drives/server_info/tools_version
        pushd opt/45drives/tools/
                for i in lsdev dmap findosd zcreate cephfs-dir-stats server_identifier;
                do
                        ln -sf /opt/45drives/tools/$i $(DESTDIR)$(bindir)
                done
        popd

clean:
        rm -rf $(DESTDIR)

distclean: clean

uninstall:
        rm -rf /etc/45drives/server_info
        rmdir /etc/45drives > /dev/null 2>&1 || true
        rm -rf /opt/45drives/tools
        rmdir /opt/45drives > /dev/null 2>&1 || true

.PHONY: all install clean distclean uninstall