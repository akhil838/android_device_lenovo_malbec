# TWRP device tree for Lenovo Idea Tab Pro Gen 2 (malbec)

TWRP 16.0 (TWRP-Test `twrp-16.0`, GUI2) for the Lenovo Idea Tab Pro Gen 2.

| | |
| --- | --- |
| Board / product | `malbec` (`fastboot getvar product`) |
| Model | TB390FU (ROW) |
| SoC | Snapdragon 8s Gen 4 (SM8735P), Qualcomm platform `sun` |
| Tested firmware | ZUI 18.0.10.425 (Android 16, kernel 6.6 GKI) |
| Recovery | dedicated A/B `recovery` partition, 100 MiB, header v4, ramdisk only |

## Status

Tested on device:

- Boot, display (portrait UI, 2190x3504) and touch
- `/data` decryption (FBE v2 + metadata encryption, wrapped keys) with no lock screen credential
- ADB, fastbootd, Qualcomm KeyMint/Gatekeeper/Weaver in recovery

Not yet tested: decryption with a PIN/pattern set, backup/restore, OTA flashing.

## Build

```shell
repo init --depth=1 -u https://github.com/TWRP-Test/platform_manifest_twrp_aosp.git -b twrp-16.0
repo sync
git -C bootable/recovery apply "$PWD/device/lenovo/malbec/patches/0001-recovery-wait-for-module-handler.patch"
```

Clone this repository into `device/lenovo/malbec`, then:

```shell
source build/envsetup.sh
lunch twrp_malbec
make recoveryimage
```

Output: `out/target/product/malbec/recovery.img`. Host tools are x86-64 Linux only.

### Source patch

`patches/0001-recovery-wait-for-module-handler.patch` makes `bootable/recovery` wait for
`twrp.module.handler_done` (set by `init.recovery.qcom.rc`) after loading vendor modules, so
vendor services do not keep `/vendor` busy. Ported from the Legion Y700 Gen 4 tree
(polygraphene, commit 321f5cf) onto current TWRP-Test.

## Install

The bootloader must be unlocked. Lenovo requires a device-specific `unlock` image
(`fastboot flash unlock sn.img`, then `fastboot oem unlock`).

```shell
fastboot flash recovery_a recovery.img
fastboot flash recovery_b recovery.img
fastboot reboot recovery
```

Do **not** flash a modified `vbmeta` (`--disable-verity --disable-verification`): this
bootloader rejects it and marks the slot unbootable. Stock `vbmeta` works with an unlocked
bootloader.

## Device-specific notes

- **Logical partitions are ext4**, not erofs.
- **Encryption flags** in `recovery.fstab` match the stock vendor `fstab.qcom`
  (`aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0`, metadata
  `aes-256-xts:wrappedkey_v0`). The stock *recovery* fstab's `fileencryption=ice` does not
  match the data partition.
- **Recovery VINTF**: in recovery, `servicemanager` reads only `/system/etc/vintf`. The vendor
  HAL declarations are therefore duplicated in `recovery/root/system/etc/vintf/manifest/`;
  without them KeyMint cannot register and `keystore2` aborts.
- **Boot control** (`vendor.boot-qti`) is started at `on fs`. TWRP waits for `IBootControl`
  while processing slotselect fstab entries, so starting it later deadlocks startup.
- **Display/touch**: the panel is landscape-native (3504x2190), the Novatek touch panel is
  portrait-native. `ro.twrp.touch.rotation=270` maps touch; `persist.twrp.rotation=270`
  gives the portrait UI.
- No NFC (`nxp-nci` not loaded).

## Credits

- [TWRP](https://twrp.me/) and [TWRP-Test](https://github.com/TWRP-Test/platform_manifest_twrp_aosp)
- [polygraphene/android_device_lenovo_TB322FC](https://github.com/polygraphene/android_device_lenovo_TB322FC)
  (Legion Y700 Gen 4, same platform): tree layout and recovery init scripts
- Vendor binaries and firmware in `recovery/root/vendor` are from the stock Lenovo firmware
  and remain the property of their respective owners.
