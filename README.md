# local_manifests

Local manifest for the chopin (POCO X3 GT / Redmi Note 10 Pro) + ares (Redmi
K40 Gaming) MT6893 LineageOS 23.2 port.

## Usage

```bash
mkdir -p ~/android/lineage && cd ~/android/lineage
repo init -u https://github.com/LineageOS/android.git -b lineage-23.2 --git-lfs
git clone https://github.com/seriaTvT/local_manifests -b lineage-23.2 .repo/local_manifests
repo sync -c -j"$(nproc)" --no-clone-bundle --no-tags
```

Then `lunch lineage_chopin-bp4a-user` / `lineage_chopin_rn10pro-bp4a-user` /
`lineage_ares-bp4a-user` and `mka bacon`.

Full build/signing/flashing instructions: REPRODUCE.md in the LOS-dev project tree.
