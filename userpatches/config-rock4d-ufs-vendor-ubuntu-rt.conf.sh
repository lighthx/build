#!/usr/bin/env bash

BOARD="radxa-rock-4d"
BRANCH="vendor"
RELEASE="noble"

BUILD_DESKTOP="no"
BUILD_MINIMAL="yes"
NETWORKING_STACK="network-manager"
KERNEL_CONFIGURE="no"
UBOOT_CONFIGURE="no"

CPUFREQUTILS_ENABLE="true"
GOVERNOR="performance"

EXTRAWIFI="yes"
KERNEL_BTF="no"
SHARE_LOG="yes"

if [[ -n "${ENABLE_EXTENSIONS}" ]]; then
	ENABLE_EXTENSIONS+=","
fi
ENABLE_EXTENSIONS+="ufs,rock4d-rt-kernel"
