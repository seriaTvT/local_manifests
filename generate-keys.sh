#!/usr/bin/env bash
# Generate this builder's own keys; never copy or overwrite another key set.
set -euo pipefail
umask 077
keys_dir="${1:-vendor/lineage-priv/keys}"
test -f development/tools/make_key || { echo 'Run from the synced Android root.' >&2; exit 1; }
mkdir -p "$keys_dir"
test -z "$(find "$keys_dir" -mindepth 1 -maxdepth 1 -print -quit)" || {
    echo 'Key directory is not empty; refusing to overwrite keys.' >&2; exit 1;
}
subject='/C=CN/O=Independent LOS24 Builder/CN=Android'
for name in releasekey platform shared media networkstack bluetooth sdk_sandbox nfc; do
    # Some historical make_key versions exit 1 even after successful generation.
    printf '\n' | bash development/tools/make_key "$keys_dir/$name" "$subject" || {
        test -s "$keys_dir/$name.pk8" && test -s "$keys_dir/$name.x509.pem" || exit 1;
    }
    test -s "$keys_dir/$name.pk8"
    test -s "$keys_dir/$name.x509.pem"
done
cp "$keys_dir/releasekey.pk8" "$keys_dir/testkey.pk8"
cp "$keys_dir/releasekey.x509.pem" "$keys_dir/testkey.x509.pem"
echo 'Generated nine key pairs. Keep them private and retain them for your future updates.'
