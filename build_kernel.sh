#!/bin/sh

CPU_CORS=`grep -c processor /proc/cpuinfo`

IMX6ULL_CROSS_TOOLCHAIN_PREFIX=arm-none-linux-gnueabihf
IMX6ULL_CROSS_TOOLCHAIN_SUBFIX=/opt/toolchain/gcc-arm-10.3-2021.07-x86_64
IMX6ULL_CROSS_TOOLCHAIN_PATH=${CROSS_TOOLCHAIN_SUBFIX}-${CROSS_TOOLCHAIN_PREFIX}

LOGO_FILE=/mnt/f/winshare/logo-linux.png
IMX6ULL_DEFCONFIG=aure_imx_14x14_emmc_rgblcd43_800x480_defconfig

function clean()
{
    make ARCH=arm CROSS_COMPILE=${CROSS_TOOLCHAIN_PATH}/bin/${CROSS_TOOLCHAIN_PREFIX}- distclean
}

function imx6ull_kernel()
{
    make ARCH=arm CROSS_COMPILE=${CROSS_TOOLCHAIN_PATH}/bin/${CROSS_TOOLCHAIN_PREFIX}- ${IMX6ULL_DEFCONFIG}
    if [ $? -ne 0 ]; then
        echo "make ${IMX6ULL_DEFCONFIG}失败"
        exit 127
    fi

    make ARCH=arm CROSS_COMPILE=${CROSS_TOOLCHAIN_PATH}/bin/${CROSS_TOOLCHAIN_PREFIX}- -j${CPU_CORS}
    if [ $? -ne 0 ]; then
        echo "构建内核失败"
        exit 127
    fi

    echo "内核构建完成"
}

function logo()
{
	if [ -f "drivers/video/logo/logo_linux_clut224.ppm" ]; then
		mv drivers/video/logo/logo_linux_clut224.ppm drivers/video/logo/logo_linux_clut224_backup.ppm
	fi

	logo=${LOGO_FILE}

	pngtopnm $logo > logo-linux.pnm
	pnmquant 224 logo-linux.pnm > logo-linux224.pnm
	pnmtoplainpnm logo-linux224.pnm > logo_linux_clut224.ppm

	if [ -f "logo-linux.pnm" ]; then
		rm logo-linux.pnm
	fi

	if [ -f "logo-linux224.pnm" ]; then
		rm logo-linux224.pnm
	fi

	if [ -f "logo_linux_clut224.ppm" ]; then
		mv logo_linux_clut224.ppm drivers/video/logo/
	fi
}

function help()
{
    echo "Usage: $0 [OPTION]"
    echo "[OPTION]:"
    echo "==========================================="
    echo "  -  clean            清理工程编译信息"
    echo "  -  logo             制作自定义开机logo"
    echo "  -  imx6ull_kernel   开始构建内核目标"
    echo "==========================================="
}

if [ -z $1 ]; then
    help
else
    $1
fi
