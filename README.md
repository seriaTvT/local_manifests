# local_manifests — chopin + ares (MT6893) LineageOS 23.2

Local manifest to reproduce the chopin (POCO X3 GT / Redmi Note 10 Pro) and
ares (Redmi K40 Gaming) MT6893 LineageOS 23.2 tree on a clean build server.

## Pull and build (fresh server)

```bash
# 1. Init the LineageOS base (lineage-23.2, with Git LFS for webview.apk)
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs

# 2. Drop in this manifest
git clone https://github.com/seriaTvT/local_manifests -b lineage-23.2 .repo/local_manifests

# 3. Sync everything (base + the projects listed in mt6893.xml)
repo sync -c -j"$(nproc)" --no-clone-bundle

# 4. Apply local patches to upstream-managed repos (RefBase perf fix,
#    frameworks/av codec2 revert). REQUIRED after every sync.
./patches/apply-patches.sh

# 5. Build (userdebug dev build shown; see variants below)
source build/envsetup.sh
lunch lineage_chopin-bp4a-userdebug     # or lineage_ares-bp4a-userdebug
mka bacon                                # -> out/target/product/<device>/lineage-*.zip
```

Lunch variants: `lineage_ares-bp4a-userdebug`, and the signed release products
`lineage_chopin-bp4a-user` / `lineage_chopin_rn10pro-bp4a-user` (see keys note).

## Must-know caveats for a clean-room build

- **Private signing keys are NOT in any repo.** `vendor/lineage-priv/keys/` is
  untracked by design. `userdebug` builds sign with test-keys and need nothing.
  The `-user` release products require those 9 key pairs copied into
  `vendor/lineage-priv/keys/` first — otherwise the build fails at signing.
- **apply-patches.sh is mandatory, every sync.** `repo sync` resets
  `system/core` and `frameworks/av` to pristine upstream; re-run the script to
  re-land the patches on topic branches. It is idempotent.
- **Git LFS.** `webview.apk` is an LFS object. `--git-lfs` at init handles it; if
  you hit `failed opening zip`, the pointer wasn't resolved — run `git lfs pull`
  in the offending repo.
- **Branch-tracking, not pinned.** Projects track branches (upstream tips move),
  so a fresh sync gives *latest buildable*, not a byte-identical rebuild. For an
  exact point-in-time rebuild, snapshot with `repo manifest -r > pinned.xml` and
  init against that.
- **Disk/RAM.** The full tree is ~330 GB checked out; a ROM build wants plenty of
  RAM (reference machine: 12 threads / 46 GB).

## What this manifest carries

seriaTvT forks: device (chopin/ares/mt6893-common), kernel (`chopin_kvm`, shared),
vendor blobs (chopin/mt6893-common/ares), AresParts, hardware/xiaomi. Community:
hardware/mediatek + vendor/mediatek/ims + device/mediatek/sepolicy_vndr. GApps
(MindTheGapps, baklava) baked in. `frameworks/av` tracks **upstream** LineageOS —
its former fork was a single codec2 revert, now in `android_patches`.
Full build/signing/flashing detail: REPRODUCE.md / PORT-LOG.md in the LOS-dev tree.
