function extension_prepare_config__690_rock4d_rt_kernel_suffix() {
	EXTRA_IMAGE_SUFFIXES+=("-rt")
}

function custom_kernel_config__690_rock4d_rt_kernel_guard() {
	if [[ "${BRANCH}" != "edge" && "${BRANCH}" != "vendor" ]]; then
		return 0
	fi

	if [[ ! -f .config ]]; then
		return 0
	fi

	if ! grep -q "select ARCH_SUPPORTS_RT" arch/arm64/Kconfig; then
		display_alert "${EXTENSION}" "patching arch/arm64/Kconfig to select ARCH_SUPPORTS_RT" "info"
		python3 - <<'PY'
from pathlib import Path

path = Path("arch/arm64/Kconfig")
text = path.read_text()
needle = "\tselect ARCH_SUPPORTS_DEBUG_PAGEALLOC\n"
replacement = needle + "\tselect ARCH_SUPPORTS_RT\n"

if "select ARCH_SUPPORTS_RT" not in text:
    if needle not in text:
        raise SystemExit("rock4d-rt-kernel: failed to find insertion point for ARCH_SUPPORTS_RT in arch/arm64/Kconfig")
    text = text.replace(needle, replacement, 1)
    path.write_text(text)
PY
	fi

	if ! grep -q "select ARCH_SUPPORTS_RT" arch/arm64/Kconfig; then
		exit_with_error "${EXTENSION}: PREEMPT_RT requested, but arch/arm64/Kconfig still does not enable ARCH_SUPPORTS_RT."
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
