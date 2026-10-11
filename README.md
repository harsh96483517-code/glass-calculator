# Glass Calculator

A frosted-glass style calculator that runs as a single, self-contained HTML page — and as a native Android app that wraps that page in a full-screen, portrait-locked WebView.

## What's here

```
index.html                 The whole web app (one file, no build step)
android/                   Android Studio-style project sources
  AndroidManifest.xml      Portrait-locked, full-screen launcher activity
  res/values/strings.xml   App name
  res/values/styles.xml    Full-screen theme (no title/action bar)
  res/mipmap-*/            Launcher icon
  java/.../MainActivity.java  WebView host
  build.sh                 Headless build (aapt2 + javac + d8 + apksigner)
dist/glass-calculator.apk  Ready-to-install signed APK
```

## The web app

Open `index.html` in a browser. No server or dependencies are required — the only external request is the Inter webfont, and the app falls back cleanly to the system font when offline.

Features:

- **Basic and Scientific** modes, plus a **History** list (persisted in `localStorage`).
- A hand-written expression parser — no `eval` — supporting `+ − × ÷ ^`, `%`, `√`, `x²`, `sin/cos/tan`, `ln/log`, `π` and `e`, with implicit multiplication (`2π`, `3(4)`).
- Live result preview as you type, and a copy-to-clipboard result.
- A liquid-glass dock with a spring-physics slider, real backdrop refraction (on Chromium) and a drifting mesh-gradient backdrop.

## The Android app

The APK is a thin WebView shell around `index.html`:

- **Portrait-locked** (`android:screenOrientation="portrait"`).
- **Full screen** — immersive sticky mode hides the status and navigation bars; the theme has no title or action bar.
- Content is loaded from `file:///android_asset/index.html`, so the app works fully offline.
- `VIBRATE` permission powers the dock's haptic ticks.

Minimum Android 7.0 (API 24); targets API 34.

### Install

```
adb install dist/glass-calculator.apk
```

Or copy the APK to the device and open it (allow install from unknown sources).

### Rebuild from source

`android/build.sh` builds the APK without Gradle, using only the Android SDK build-tools and a JDK:

```
export ANDROID_HOME=/path/to/android-sdk   # needs build-tools;34.0.0 and platforms;android-34
bash android/build.sh
```

It runs `aapt2` (compile + link), `javac` against `android.jar`, `d8` (dex), then `zipalign` and `apksigner`.

> The bundled APK is signed with a standard Android **debug** keystore, which is fine for local testing but should be replaced with your own release key before distributing.

## License

MIT.
