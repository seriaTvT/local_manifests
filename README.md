# PixelOS 17 for MT6893 devices

This branch is a standalone, pinned manifest for the tested PixelOS 17 port.
It includes chopin (POCO X3 GT), chopin_rn10pro (Redmi Note 10 Pro China),
and ares (Redmi K40 Gaming / POCO F3 GT). AresParts is included for ares.

Use this repository as the **main manifest**, rather than copying its XML into
an existing checkout's local_manifests directory. The complete source snapshot
is pinned by commit, including the matching compatibility patch repository.
Existing LineageOS branches are independent of this snapshot.

For upstream branch tracking, use the separate
[`pixelos-17-tracking` branch](https://github.com/seriaTvT/local_manifests/tree/pixelos-17-tracking).
This fixed snapshot retains its tested kernel commit; the kernel's upstream
branch metadata now points to `main`.

## Fetch and prepare

Use a Linux Android build environment with Git, Git LFS, Repo, Python 3,
OpenSSL and the usual Android build dependencies installed. Configure your
Git identity before initializing Repo. Git LFS must be available before syncing;
the PixelOS GMS repository contains LFS assets.

```bash
mkdir pixelos
cd pixelos
git lfs install
repo init -u https://github.com/seriaTvT/local_manifests -b pixelos-17 --repo-rev=v2.71 --git-lfs
repo sync -c --fail-fast
bash patches/apply-patches.sh
bash patches/apply-patches.sh --check
git -C vendor/pixel/gms lfs fsck
bash .repo/manifests/generate-keys.sh
```

The patch runner verifies patch hashes, public base commits and final Git trees.
It refuses dirty or unexpected source trees and can be repeated safely. The
eleven groups cover product integration, AresParts, battery LED coordination,
legacy kernel compatibility and build/tool fixes. The kernel and media buffer
fixes are already present in the pinned device/vendor/kernel baselines.

The key helper creates a new private key set in `vendor/lineage-priv/keys` and
refuses to overwrite a nonempty directory. Retain your own keys for future
updates and never publish them. Independently generated keys produce different
signatures from other builders' releases; cross-signed OTA compatibility and
byte-identical release ZIPs are not implied by this source snapshot.

## Build

From the synced source root:

```bash
export OUT_DIR=out
unset OUT_DIR_COMMON_BASE
export SOONG_INCREMENTAL_ANALYSIS=false
source build/envsetup.sh
lunch custom_ares-cp2a-user
m pixelos
```

Select one product with the matching `lunch` command:

| Device | Release build target |
| --- | --- |
| Redmi Note 10 Pro China | `custom_chopin_rn10pro-cp2a-user` |
| POCO X3 GT | `custom_chopin-cp2a-user` |
| Redmi K40 Gaming / POCO F3 GT | `custom_ares-cp2a-user` |

Replace `user` with `userdebug` when developer debugging is required. PixelOS
already includes Google apps. Keep `OUT_DIR` relative to the source root for
the Siso build path. Build parallelism and optional `SOONG_GOMEMLIMIT` depend
on the build environment; no machine-specific tuning is required by this manifest.

The n10p and ares development builds passed device testing. This publication
also checks that all compatibility patches reproduce the tested Git trees;
it is not an additional full rebuild from a fresh source download. Device
testing remains necessary for releases built by other developers.

## Updating the snapshot

This branch intentionally freezes the source versions. Do not substitute newer
upstream revisions or force the patches onto different bases. Commit or stash
your own changes before syncing, and use a separate clean checkout when moving
to another manifest snapshot. Regenerate or restore keys only as appropriate
for your own existing releases.
