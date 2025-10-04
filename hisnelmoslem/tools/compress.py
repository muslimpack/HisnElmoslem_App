import os
from pydub import AudioSegment

# --- USER CONFIGURATION ---
INPUT_FOLDER = r"D:\Downloads\Miscellaneous\processed-20250527T080005Z-1-001\processed"           # Folder with your current mp3 files
OUTPUT_FOLDER = r"./tools/output/compressed_all"      # Destination for reduced-size versions
TARGET_BITRATE = "48k"               # Options: "64k", "48k", "32k", etc.
# ---------------------------

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# Get list of mp3 files
mp3_files = [f for f in os.listdir(INPUT_FOLDER) if f.lower().endswith(".mp3")]

if not mp3_files:
    print("⚠️ No MP3 files found in the input folder.")
else:
    print(f"🎧 Found {len(mp3_files)} mp3 files to compress...")

compressed_count = 0
for file in mp3_files:
    src_path = os.path.join(INPUT_FOLDER, file)
    dst_path = os.path.join(OUTPUT_FOLDER, file)

    try:
        # Load and export with lower bitrate
        sound = AudioSegment.from_file(src_path, format="mp3")
        sound.export(dst_path, format="mp3", bitrate=TARGET_BITRATE)
        compressed_count += 1
        print(f"✅ Compressed: {file}")
    except Exception as e:
        print(f"❌ Failed to compress {file}: {e}")

print(f"\n🎉 Done! {compressed_count}/{len(mp3_files)} files saved in '{OUTPUT_FOLDER}'.")
