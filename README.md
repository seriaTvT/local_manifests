# PixelOS 17 for MT6893 devices

This branch is a standalone manifest that tracks upstream branches for the PixelOS 17 port.
It includes chopin (POCO X3 GT), chopin_rn10pro (Redmi Note 10 Pro China),
and ares (Redmi K40 Gaming / POCO F3 GT). AresParts is included for ares.

Use this repository as the **main manifest**, rather than copying its XML into
an existing checkout's local_manifests directory. PixelOS, LineageOS, device
and vendor projects follow their corresponding branches; the kernel follows
`seriaTvT/kernel_mt6893` branch `main`. The patch repository follows
`pixelos-17-tracking`. AOSP projects retain the release tags selected by upstream;
they are not moved to Android's development branch.

For the fixed, device-tested snapshot, use the
[`pixelos-17` branch](https://github.com/seriaTvT/local_manifests/tree/pixelos-17).
This tracking manifest follows existing project branches. Upstream manifest
additions, removals and release-tag changes require a manifest update here.

## Fetch and prepare

Use a Linux Android build environment with Git, Git LFS, Repo, Python 3,
OpenSSL and the usual Android build dependencies installed. Git must support
`merge-tree --write-tree --merge-base` for compatibility patch merging. Configure your
Git identity before initializing Repo. Git LFS must be available before syncing;
the PixelOS GMS repository contains LFS assets.

```bash
mkdir pixelos
cd pixelos
git lfs install
repo init -u https://github.com/seriaTvT/local_manifests -b pixelos-17-tracking --repo-rev=v2.71 --git-lfs
repo sync -c --fail-fast
repo manifest -r -o upstream-revisions.xml
bash patches/apply-patches.sh
bash patches/apply-patches.sh --check
git -C vendor/pixel/gms lfs fsck
bash .repo/manifests/generate-keys.sh
```

The patch runner first verifies patch hashes and reconstructs each original
patch tree from its recorded public base. It then performs a three-way merge
between that base, the current upstream and the patch. All projects are
preflighted before checked-out files are changed. Dirty worktrees, missing base
history, rewritten history or merge conflicts stop application. Do not use a
shallow checkout for patched projects. Repeated application is supported;
`--check` verifies that the patches require no further changes on current sources.

The eleven groups cover product integration, AresParts, battery LED coordination,
legacy kernel compatibility and build/tool fixes. The kernel and media buffer
fixes are already present in the corresponding device/vendor/kernel histories.
The Repo tool itself remains at v2.71 for the matching tool patch.

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

The fixed n10p and ares development builds passed device testing. Tracking
upstream heads does not carry that validation forward: a clean textual merge
does not prove build or runtime compatibility. Build and device testing remain
necessary after updates. No additional complete rebuild is claimed here.

## Updating tracked sources

Commit or stash your own work before syncing. In a clean tracking checkout,
update sources and rerun the patch tool:

```bash
repo sync -c --fail-fast
repo manifest -r -o upstream-revisions.xml
bash patches/apply-patches.sh
bash patches/apply-patches.sh --check
```

If Repo refuses to update a project with local commits, retain those commits
on a branch and resolve the checkout normally; do not force-discard work.
If the patch tool reports a conflict, update the affected patch before building.
Keep `upstream-revisions.xml` from before patch application together with the
patch repository revision to record the inputs to a build. Generated patch
commits are local; an export made after applying them alone is not a public
source manifest. Retain the same private signing keys for your own updates.
