#!/bin/bash
# Script to build a barebones kernel and root filesystem for ARM architecture
# Author: Your Name

set -e
set -u

# Default output directory
OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

# Handle input arguments for OUTDIR
if [ $# -lt 1 ]
then
    echo "Using default directory ${OUTDIR} for output"
else
    OUTDIR=$1
    echo "Using passed directory ${OUTDIR} for output"
fi

# Ensure OUTDIR exists, create it if not
mkdir -p ${OUTDIR}
if [ ! -d "${OUTDIR}" ]; then
    echo "Failed to create the output directory ${OUTDIR}"
    exit 1
fi

# Clone the Linux kernel source if it doesn't exist
cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux" ]; then
    echo "Cloning the Linux kernel source from ${KERNEL_REPO} into ${OUTDIR}"
    git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi

# Build the kernel if it hasn't been built already
if [ ! -e ${OUTDIR}/linux/arch/${ARCH}/boot/Image ]; then
    cd linux
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    echo "Configuring the kernel for ARM64 architecture"
    make ARCH=${ARCH} defconfig

    # Optionally, configure kernel with menuconfig here (you can add custom configs)
    # make ARCH=${ARCH} menuconfig

    echo "Building the kernel"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc)

    # Copy the kernel Image to OUTDIR
    cp ${OUTDIR}/linux/arch/${ARCH}/boot/Image ${OUTDIR}/kernel.img
fi

echo "Adding the Image in outdir"

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
    echo "Deleting existing rootfs directory at ${OUTDIR}/rootfs"
    sudo rm -rf ${OUTDIR}/rootfs
fi

# Create necessary base directories
echo "Creating base directories for rootfs"
mkdir -p ${OUTDIR}/rootfs/{bin,dev,etc,home,lib,lib64,mnt,opt,proc,root,sbin,sys,tmp,usr,var}

# Clone busybox repository if not already cloned
cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
    echo "Cloning busybox repository"
    git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}

    # Configure busybox
    echo "Configuring busybox"
    make defconfig
else
    cd busybox
fi

# Build and install busybox
echo "Building and installing busybox"
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc)
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

# Copy busybox binaries to rootfs/bin
echo "Copying busybox binaries to rootfs"
cp -a ${OUTDIR}/busybox/_install/* ${OUTDIR}/rootfs/

# Add library dependencies to rootfs
echo "Adding library dependencies to rootfs"
for lib in $(ldd ${OUTDIR}/rootfs/bin/busybox | awk '{print $3}' | grep -v '('); do
    cp -v $lib ${OUTDIR}/rootfs/lib/
done

# Make device nodes
echo "Making device nodes"
cd ${OUTDIR}/rootfs
sudo mknod -m 666 dev/console c 5 1
sudo mknod -m 666 dev/null c 1 3

# Build the writer utility
echo "Building the writer utility"
cd "$FINDER_APP_DIR"
make CROSS_COMPILE=${CROSS_COMPILE}

# Copy the finder related scripts and executables to rootfs
echo "Copying finder scripts and executables to rootfs"
mkdir -p ${OUTDIR}/rootfs/home
cp -a ${FINDER_APP_DIR}/writer ${OUTDIR}/rootfs/home/
cp -a ${FINDER_APP_DIR}/finder.sh ${OUTDIR}/rootfs/home/
cp -a ${FINDER_APP_DIR}/conf/username.txt ${OUTDIR}/rootfs/home/
cp -a ${FINDER_APP_DIR}/conf/assignment.txt ${OUTDIR}/rootfs/home/
cp -a ${FINDER_APP_DIR}/finder-test.sh ${OUTDIR}/rootfs/home/

# Set correct ownership
echo "Chowning root directory"
sudo chown -R root:root ${OUTDIR}/rootfs

# Create initramfs
echo "Creating initramfs.cpio.gz"
cd ${OUTDIR}/rootfs
find . | cpio -o -H newc | gzip > ${OUTDIR}/initramfs.cpio.gz

# Boot with QEMU
echo "Booting with QEMU"
qemu-system-${ARCH} -kernel ${OUTDIR}/kernel.img -initrd ${OUTDIR}/initramfs.cpio.gz -append "root=/dev/ram" -nographic

