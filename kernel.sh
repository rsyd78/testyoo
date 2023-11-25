#!/bin/bash

echo -e "==========================="
echo -e "= START COMPILING KERNEL  ="
echo -e "==========================="
bold=$(tput bold)
normal=$(tput sgr0)

# Scrip option
while (( ${#} )); do
    case ${1} in
        "-Z"|"--zip") ZIP=true ;;
    esac
    shift
done
[[ -z ${ZIP} ]] && { echo "${bold}LOADING-_-....${normal}"; }

export KERNELDIR="/workspace/tmp/krnl" 
export USE_CCACHE=1
export CCACHE_DIR="/workspace/.ccache"
DEFCONFIG="beryllium_defconfig"
export KBUILD_BUILD_USER=Unknown44
export KERNELNAME="MINTKernel" 
export SRCDIR="${KERNELDIR}";
export OUTDIR="${KERNELDIR}/out"
export ANYKERNEL="${KERNELDIR}/Anykernel3"
export ARCH="arm64"
export SUBARCH="arm64"
export ZIP_DIR="${KERNELDIR}/files";
export IMAGE="${OUTDIR}/arch/${ARCH}/boot/Image.gz-dtb";
# export KBUILD_BUILD_HOST=
TC_DIR="/workspace/proton-clang"
export PATH="$TC_DIR/bin:$PATH"

if [[ $1 = "-r" || $1 = "--regen" ]]; then
make O=out ARCH=arm64 $DEFCONFIG savedefconfig
cp out/defconfig arch/arm64/configs/$DEFCONFIG
exit
fi

if [[ $1 = "-c" || $1 = "--clean" ]]; then
rm -rf out
fi

mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG


make -j$(nproc --all) O=out ARCH=arm64 CC=clang LD=ld.lld AR=llvm-ar AS=llvm-as NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- 2>&1 | tee log.txt

    echo -e "==========================="
    echo -e "   COMPILE KERNEL COMPLETE "
    echo -e "==========================="
    
# Make ZIP using AnyKernel
# ================
echo -e "Copying kernel image";
cp -v "${IMAGE}" "${ANYKERNEL}/";
cd -;
cd ${ANYKERNEL};
zip -r9 ${FINAL_ZIP} *;
cd -;
# echo -e "zip boot and dtbo"
# cd out/arch/arm64/boot && zip kernel.zip Image.gz-dtb && rm -rf Image.gz-dtb && mv kernel.zip /w* && cd /w* && ls

if [[ ":v" ]]; then
exit
fi
