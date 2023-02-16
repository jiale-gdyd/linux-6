#!/bin/sh

CUR_DIR=${PWD}
source ${CUR_DIR}/buildFuncDefine.sh
CPU_CORS=`grep -c processor /proc/cpuinfo`

# arm linaro
IMX6ULL_CROSS_TOOLCHAIN_VENDOR=linaro

IMX6ULL_CROSS_TOOLCHAIN_YEAR=2022
IMX6ULL_CROSS_TOOLCHAIN_MONTH=08

IMX6ULL_CROSS_TOOLCHAIN_GCC_MAJOR=12
IMX6ULL_CROSS_TOOLCHAIN_GCC_MINOR=1
IMX6ULL_CROSS_TOOLCHAIN_GCC_PATCH=1

IMX6ULL_CROSS_TOOLCHAIN_PATH=
IMX6ULL_CROSS_TOOLCHAIN_SUBFIX=
IMX6ULL_CROSS_TOOLCHAIN_PREFIX=

if [ "$IMX6ULL_CROSS_TOOLCHAIN_VENDOR" = "arm" ]; then
    IMX6ULL_CROSS_TOOLCHAIN_PREFIX=arm-none-linux-gnueabihf
    IMX6ULL_CROSS_TOOLCHAIN_SUBFIX=/opt/toolchain/gcc-arm-${IMX6ULL_CROSS_TOOLCHAIN_GCC_MAJOR}.${IMX6ULL_CROSS_TOOLCHAIN_GCC_MINOR}-${IMX6ULL_CROSS_TOOLCHAIN_YEAR}.${IMX6ULL_CROSS_TOOLCHAIN_MONTH}-x86_64
    IMX6ULL_CROSS_TOOLCHAIN_PATH=${IMX6ULL_CROSS_TOOLCHAIN_SUBFIX}-${IMX6ULL_CROSS_TOOLCHAIN_PREFIX}
else
    IMX6ULL_CROSS_TOOLCHAIN_PREFIX=arm-linux-gnueabihf
    IMX6ULL_CROSS_TOOLCHAIN_SUBFIX=/opt/toolchain/gcc-linaro-${IMX6ULL_CROSS_TOOLCHAIN_GCC_MAJOR}.${IMX6ULL_CROSS_TOOLCHAIN_GCC_MINOR}.${IMX6ULL_CROSS_TOOLCHAIN_GCC_PATCH}-${IMX6ULL_CROSS_TOOLCHAIN_YEAR}.${IMX6ULL_CROSS_TOOLCHAIN_MONTH}-x86_64
    IMX6ULL_CROSS_TOOLCHAIN_PATH=${IMX6ULL_CROSS_TOOLCHAIN_SUBFIX}_${IMX6ULL_CROSS_TOOLCHAIN_PREFIX}
fi

LOGO_FILE=/mnt/f/winshare/logo-linux.png
IMX6ULL_DEFCONFIG=aure_imx_14x14_emmc_defconfig
IMX6ULL_CROSS_COMPILE=${IMX6ULL_CROSS_TOOLCHAIN_PATH}/bin/${IMX6ULL_CROSS_TOOLCHAIN_PREFIX}-

function clean()
{
    make ARCH=arm CROSS_COMPILE=${IMX6ULL_CROSS_COMPILE} distclean
}

function imx6ull_kernel()
{
    make ARCH=arm CROSS_COMPILE=${IMX6ULL_CROSS_COMPILE} ${IMX6ULL_DEFCONFIG}
    if [ $? -ne 0 ]; then
        error_exit "make ${IMX6ULL_DEFCONFIG}失败"
    fi

    if confirm "是否需要打开menuconfig进行参数配置?"; then
        make ARCH=arm CROSS_COMPILE=${IMX6ULL_CROSS_COMPILE} menuconfig
    fi

    print_info "开始构建内核"

    make ARCH=arm CROSS_COMPILE=${IMX6ULL_CROSS_COMPILE} -j${CPU_CORS}
    if [ $? -ne 0 ]; then
        error_exit "构建内核失败"
    fi

    print_info "内核构建完成"
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
    print_logo

    echo "Usage: $0 [OPTION]"
    echo "[OPTION]:"
    echo "==========================================="
    echo "  -  clean            清理工程编译信息"
    echo "  -  logo             制作自定义开机logo"
    echo "  -  imx6ull_kernel   开始构建imx6ull内核目标"
    echo "==========================================="
}

if [ -z $1 ]; then
    help
else
    $1
fi
