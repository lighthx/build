function extension_prepare_config__700_rock4d_audio_player_packages() {
	display_alert "${EXTENSION}" "adding audio player package set" "info"

	add_packages_to_image \
		alsa-utils \
		avahi-daemon \
		bluetooth \
		bluez \
		cpufrequtils \
		iw \
		mpc \
		mpd \
		rfkill
}

function custom_kernel_config__700_rock4d_audio_player_rt() {
	if [[ "${BRANCH}" != "edge" && "${BRANCH}" != "vendor" ]]; then
		return 0
	fi

	display_alert "${EXTENSION}" "enabling low-latency audio kernel options" "info"

	opts_n+=("HZ_250")
	opts_n+=("HZ_300")
	opts_n+=("PREEMPT_NONE")
	opts_n+=("PREEMPT_VOLUNTARY")
	opts_n+=("PREEMPT_DYNAMIC")
	opts_n+=("CPU_FREQ_DEFAULT_GOV_ONDEMAND")

	opts_y+=("HZ_1000")
	opts_y+=("PREEMPT_RT")
	opts_y+=("SND_HRTIMER")
	opts_y+=("CPU_FREQ_DEFAULT_GOV_PERFORMANCE")
	opts_y+=("CPU_FREQ_GOV_PERFORMANCE")

	opts_val["HZ"]="1000"
}

function post_family_tweaks__700_rock4d_audio_player_tune_image() {
	display_alert "${EXTENSION}" "applying audio player runtime tuning" "info"

	mkdir -p "${SDCARD}/etc/modules-load.d"
	mkdir -p "${SDCARD}/etc/modprobe.d"
	mkdir -p "${SDCARD}/etc/security/limits.d"
	mkdir -p "${SDCARD}/etc/sysctl.d"
	mkdir -p "${SDCARD}/etc/systemd/system/mpd.service.d"

	cat > "${SDCARD}/etc/modules-load.d/99-rock4d-audio-player.conf" <<-'EOF'
		hidp
		rfcomm
		bnep
		snd_seq
		snd_timer
		snd_hrtimer
		snd_usb_audio
	EOF

	cat > "${SDCARD}/etc/modprobe.d/99-rock4d-audio-player.conf" <<-'EOF'
		options snd_usb_audio nrpacks=1
	EOF

	cat > "${SDCARD}/etc/security/limits.d/95-audio-realtime.conf" <<-'EOF'
		@audio - rtprio 95
		@audio - memlock unlimited
		@audio - nice -19
		root - rtprio 95
		root - memlock unlimited
		root - nice -19
	EOF

	cat > "${SDCARD}/etc/sysctl.d/99-rock4d-audio-player.conf" <<-'EOF'
		kernel.sched_rt_runtime_us=-1
		vm.swappiness=10
	EOF

	cat > "${SDCARD}/etc/systemd/system/mpd.service.d/override.conf" <<-'EOF'
		[Service]
		CPUSchedulingPolicy=rr
		CPUSchedulingPriority=70
		IOSchedulingClass=realtime
		IOSchedulingPriority=0
		LimitRTPRIO=95
		LimitMEMLOCK=infinity
		Nice=-11
	EOF

	if [[ -d "${SRC}/packages/bsp/aic8800" ]]; then
		display_alert "${EXTENSION}" "installing AIC8800 bluetooth helper" "info"
		install -D -m 0755 "${SRC}/packages/bsp/aic8800/aic-bluetooth" "${SDCARD}/usr/bin/aic-bluetooth"
		install -D -m 0644 "${SRC}/packages/bsp/aic8800/aic-bluetooth.service" "${SDCARD}/usr/lib/systemd/system/aic-bluetooth.service"
	fi

	if [[ -f "${SDCARD}/boot/armbianEnv.txt" ]]; then
		if grep -q '^extraargs=' "${SDCARD}/boot/armbianEnv.txt"; then
			if ! grep -q '^extraargs=.*threadirqs' "${SDCARD}/boot/armbianEnv.txt"; then
				sed -i 's/^extraargs=\(.*\)$/extraargs=\1 threadirqs/' "${SDCARD}/boot/armbianEnv.txt"
			fi
		else
			echo 'extraargs=threadirqs' >> "${SDCARD}/boot/armbianEnv.txt"
		fi
	fi

	chroot_sdcard systemctl --no-reload enable avahi-daemon.service
	chroot_sdcard systemctl --no-reload enable bluetooth.service
	chroot_sdcard systemctl --no-reload enable NetworkManager.service
	chroot_sdcard systemctl --no-reload enable chrony.service
	chroot_sdcard systemctl --no-reload enable mpd.service

	if chroot_sdcard test -f /usr/lib/systemd/system/aic-bluetooth.service || chroot_sdcard test -f /etc/systemd/system/aic-bluetooth.service; then
		chroot_sdcard systemctl --no-reload enable aic-bluetooth.service
	fi

	if chroot_sdcard id -u mpd > /dev/null 2>&1; then
		chroot_sdcard usermod -a -G audio mpd || true
	fi
}
