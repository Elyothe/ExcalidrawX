# Excalidraw X

**Excalidraw X** is a cross-platform desktop client for organizing and editing Excalidraw files. Built with Flutter.

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