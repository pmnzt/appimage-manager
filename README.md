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

1) `appimg ls`

Usage:

```bash
appimg ls
appimg ls -s /path/to/search
```

Description:

- Lists discovered `.AppImage` files.
- Default search path: `$HOME`.

2) `appimg move`

Usage:

```bash
appimg move --all
appimg move myfile.AppImage
appimg move -s ~/Downloads --all
```

Description:

- Moves AppImages into the `~/.appimages` structure.
- Creates `~/.appimages` if it does not exist.

3) `appimg update`

Usage:

```bash
appimg update [--icon | --icon-skip]
```

Description:

- Scans `~/.appimages` and creates a `.desktop` file for each AppImage.
- Icon handling:
  - If an `icon.*` file exists alongside the AppImage it is used.
  - `--icon` attempts automatic icon extraction from the AppImage when no icon file is present.
  - `--icon-skip` forces use of the placeholder and skips extraction.
  - If neither flag is provided the tool may prompt interactively; if extraction is not performed or fails, the placeholder is used.
- Creates symlinks in `~/.local/share/applications`.

4) `appimg setup-all`

Usage:

```bash
appimg setup-all [--icon | --icon-skip]
```

Description:

Performs `appimg move --all` followed by `appimg update` (honoring the same icon flags).

5) `appimg reset`

Usage:

```bash
appimg reset
```

Description:

- Moves all AppImages from `~/.appimages` into `~/.appimages/tmp/`.
- Removes all other folders inside `~/.appimages` (except `tmp` and `placeholder-icon.png`).
- Removes `.desktop` symlinks that point to AppImages.
- Removes executable permissions from AppImages placed in `tmp/`.

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