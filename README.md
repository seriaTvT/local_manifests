# chopin / ares — pinned LineageOS 24 snapshot

This branch publishes the 2026-11-04 Android 17 / LineageOS 24 source snapshot.
The tested device is **chopin** (POCO X3 GT / Redmi Note 10 Pro China, MT6893),
not the unrelated global Redmi Note 10 Pro (`sweet`). ares hardware is not yet
validated on LOS24. This remains a bring-up snapshot, not a fully qualified release.

## Reproduce the tested source

Use an empty Linux working directory and a recent Repo launcher, Git, Git LFS,
Python 3, OpenSSL and the standard LineageOS host build dependencies.
Allow sufficient disk space for the source and build outputs.

```bash
mkdir los24 && cd los24
git lfs install
repo init -u https://github.com/seriaTvT/local_manifests -b lineage-24.0 --repo-rev=v2.71 --git-lfs
repo sync -c --fail-fast
bash patches/apply-patches.sh
bash patches/apply-patches.sh --check
```

`default.xml` is a **standalone main manifest**, with all 1,255 projects pinned
to full commits. Do not additionally copy it or mt6893.xml into local_manifests.
The optional `mt6893.xml` is only a device overlay and does not pin the full
platform; it is insufficient for reproducing this snapshot by itself.

The manifest pins upstream bases for the eight patches; the patch runner verifies
both patch hashes and final source tree hashes. Device/common, vendor/common and
kernel changes are published directly in seriaTvT repositories. Device/common
and vendor/common use `lineage-24.0`; the kernel upstream is `main`. The manifest
retains the tested commit pins.
Repo v2.71 is pinned because the Repo cache patch has that exact source baseline.
No repo sync, patch application or branch switch is needed on the existing build
server while a build is active. Do not add `--force-sync` to discard local work.

## Signing

All products, including userdebug, expect a complete certificate directory at
`vendor/lineage-priv/keys`. **No private key is published.** Supply your own
existing nine-pair key set, or generate a new one once:

```bash
bash .repo/manifests/generate-keys.sh vendor/lineage-priv/keys
```

Keep these keys for your subsequent updates. Eight distinct identities are
required (including distinct NFC/platform keys); testkey copies releasekey.
Bluetooth's signing certificate and SELinux mapping use the same directory.
An independently signed build cannot be byte-identical to seriaTvT's signed OTA
and is not a seamless replacement for its update-signing identity.

## Build

```bash
export OUT_DIR=out
export SOONG_INCREMENTAL_ANALYSIS=false
source build/envsetup.sh
lunch lineage_chopin_rn10pro-cp2a-user
m bacon
```

This selects Redmi Note 10 Pro branding and the stock CN fingerprint, user build,
release signing and included GApps. Use `lineage_chopin-cp2a-userdebug` for the
POCO bring-up configuration. Both target the same chopin output directory; build
sequentially and archive artifacts before changing products.

## Scope and known limits

The source includes first-boot ION/power/thermal integration, media policy,
Codec2 Fence ABI repair, native Zygote capability fallback, ARM64 membarrier
sync-core, legacy process reclaim and freezer capability gating. On the tested
chopin userdebug build: boot/enforcing, Chrome/search/application starts, memory
integrity/reclaim, cross-CPU JIT tests, media and HDR interaction regressions pass.
Hotspot/VPN/public IPv6/CLAT and longer daily-use stress remain to be verified.
Complete Binder freezer and modern reclaim syscalls are not backported.

No new platform forks are required. Small upstream/platform/tool patches live in
[android_patches](https://github.com/seriaTvT/android_patches/tree/lineage-24.0),
including hardware/mediatek's small namespace change. The existing
`seriaTvT/android_frameworks_av` fork is not required by this snapshot.
