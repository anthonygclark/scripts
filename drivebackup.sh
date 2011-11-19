#!/bin/sh
# Simple partition backup
# Written by Sam B.

srcdrv=/dev/sda
outdir=/media/Compressed_/backup/lenovo-s10-2/
mkdir -p $outdir

sfdisk -d $srcdrv > $outdir/partitions.sfdisk.dump
dd if="$srcdrv" bs=512 count=1 | gzip > $outdir/mbr.img.gz

for i in $srcdrv[0-9]; do
	p=${i#$srcdrv};
	echo "Backing up $srcdrv :: $p" >&2
	dd if="$srcdrv$p" bs=1024k | lzma > $outdir/part.${srcdrv#/dev/}$p.img.lzma

done

