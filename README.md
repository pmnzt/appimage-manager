# appimg — AppImage Manager

<p align="center">
  <img src="https://github.com/user-attachments/assets/810a3034-caae-47d3-b3dd-3e00f018bf26" alt="appimg logo" width="200"/>
</p>

`appimg` is a lightweight command-line utility for managing AppImage files on Linux. It scans for AppImage files, organizes them into a consistent directory layout, and automatically generates `.desktop` launchers.

## Features

- Scan directories for `.AppImage` files
- Organize AppImages into `~/.appimages/<AppName>/`
- Detect and use bundled icons, or fall back to a placeholder
- Generate `.desktop` launchers and symlink them to the user applications directory
- One-shot full setup with `appimg setup-all`
- No external dependencies beyond standard GNU/Linux command-line tools

[demo.webm](https://github.com/user-attachments/assets/8d2ce4d9-6e46-4438-afd7-6be0bf8ccfaa)


## Installation

To install `appimg`, simply run the following command:

```bash
curl -sSL https://raw.githubusercontent.com/pmnzt/appimage-manager/main/install.sh | bash
```

This command downloads the `install.sh` script and pipes it directly to `bash` for execution, installing `appimg` to `/usr/local/bin` and setting up its man page and necessary directories.

## Man Pages

For detailed information on `appimg` commands, options, and usage, consult the man page:

```bash
man appimg
```

## Commands

Below are the primary `appimg` commands. For a detailed breakdown of all commands, options, and behaviors, please see the `structure.md` file.

### `appimg ls`

Lists discovered AppImage files.

- **Usage:**
  ```bash
  appimg ls
  appimg ls -s /path/to/search
  ```
- **Options:**
  - `-s DIR`: Specify a directory to search (default: `$HOME`).
- **Output:** Prints each found AppImage with its full path.

### `appimg move`

Moves AppImage files into the managed directory (`~/.appimages`).

- **Usage:**
  ```bash
  appimg move --all
  appimg move myfile.AppImage
  appimg move -s ~/Downloads --all
  ```
- **Options:**
  - `-s DIR`: Search directory.
  - `--all`: Move all found AppImages.

### `appimg update`

Generates or updates `.desktop` launchers for AppImages in the managed directory.

- **Usage:**
  ```bash
  appimg update [APPNAME] [--icon | --icon-skip]
  ```
- **Options:**
  - `[APPNAME]`: Update a specific app.
  - `--icon` / `--icon-skip`: Control icon extraction.

### `appimg setup-all`

A convenience command that runs `appimg move --all` followed by `appimg update`.

- **Usage:**
  ```bash
  appimg setup-all [--icon | --icon-skip]
  ```

### `appimg reset`

Resets the managed AppImage state by moving AppImages to a temporary directory and unregistering them.

- **Usage:**
  ```bash
  appimg reset
  ```

### `appimg select`

Manages and switches between multiple versions of an AppImage.

- **Usage:**
  ```bash
  appimg select <appname>
  appimg select <appname> --switch <VERSION>
  ```
- **Behavior:**
  - `appimg select <appname>`: Lists available versions.
  - `appimg select <appname> --switch <VERSION>`: Switches the active version.

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
