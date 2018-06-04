#!/bin/bash


#For Time Calculation
BUILD_START=$(date +"%s")

kernel_version="Stable"
kernel_name="Firangistan"
device_name="Z2_Plus"
zip_name="$kernel_name-$device_name-$kernel_version-$(date +"%Y%m%d")-$(date +"%H%M%S").zip"


export HOME="/home/thesooberman"
export CONFIG_FILE="z2_plus_defconfig"
export ARCH="arm64"
export KBUILD_BUILD_USER="thesooberman"
export KBUILD_BUILD_HOST="abyss"
export TOOLCHAIN_PATH="${HOME}/Android/kernel/linaro-7.2"
export CROSS_COMPILE=$TOOLCHAIN_PATH/bin/aarch64-linux-gnu-
export CONFIG_ABS_PATH="arch/${ARCH}/configs/${CONFIG_FILE}"
export objdir="$HOME/Android/kernel/obj"
export sourcedir="$HOME/Android/kernel/zuk"
export anykernel="$HOME/Android/kernel/anykernel"

compile() {
  make O=$objdir  $CONFIG_FILE -j8
  make O=$objdir -j8
}
clean() {
  make O=$objdir CROSS_COMPILE=${CROSS_COMPILE}  $CONFIG_FILE -j8
  make O=$objdir mrproper
  make O=$objdir clean
}
module_stock(){
  rm -rf $anykernel/modules/
  mkdir $anykernel/modules
  find $objdir -name '*.ko' -exec cp -av {} $anykernel/modules/ \;
  # strip modules
  ${CROSS_COMPILE}strip --strip-unneeded $anykernel/modules/*
  cp -rf $objdir/arch/$ARCH/boot/Image.gz-dtb $anykernel/zImage
}
delete_zip(){
  cd $anykernel
  find . -name "*.zip" -type f
  find . -name "*.zip" -type f -delete
}
build_package(){
  zip -r9 UPDATE-AnyKernel2.zip * -x README UPDATE-AnyKernel2.zip
}
make_name(){
  mv UPDATE-AnyKernel2.zip $zip_name
}
turn_back(){
cd $sourcedir
}

clean
compile
module_stock
delete_zip
build_package
make_name
turn_back
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
