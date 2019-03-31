# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=blueline
device.name2=crosshatch
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. $TMPDIR/tools/ak2-core.sh;


## AnyKernel install
ui_print "  • Unpacking image"
dump_boot;

# begin ramdisk changes

rm -fr $ramdisk/overlay

patch_cmdline "skip_override" ""

decompressed_image=$TMPDIR/kernel/Image
compressed_image=$decompressed_image.lz4
if [ -d $ramdisk/.backup ]; then
  ui_print "  • Patching kernel to preserve Magisk"

  # Hex patch: "skip_initramfs" -> "want_initramfs" as Magisk does
  $bin/magiskboot --decompress $compressed_image $decompressed_image
  $bin/magiskboot --hexpatch $decompressed_image 736B69705F696E697472616D667300 77616E745F696E697472616D667300
  $bin/magiskboot --compress=lz4 $decompressed_image $compressed_image
fi

cat $compressed_image $TMPDIR/dtbs/*.dtb > $TMPDIR/Image.lz4-dtb
rm -fr $TMPDIR/kernel $TMPDIR/dtbs

# Clean up files from other kernels
mountpoint -q /data && {
  rm -f /data/adb/magisk_simple/vendor/etc/powerhint.json
  rm -f /data/adb/service.d/95-proton.sh
  rm -f /data/adb/dtbo_a.orig.img /data/adb/dtbo_b.orig.img
}

# end ramdisk changes

write_boot;

## end install

