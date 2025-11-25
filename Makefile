all:

install:
	mkdir -p "$(DESTDIR)/opt/45drives/tools"
	mkdir -p "$(DESTDIR)/opt/45drives/ubm"
	mkdir -p "$(DESTDIR)/etc/45drives/server_info"
	mkdir -p "$(DESTDIR)/opt/45drives/dalias"
	mkdir -p "$(DESTDIR)/usr/bin"
	mkdir -p "$(DESTDIR)/usr/lib/udev/rules.d"
	cp -a tools/* "$(DESTDIR)/opt/45drives/tools"
	cp -a dalias/* "$(DESTDIR)/opt/45drives/dalias"
	install -m 755 -t "$(DESTDIR)/opt/45drives/ubm" \
		ubm/id_disk \
		ubm/patch_vdev_id_conf \
		ubm/on_enclosure_add \
		ubm/on_enclosure_remove \
		ubm/slot_led_ctrl \
		ubm/ubm_func_wrapper.sh \
		ubm/ubm_override_alias_style
	install -m 644 -t "$(DESTDIR)/opt/45drives/ubm" \
		ubm/ubm_funcs.sh \
		ubm/slot_name_map.txt
	install -m 644 -t "$(DESTDIR)/usr/lib/udev/rules.d" \
		udev/61-flash-io-scheduler.rules \
		udev/67-ubm.rules \
		udev/68-0-custom-aliases.rules \
		udev/68-vdev.rules
	install -m 644 -t "$(DESTDIR)/opt/45drives/tools" \
		udev/68-vdev.rules
	install -D -m 644 tools/zfs-scrub.timer "$(DESTDIR)"/etc/systemd/system/zfs-scrub.timer
	install -D -m 644 tools/zfs-scrub.service "$(DESTDIR)"/etc/systemd/system/zfs-scrub.service

ifdef TOOLS_VERSION
	echo $(TOOLS_VERSION) > "$(DESTDIR)/etc/45drives/server_info/tools_version"
endif
	ln -sf /opt/45drives/tools/cephfs-dir-stats "$(DESTDIR)/usr/bin/cephfs-dir-stats"
	ln -sf /opt/45drives/tools/dmap "$(DESTDIR)/usr/bin/dmap"
	ln -sf /opt/45drives/tools/findosd "$(DESTDIR)/usr/bin/findosd"
	ln -sf /opt/45drives/tools/lsdev "$(DESTDIR)/usr/bin/lsdev"
	ln -sf /opt/45drives/tools/server_identifier "$(DESTDIR)/usr/bin/server_identifier"
	ln -sf /opt/45drives/tools/zcreate "$(DESTDIR)/usr/bin/zcreate"
	ln -sf /opt/45drives/dalias/dalias "$(DESTDIR)/usr/bin/dalias"
	ln -sf /opt/45drives/tools/wipedev "$(DESTDIR)/usr/bin/wipedev"
	ln -sf /opt/45drives/ubm/slot_led_ctrl "$(DESTDIR)/usr/bin/slot_led_ctrl"
	ln -sf /opt/45drives/tools/slot_speeds "$(DESTDIR)/usr/bin/slot_speeds"
	ln -sf /opt/45drives/tools/ubm_override_alias_style "$(DESTDIR)/usr/bin/ubm_override_alias_style"
	for i in \
		slot_num_to_slot_name \
		slot_name_to_slot_num \
		block_dev_to_slot_num \
		block_dev_to_slot_name \
		slot_num_to_block_dev \
		slot_name_to_block_dev \
		all_slot_nums \
		all_slot_names \
		check_ubm_func_support \
		; do ln -sf /opt/45drives/ubm/ubm_func_wrapper.sh "$(DESTDIR)/usr/bin/$$i"; done

uninstall:
	rm -rf "$(DESTDIR)/etc/45drives/server_info"
	rm -rf "$(DESTDIR)/opt/45drives/tools"
	rm -rf "$(DESTDIR)/opt/45drives/ubm"
	rm -f "$(DESTDIR)/usr/bin/cephfs-dir-stats"
	rm -f "$(DESTDIR)/usr/bin/dmap"
	rm -f "$(DESTDIR)/usr/bin/findosd"
	rm -f "$(DESTDIR)/usr/bin/lsdev"
	rm -f "$(DESTDIR)/usr/bin/server_identifier"
	rm -f "$(DESTDIR)/usr/bin/zcreate"
	rm -f "$(DESTDIR)/usr/lib/udev/rules.d/{61-flash-io-scheduler.rules,67-ubm.rules}"
	rm -f "$(DESTDIR)/usr/bin/dalias"
	rm -f "$(DESTDIR)/usr/bin/wipedev"
	rm -f "$(DESTDIR)/usr/bin/slot_led_ctrl"
	rm -f "$(DESTDIR)/usr/bin/slot_speeds"
	for i in \
		slot_num_to_slot_name \
		slot_name_to_slot_num \
		block_dev_to_slot_num \
		block_dev_to_slot_name \
		slot_num_to_block_dev \
		slot_name_to_block_dev \
		all_slot_nums \
		all_slot_names \
		check_ubm_func_support \
		; do rm -f "$(DESTDIR)/usr/bin/$$i"; done
