import os
import sqlite3
import shutil
import requests

# --- USER CONFIGURATION ---
DB_PATH = r".\assets\db\hisn_elmoslem.db"        # ← your SQLite DB file path
AUDIO_FOLDER = r""     # ← folder containing 221.mp3, etc.
OUTPUT_FOLDER = r"./tools/output/audio"                 # ← destination folder for copied audios
TITLE_IDS = [3, 27, 29, 30, 31, 96, 98, 107]  # ← favourite title IDs
# ---------------------------

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# Connect to SQLite database
conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

# Query all relevant audio URLs
placeholders = ",".join("?" * len(TITLE_IDS))
query = f"SELECT audio FROM contents WHERE titleId IN ({placeholders})"
cursor.execute(query, TITLE_IDS)
results = cursor.fetchall()

audio_files = set()

for (audio_url,) in results:
    if not audio_url:
        continue
    filename = os.path.basename(audio_url.strip())
    base_name = filename.replace(".mp3", "").replace("audio_", "")
    prefixed_name = f"audio_{base_name}.mp3"
    audio_files.add((prefixed_name, audio_url))

copied_count = 0
downloaded_count = 0
missing = []

for filename, audio_url in audio_files:
    src = os.path.join(AUDIO_FOLDER, filename)
    dst = os.path.join(OUTPUT_FOLDER, filename)

    if os.path.exists(src):
        # Copy local file
        shutil.copy2(src, dst)
        copied_count += 1
    else:
        # Try downloading
        try:
            print(f"⬇️  Downloading missing file: {filename}")
            response = requests.get(audio_url.strip(), timeout=10)
            if response.status_code == 200:
                with open(dst, "wb") as f:
                    f.write(response.content)
                downloaded_count += 1
            else:
                print(f"⚠️ Failed to download {audio_url} (status {response.status_code})")
                missing.append(filename)
        except Exception as e:
            print(f"❌ Error downloading {audio_url}: {e}")
            missing.append(filename)

# Summary
print(f"\n✅ Copied {copied_count} files from local folder.")
print(f"✅ Downloaded {downloaded_count} files from the web.")
if missing:
    print(f"⚠️ Missing {len(missing)} files could not be copied or downloaded:")
    for m in missing:
        print("  -", m)
else:
    print("🎉 All audio files are available in './output'!")

conn.close()