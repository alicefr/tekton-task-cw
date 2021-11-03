#!/bin/bash

IMAGE=$1
ENCRYPT_IMAGE=$2

OUTPUT=disk.img
CONT=temporary-container
OUTDIR=/tmp/output
DISK=$OUTDIR/disk.img

buildah rm $CONT

set -xe 

mkdir -p $OUTDIR
buildah from --name $CONT $IMAGE
dir=$(buildah mount $CONT)
cd $dir
find . | cpio -o -c -R root:root | gzip -9 >  $DISK
buildah rm $CONT

# TODO encrypt the image with the LUKS passphrase

# TODO generate fake entrypoint

# Create final image
buildah from --name $CONT scratch 
buildah copy $CONT $DISK /
# TODO copy fake entrypoint in the final image
buildah commit --rm $CONT $ENCRYPT_IMAGE
