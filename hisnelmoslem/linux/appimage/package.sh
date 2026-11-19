#!/usr/bin/env bash
set -euo pipefail

if [[ $# != 1 || "$(uname -m)" != x86_64 ]]; then
  echo "Usage on Linux x86-64: $0 OUTPUT.AppImage" >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/../.." && pwd)"
bundle="$project_dir/build/linux/x64/release/bundle"
output="$(realpath -m -- "$1")"
if [[ ! -x "$bundle/hisnelmoslem" || ! -d "$bundle/data/flutter_assets" ]]; then
  echo "Build the release bundle with flutter build linux --release first." >&2
  exit 1
fi

staging="$(mktemp -d "$project_dir/build/linux/appimage.XXXXXXXX")"
trap 'rm -rf -- "$staging"' EXIT
export TMPDIR="$staging"

appdir="$staging/HisnElmoslem.AppDir"
app_id=com.hassaneltantawy.hisnelmoslem
mkdir -p -- "$appdir/usr/bin" "$appdir/usr/share/licenses/$app_id" "$(dirname -- "$output")"
cp -a -- "$bundle/." "$appdir/usr/bin/"
install -m 755 -- "$script_dir/AppRun" "$appdir/AppRun"
install -m 644 -- "$project_dir/../LICENSE" "$appdir/usr/share/licenses/$app_id/LICENSE"
install -m 644 -- "$project_dir/assets/images/app_icon.png" "$appdir/$app_id.png"
install -m 644 -- "$script_dir/$app_id.desktop" "$appdir/$app_id.desktop"
desktop-file-validate "$appdir/$app_id.desktop"

packager="$staging/appimagetool-x86_64.AppImage"
curl --fail --silent --show-error --location --retry 3 --output "$packager" \
  https://github.com/AppImage/appimagetool/releases/download/1.9.1/appimagetool-x86_64.AppImage
printf '%s  %s\n' ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0 "$packager" |
  sha256sum --check
chmod +x -- "$packager"

# Use the runtime embedded in the pinned tool to avoid a second, unversioned download.
head -c "$("$packager" --appimage-offset)" "$packager" > "$staging/runtime"
ARCH=x86_64 "$packager" --appimage-extract-and-run --no-appstream \
  --runtime-file "$staging/runtime" --mksquashfs-opt=-processors --mksquashfs-opt=2 \
  "$appdir" "$staging/hisnelmoslem-linux-x86_64.AppImage"
mv -- "$staging/hisnelmoslem-linux-x86_64.AppImage" "$output"
