#!/usr/bin/env bash

BOARD="radxa-rock-4d"
BRANCH="edge"
RELEASE="noble"

BUILD_DESKTOP="no"
BUILD_MINIMAL="yes"
KERNEL_CONFIGURE="no"
UBOOT_CONFIGURE="no"
SHARE_LOG="yes"

if [[ -n "${ENABLE_EXTENSIONS}" ]]; then
	ENABLE_EXTENSIONS+=","
fi
ENABLE_EXTENSIONS+="ufs,rock4d-rt-kernel"
