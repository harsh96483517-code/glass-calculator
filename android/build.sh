#!/usr/bin/env bash
set -e
source /scratch/work/env.sh
cd /scratch/work/android
BT="$ANDROID_HOME/build-tools/34.0.0"
AJAR="$ANDROID_HOME/platforms/android-34/android.jar"

echo "== 1. compile resources =="
"$BT/aapt2" compile --dir res -o compiled.zip

echo "== 2. link resources -> base.apk =="
"$BT/aapt2" link -o base.apk -I "$AJAR" --manifest AndroidManifest.xml \
  compiled.zip --java gen --min-sdk-version 24 --target-sdk-version 34 \
  -A assets --version-code 2 --version-name 1.1

echo "== 3. compile java =="
rm -rf classes dexout && mkdir -p classes dexout
javac -source 8 -target 8 -bootclasspath "$AJAR" -d classes \
  gen/com/example/glasscalculator/R.java \
  java/com/example/glasscalculator/MainActivity.java 2>&1 | grep -v "bootstrap class path" || true
echo "classes:"; find classes -name '*.class'

echo "== 4. dex =="
"$BT/d8" --lib "$AJAR" --min-api 24 --output dexout $(find classes -name '*.class')
ls -la dexout

echo "== 5. add classes.dex into apk =="
python3 - <<'PY'
import zipfile, os
src = "base.apk"; dst = "base-dex.apk"
with zipfile.ZipFile(src) as zin, zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED) as zout:
    for it in zin.infolist():
        zout.writestr(it, zin.read(it.filename))
    zout.write("dexout/classes.dex", "classes.dex")
os.replace(dst, src)
print("classes.dex added; apk entries:")
with zipfile.ZipFile(src) as z:
    for n in z.namelist(): print("  ", n)
PY

echo "== 6. zipalign =="
"$BT/zipalign" -f -p 4 base.apk aligned.apk

echo "== 7. keystore =="
if [ ! -f debug.keystore ]; then
keytool -genkeypair -keystore debug.keystore -alias androiddebugkey \
  -storepass android -keypass android -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Android Debug,O=Android,C=US"
fi

echo "== 8. sign =="
"$BT/apksigner" sign --ks debug.keystore --ks-pass pass:android --key-pass pass:android \
  --out glass-calculator.apk aligned.apk

echo "== 9. verify =="
"$BT/apksigner" verify --print-certs glass-calculator.apk
"$BT/aapt2" dump badging glass-calculator.apk | head -20
ls -la glass-calculator.apk
