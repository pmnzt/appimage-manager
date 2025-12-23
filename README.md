# appimg — AppImage Manager

<p align="center">
  <img src="https://github.com/user-attachments/assets/810a3034-caae-47d3-b3dd-3e00f018bf26" alt="appimg logo" width="200"/>
</p>

`appimg` is a lightweight command-line utility for managing AppImage files on Linux. It scans for AppImage files, organizes them into a consistent directory layout, and automatically generates .desktop launchers.

---

## Table of Contents
1. [Features](#features)
2. [Installation](#installation)
3. [NixOS-specific note](#nixos-specific-note)
4. [Commands](#commands)
5. [Example workflow](#example-workflow)
6. [Requirements](#requirements)
7. [Documentation](#documentation)
8. [License](#license)
9. [Contributing](#contributing)

---

## Features
- Scan directories for .AppImage files
- Organize AppImages into ~/.appimages/
- Detect and use bundled icons, or fall back to a placeholder
- Generate .desktop launchers and symlink them to the user applications directory
- One-shot full setup with appimg setup-all
- No external dependencies beyond standard GNU/Linux command-line tools (see [nixos](#nixos-specific-note))

[demo.webm](https://github.com/user-attachments/assets/83b701d4-d42c-4a87-9394-e87998a38d1f)

---

## Installation

### Via curl (Recommended for quick install)
```bash
curl -sSL [https://raw.githubusercontent.com/pmnzt/appimage-manager/main/install/curl.sh](https://raw.githubusercontent.com/pmnzt/appimage-manager/main/install/curl.sh) | bash

```

This command downloads the curl.sh script and pipes it directly to bash for execution, installing appimg to /usr/local/bin and setting up its man page and necessary directories.

### Via git

```bash
git clone [https://github.com/pmnzt/appimage-manager.git](https://github.com/pmnzt/appimage-manager.git)
cd appimage-manager
./install/install.sh

```

This will install appimg from your local clone.

---

## NixOS-specific note

On NixOS, the filesystem layout is non-FHS (non-typical Linux hierarchy), so some AppImages require the appimage-run package to execute properly.

You can include it in your system configuration like this:

```nix
environment.systemPackages = with pkgs; [
  appimage-run
];

```

This ensures AppImages run correctly without extra manual steps.

---

## Commands

### appimg ls

Lists discovered AppImage files.

* **Usage:**
```bash
appimg ls
appimg ls -s /path/to/search

```


* **Options:**
* -s DIR: Specify a directory to search (default: $HOME).


* **Output:** Prints each found AppImage with its full path.

### appimg move

Moves AppImage files into the managed directory (~/.appimages).

* **Usage:**
```bash
appimg move --all
appimg move myfile.AppImage
appimg move -s ~/Downloads --all

```


* **Options:**
* -s DIR: Search directory.
* --all: Move all found AppImages.



### appimg update

Generates or updates .desktop launchers for AppImages in the managed directory.

* **Usage:**
```bash
appimg update [APPNAME]

```


* **Options:**
* [APPNAME]: Update a specific app.



### appimg setup-all

A convenience command that runs appimg move --all followed by appimg update.

* **Usage:**
```bash
appimg setup-all

```



### appimg reset

Resets the managed AppImage state by moving AppImages to a temporary directory and unregistering them.

* **Usage:**
```bash
appimg reset

```



### appimg open

Interactively select and launch an AppImage from the managed directory (~/.appimages/managed).

* **Usage:**
```bash
appimg open

```


* **Behavior:**
* Shows a terminal menu; navigate with arrow keys.
* Press Enter to launch the selected AppImage.



---

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

---

## Requirements

* Bash
* Standard GNU/Linux utilities (find, mv, ln, etc.) (see [nixos](#nixos-specific-note))

## Documentation

For detailed information on appimg commands, options, and usage, consult the man page:

```bash
man appimg

```

## License

MIT License
Copyright © 2025

## Contributing

Contributions, issues, and suggestions are welcome. Please open a pull request or issue on the project repository.
