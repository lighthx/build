function custom_kernel_config__690_rock4d_rt_kernel_guard() {
	if [[ "${BRANCH}" != "edge" && "${BRANCH}" != "vendor" ]]; then
		return 0
	fi

	if [[ ! -f .config ]]; then
		return 0
	fi

	if ! grep -q "select ARCH_SUPPORTS_RT" arch/arm64/Kconfig; then
		exit_with_error "${EXTENSION}: PREEMPT_RT requested, but this kernel tree does not enable ARCH_SUPPORTS_RT for arm64. The build would silently fall back to a non-RT kernel."
	fi
}

function custom_kernel_config__700_rock4d_rt_kernel() {
	if [[ "${BRANCH}" != "edge" && "${BRANCH}" != "vendor" ]]; then
		return 0
	fi

	display_alert "${EXTENSION}" "enabling RT kernel options" "info"

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
