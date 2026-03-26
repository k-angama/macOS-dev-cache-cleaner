<p align="center">
  <img src="./DevCacheCleaner/Assets.xcassets/FeatherDusterIcon.imageset/FeatherDusterIcon.png" alt="DevCacheCleaner icon" width="128" height="128">
</p>

<h1 align="center">DevCacheCleaner</h1>

<p align="center">
  A macOS menu bar app for inspecting and cleaning developer caches stored in your Home folder.
</p>

<p align="center">
  DevCacheCleaner scans common cache-heavy directories, shows how much disk space they use, and lets you clean one category or all supported categories with live progress feedback.
</p>

If you want to reclaim storage used by Xcode, Gradle, CocoaPods, npm, browsers, and other development tools without manually digging through `~/Library` and hidden folders, this project is built for that workflow.

DevCacheCleaner keeps the scope intentionally focused:

- It only scans paths defined in the app configuration
- It works inside the user Home directory
- It asks for explicit Home-folder access before reading or deleting anything
- It shows cleanup progress while files are being removed

## Features

- Menu bar utility built with SwiftUI
- Security-scoped access to the user Home directory
- Per-category storage overview
- Single-category cleanup
- Clean-all workflow across all non-empty categories
- Cleanup progress window with live deletion feedback
- Automatic refresh when watched cache folders change
- Test coverage for use cases and view models

## What DevCacheCleaner Can Clean

### IDE Caches

Editor-related cache locations such as VS Code cache folders and other development-tool support files can quietly grow over time. DevCacheCleaner groups those locations into a single category so they can be reviewed and cleaned quickly.

### CocoaPods Caches

CocoaPods repositories and related cache folders can consume a noticeable amount of space, especially on machines used across many projects. These paths are included as a dedicated cleanup category.

### npm and Yarn Caches

Node package manager caches are common disk-space offenders on development machines. DevCacheCleaner scans the configured npm and Yarn cache paths and reports their combined usage.

### Android and Gradle Caches

Gradle caches, daemons, and Android Studio related cache folders can grow significantly after SDK, emulator, and build activity. The app groups those paths into one category for easier cleanup.

### Xcode Caches and DerivedData

Xcode generated data is one of the largest sources of reclaimable disk usage on many macOS development machines. DevCacheCleaner includes DerivedData, documentation cache, archives, simulator device data, and other Xcode-related cache paths configured in the app.

### Browser Caches

Developer workflows often involve multiple browsers, and their caches can also build up over time. Chrome, Brave, Firefox, Safari, Edge, and Opera cache folders are included in the current configuration.

### Flutter and pub-cache

Flutter tooling and `.pub-cache` content can accumulate over time, especially when switching between projects or SDK versions. DevCacheCleaner exposes that storage as its own category.

## How It Works

1. The app requests access to your Home folder and stores a security-scoped bookmark.
2. Storage categories are built from configured paths in [`Constants.swift`](./DevCacheCleaner/Common/Utils/Constants.swift).
3. Each category is scanned and displayed in the main menu bar window.
4. Folder changes are monitored so affected categories can refresh automatically.
5. Cleanup runs for one category or all non-empty categories and reports progress in a separate window.

## Cache Categories

The current configuration includes:

- IDE caches
- CocoaPods caches
- npm and Yarn caches
- Android and Gradle caches
- Xcode caches and DerivedData
- Browser caches
- Flutter and `.pub-cache`

Definitions live in [`Constants.swift`](./DevCacheCleaner/Common/Utils/Constants.swift).

## Run In Xcode

1. Open `DevCacheCleaner.xcodeproj`
2. Select the `DevCacheCleaner` scheme
3. Run the app
4. Grant access to your Home directory when prompted

The app launches from the macOS menu bar and opens a secondary window during cleanup to display progress.

## Build

```bash
xcodebuild -project DevCacheCleaner.xcodeproj \
  -scheme DevCacheCleaner \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  build
```

## Test

```bash
xcodebuild -project DevCacheCleaner.xcodeproj \
  -scheme DevCacheCleaner \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  test
```

## Architecture

The project follows a simple layered structure:

- `Common`: shared constants, managers, utilities, extensions, dependency container
- `Data`: repository implementations
- `Domain`: entities, repository protocols, and use cases
- `Presentation`: SwiftUI views, view models, and shared UI state
- `DevCacheCleanerTests`: use case, mock, and view model tests

Main behavior is driven by focused domain use cases such as:

- `LoadStorageOverviewUseCase`
- `RefreshStorageCategoryUseCase`
- `CleanStorageCategoryUseCase`
- `CleanAllStorageCategoriesUseCase`
- `ReadDiskSpaceUseCase`
- `ObserveDiskChangesUseCase`

## Notes

- The app only cleans paths explicitly listed in `Constants`
- Some configured paths use prefix matching so only specific child directories are removed
- Cleanup deletes cache contents and cannot be undone
- Backing up anything important before cleaning is still the safer choice

## License

The source code in this repository is licensed under `GPL-3.0-only`. See
[`LICENSE`](./LICENSE).

The project name, logos, icon assets, and official branding are not granted
under the GPL code license. See [`TRADEMARKS.md`](./TRADEMARKS.md).

Official Mac App Store releases are published by Karim Angama.
