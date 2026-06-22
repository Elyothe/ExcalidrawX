<h1 align="center">ExcalidrawX</h1>

<p align="center">
  <img src="./excalidrawx/assets/logo_rounded.png" alt="ExcalidrawX" width="128">
</p>

<p align="center"><strong>ExcalidrawX</strong> is a cross-platform desktop client for organizing and editing Excalidraw files. Built with Flutter.</p>

<p align="center">
  <a href="https://github.com/Elyothe/ExcalidrawX/releases/latest">
    <img alt="Latest Release" src="https://img.shields.io/github/v/release/Elyothe/ExcalidrawX?include_prereleases&sort=semver&style=for-the-badge&labelColor=24273a&color=c6a0f6">
  </a>
  <a href="https://github.com/Elyothe/ExcalidrawX/releases/latest">
    <img alt="macOS" src="https://img.shields.io/badge/macOS-dmg-grey?style=for-the-badge&labelColor=24273a&color=8bd5ca&logo=apple&logoColor=white">
  </a>
  <a href="https://github.com/Elyothe/ExcalidrawX/blob/main/LICENSE">
    <img alt="License" src="https://img.shields.io/badge/license-MIT-grey?style=for-the-badge&labelColor=24273a&color=a6da95">
  </a>
</p>

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS | ✅ Available |
| Linux | 🚧 In development |
| Windows | 🚧 In development |

---

## Features

- Browse and organize `.excalidraw` files in folders
- Full editing via embedded Excalidraw web editor
- Create, open, save, and delete `.excalidraw` files
- Autosave
- Session restore (reopens last edited file on launch)
- Native macOS look and feel

---

## Prerequisites

- [Flutter](https://flutter.dev) SDK
- [FVM](https://fvm.app) (Flutter Version Management) — the project uses Flutter `3.44.0`
- [Xcode](https://developer.apple.com/xcode/) (with command-line tools)
- [CocoaPods](https://cocoapods.org) — install via `sudo gem install cocoapods`
- A macOS host machine (for now; Linux and Windows support coming)

---

## Getting Started

```bash
# Clone the repository
git clone https://github.com/Elyothe/ExcalidrawX.git
cd ExcalidrawX

# Install FVM and use the project's Flutter version
fvm install
fvm use

# Install dependencies
cd excalidrawx
fvm flutter pub get

# Generate code (dart_mappable serialization, etc.)
fvm dart run build_runner build --delete-conflicting-outputs

# Run on macOS
fvm flutter run -d macos

# Build for macOS
fvm flutter build macos
```
