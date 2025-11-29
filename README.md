# appimg — AppImage Manager

`appimg` is a lightweight command-line utility for managing AppImage files on Linux. It scans for AppImage files, organizes them into a consistent directory layout, and automatically generates `.desktop` launchers.

## Features

- Scan directories for `.AppImage` files
- Organize AppImages into `~/.appimages/<AppName>/`
- Detect and use bundled icons, or fall back to a placeholder
- Generate `.desktop` launchers and symlink them to the user applications directory
- One-shot full setup with `appimg setup-all`
- No external dependencies beyond standard GNU/Linux command-line tools

## Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/pmnzt/appimage-manager
cd appimage-manager
sh install.sh
```

This installs the `appimg` command on the system.

## Directory layout

Managed AppImages are stored under `~/.appimages/` using a per-application directory layout:

```
~/.appimages/
    MyApp/
        MyApp.AppImage
        icon.png       # optional application icon
        MyApp.desktop
    Editor/
        Editor.AppImage
        Editor.desktop
    placeholder-icon.png
```

Generated `.desktop` launchers are symlinked into:

```
~/.local/share/applications/
```

If you want to provide a custom icon for an AppImage, place the icon file (`.png`, `.svg`, `.ico`, etc.) in the same folder as the AppImage and run:

```bash
appimg update
```

If no icon is available, the `placeholder-icon.png` file will be used.

## Commands

Below are the primary `appimg` commands and expected behavior. Notes: file-extension matching is case-insensitive (e.g. `.AppImage`, `.appimage`) and the default search scope is the user's home directory (`$HOME`). The managed directory is `~/.appimages` and the placeholder icon path is `~/.appimages/placeholder-icon.png`.

1) `appimg ls`

Usage:

```bash
appimg ls
appimg ls -s /path/to/search
```

Description:

- **Purpose:** List discovered AppImage files.
- **Options:** `-s DIR` — specify a directory to search (default: `$HOME`).
- **Output:** Prints each found AppImage with its full path.

2) `appimg move`

Usage:

```bash
appimg move --all
appimg move myfile.AppImage
appimg move -s ~/Downloads --all
```

Description:

- **Purpose:** Move AppImage files into the managed directory (`~/.appimages`). Each AppImage is placed inside its own folder.
- **Options:** `-s DIR` — search directory; `--all` — move all AppImages found in the search scope. If `--all` is omitted you must provide a path to a single AppImage file.
- **Behavior:**
    - Create `~/.appimages` if it does not exist.
    - Do not move files that are already located inside `~/.appimages` into the same location.
    - Handle `~/.appimages/tmp` specially: avoid moving a file into the same folder and do not treat `tmp` as an ordinary application folder.
    - File-extension matching is case-insensitive.

3) `appimg update`

Usage:

```bash
appimg update [--icon | --icon-skip]
```

Description:

- **Purpose:** Scan `~/.appimages` and for each app folder containing an AppImage generate or update a `.desktop` launcher, ensure the AppImage is executable, and manage the app icon.
- **Icon selection precedence:**
    1. If `icon.*` already exists in the app folder, use it.
 2. Otherwise, attempt to extract or locate an icon from the AppImage:
         - Inspect the AppImage's embedded `.desktop` `Icon` key (if present) and try to find a matching icon name in common system icon directories such as `/usr/share/icons` and `/usr/share/pixmaps`.
         - Prefer SVGs first. If no SVG is found, search for PNGs and prefer the largest PNG by file size. If still not found, look for XPM.
         - If no direct name match is found in system dirs, fall back to choosing the largest SVG from the extracted contents, then largest PNG, then largest XPM.
 3. If no icon is found at all:
         - If `--icon` was provided, attempt automatic icon extraction from the AppImage.
         - If `--icon-skip` was provided, skip extraction and use the placeholder icon (`~/.appimages/placeholder-icon.png`).
         - If neither flag is provided, `appimg` may prompt interactively to ask whether to attempt extraction; if the user declines or extraction fails, the placeholder is used.
- **Additional behavior:**
    - The chosen icon is copied into the app folder as `icon.*`.
    - A `.noiconkeep` marker file may be created when needed to indicate the icon should be preserved across resets.
    - Ensure the AppImage file is executable.
    - Create or update a `.desktop` file for the app and symlink it into the user's applications directory (typically `~/.local/share/applications`).

4) `appimg setup-all`

Usage:

```bash
appimg setup-all [--icon | --icon-skip]
```

Description:

- **Purpose:** Convenience command that runs `appimg move --all` followed by `appimg update` (honoring the same icon flags) to discover, move, and register AppImages in one step.

5) `appimg reset`

Usage:

```bash
appimg reset
```

Description:

- **Purpose:** Reset the managed AppImage state by moving AppImages into a temporary area, removing application folders, and undoing registration.
- **Behavior:**
    - Move all AppImage files from their per-app folders in `~/.appimages` into `~/.appimages/tmp/`.
    - When moving, also move any icon files that belong to an AppImage and rename them using the pattern `<appname>-icon.*` so they can be detected later by `appimg update`.
    - After moving files to `~/.appimages/tmp`, delete the now-empty app folders.
    - Mark the moved AppImage files as non-executable.
    - Remove any `.desktop` symlinks that were created in the user's applications directory.
    - `appimg update` is able to detect icons stored in `~/.appimages/tmp` (using the `<appname>-icon.*` pattern), rename them back to `icon.*`, and move them to the restored app folder when re-registering.

After resetting, re-register AppImages with:

```bash
appimg setup-all
```

## Example workflow

```bash
# 1. List AppImages in Downloads
appimg ls -s ~/Downloads

# 2. Move detected AppImages into the managed directory
appimg move --all

# 3. Generate launchers
appimg update

# Or run the full setup
appimg setup-all

# Reset and re-register
appimg reset
appimg setup-all
```

## Requirements

- Bash
- Standard GNU/Linux utilities (`find`, `mv`, `ln`, etc.)
- No third-party dependencies are required

## License

MIT License
Copyright © 2025

## Contributing

Contributions, issues, and suggestions are welcome. Please open a pull request or issue on the project repository.