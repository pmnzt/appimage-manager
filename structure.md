# Directory layout

AppImages are organized into two main categories under `~/.appimages/`:

- `managed/`: Contains AppImages that have been organized and registered by `appimg`. Each managed AppImage resides in its own subdirectory, named after its application ID (derived from its `.desktop` file).
- `unmanaged/`: Serves as a holding area for AppImages that are either newly discovered, have been reset from a managed state, or were moved without an update.

### Managed AppImage Structure

Managed AppImages follow a per-application directory layout, where the directory name is based on the application's desktop file ID. The ID is derived from the `.desktop` filename (e.g., `org.kde.krita` from `org.kde.krita.desktop`).

Examples of desktop file IDs include:
- `com.appname.App`
- `org.kde.krita`
- `org.blender.Blender`

The resulting directory structure for managed AppImages would be:

```
~/.appimages/
    managed/
        org.kde.krita/
            org.kde.krita.AppImage
            icon.png       # optional application icon
            org.kde.krita.desktop
        org.blender.Blender/
            org.blender.Blender.AppImage
            org.blender.Blender.desktop
    unmanaged/
        my_new_app.AppImage
        another_app.AppImage
    placeholder-icon.png
```

Generated `.desktop` launchers for managed AppImages are symlinked into:

```
~/.local/share/applications/
```

If you want to provide a custom icon for a **managed** AppImage, place the icon file (`.png`, `.svg`, `.ico`, etc.) in the same folder as the AppImage (e.g., `~/.appimages/managed/org.kde.krita/icon.png`) and run:

```bash
appimg update [APPNAME]
```

If no icon is available, the `placeholder-icon.png` file will be used.

# Commands

This document describes the CLI commands and expected behavior for managing AppImage files.

1) `appimg ls`
- Description: List AppImage files. By default searches the user's home directory.
- Usage: `appimg ls [OPTIONS]`
- Options:
	- `-s DIR` — specify a directory to search ("s" = search scope).
- Output: Prints each found AppImage with its full path.
- Notes: File extension matching is case-insensitive (`.AppImage`, `.appimage`).

2) `appimg move`
- Description: Moves AppImage files from a source location to a destination. This command operates in two modes: "Direct Move" (moving files to a user-specified directory) or "Managed Import" (organizing files into the internal managed library structure based on metadata).
- Usage: `appimg move [OPTIONS] [FILE] [TARGET_DIR]`
- Options:
    - `-s`: Sets the source directory to search for AppImages when using `--all` (default is `$HOME`).
    - `--all`: Automatically finds and processes all AppImages found in the search path.
- Behavior:
    - Path 1: A target directory is specified.
        - Creates the target directory if it does not exist.
        - If `--all` is used, finds all unmanaged AppImages in the search path and moves them into the target directory.
        - If a specific file is provided, checks if the file is already in `managed/`. If not, moves the file to the target directory.
    - Path 2: No target directory is specified (Managed Import).
        - Gathers metadata (desktop ID and active status) for the specific file or all files found via `--all`.
        - Groups the AppImages by their unique desktop ID.
        - For each group (Application):
            - Determines the "Primary" AppImage. Logic prioritizes files tagged as `#active`; if none are active, it defaults to the first valid file.
            - Moves the Primary AppImage to `~/.appimages/managed/<desktop_id>/`.
            - If a managed AppImage already exists for that ID, it is overwritten if the new file is different.
            - Moves any secondary files (duplicates or non-active versions) to `~/.appimages/unmanaged/`.
        - Files with no detectable desktop ID are moved directly to `~/.appimages/unmanaged/`.

3) `appimg update`
- Description: Scan `~/.appimages/managed/`, and for each application folder containing an AppImage, generate a `.desktop` file and ensure a proper icon and executable bit. If `APPNAME` is provided, only that specific application in `managed/` is updated.
- Usage: `appimg update [APPNAME]`
- Behavior:
	- For each application folder in `~/.appimages/managed/` that contains an AppImage:
		- Generate or update the `.desktop` file for the application, typically placed in the application's folder (e.g., `~/.appimages/managed/org.kde.krita/org.kde.krita.desktop`).
		    - Determine the icon using the following precedence:
      1. If an `icon.*` file (e.g., `icon.png`, `icon.svg`) already exists within the application's folder, it is used.
      2. Otherwise, the AppImage is extracted (partially or fully) to inspect its embedded `.desktop` file for an `Icon` key. Then, the tool attempts to find a matching icon:
         - It first searches within the extracted AppImage's internal common icon directories (e.g., `usr/share/icons`, `usr/share/pixmaps`) for an SVG matching the `Icon` key's name (case-insensitively).
         - If no matching SVG is found, it searches these same directories for a matching PNG and prefers the largest PNG file by file size.
         - If still not found, it searches these same directories for a matching XPM.
         - If no icon is found based on the `Icon` key within these internal common directories, it falls back to searching the entire extracted AppImage contents for the largest SVG, then the largest PNG, then the largest XPM.
      3. If no icon is found at all through the above methods, `~/.appimages/placeholder-icon.png` is copied and used.
    - The chosen icon is copied into the app's folder as `icon.<extension>` (e.g., `icon.png`).
    - A `.noiconkeep` marker file is created in the application's folder if the icon was extracted and copied from the AppImage, to signal that this icon can be safely overwritten on subsequent updates or resets. This file is NOT created if a custom `icon.*` file already existed in the application folder.
		- Ensures the main AppImage file within the managed folder is executable.
		- Creates a symlink for the generated `.desktop` file in the system applications directory (e.g., `~/.local/share/applications/org.kde.krita.desktop`).
	- Note: AppImage file extensions are treated case-insensitively.

4) `appimg setup-all`
- Description: Convenience command that orchestrates a complete setup by running `appimg move --all` to discover and manage AppImages, followed by `appimg update` to register and configure them. It also performs a cleanup of outdated desktop files and empty managed directories.
- Usage: `appimg setup-all`
- Behavior:
	- Executes `appimg move --all`, which finds all AppImages in the default search scope (`$HOME`) and moves them into `~/.appimages/managed/`.
	- Executes `appimg update`, which processes all newly moved (and existing) managed AppImages to generate `.desktop` files, set icons, and ensure executability.
	- Performs additional cleanup:
		- Removes any existing `.desktop` files and their symlinks associated with previously managed AppImages to prevent conflicts.
		- Deletes any empty application directories that might remain in `~/.appimages/managed/` after previous operations.
	- Note: This command is designed for a fresh setup or a comprehensive re-scan and reorganization.

5) `appimg reset`
- Description: Resets the state of **managed** AppImages by moving them from `~/.appimages/managed/` to `~/.appimages/unmanaged/`, removing their associated `.desktop` files and symlinks, and deleting their now-empty managed application folders.
- Usage: `appimg reset`
- Behavior:
	- Identifies all AppImages currently within `~/.appimages/managed/`.
	- For each managed AppImage:
		- Moves the AppImage file from its managed application folder (e.g., `~/.appimages/managed/org.kde.krita/org.kde.krita.AppImage`) to the `~/.appimages/unmanaged/` directory.
		- Removes the application's `.desktop` file from its original managed folder (e.g., `~/.appimages/managed/org.kde.krita/org.kde.krita.desktop`).
		- Deletes the symlink to the `.desktop` file from the system applications directory (e.g., `~/.local/share/applications/org.kde.krita.desktop`).
		- Removes the now-empty application folder from `~/.appimages/managed/` (e.g., `~/.appimages/managed/org.kde.krita/`).
	- After the process, all previously managed AppImages will reside in `~/.appimages/unmanaged/`, effectively unregistering them from the system and preparing them for a potential re-management or manual handling.

Notes
- Treat `.AppImage` and `.appimage` equivalently (case-insensitive matching).
- Default managed directory: `~/.appimages/managed`.
- Default unmanaged directory: `~/.appimages/unmanaged`.
- Placeholder icon path: `~/.appimages/placeholder-icon.png`.

6) `appimg run`

- Description:
  Runs an AppImage directly, handling execution permissions and NixOS compatibility automatically.  
  This command is also used in the `.desktop` files generated for managed AppImages to launch the application.

- Usage:
  appimg run <PATH_TO_APPIMAGE>

- Behavior:
  - Validates that an AppImage path is provided and that the file exists.
  - Ensures the AppImage is executable (chmod +x).
  - On NixOS:
      - Detects the non-FHS environment.
      - If appimage-run is available, uses it to launch the AppImage.
      - If appimage-run is missing, opens a terminal explaining that:
          - NixOS is non-FHS.
          - appimage-run is required to run AppImages.
          - Provides a minimal install hint and exits.
  - On non-NixOS systems:
      - Executes the AppImage directly.

7) `appimg open`
- Description: Interactively select and launch a managed AppImage.
- Usage: `appimg open`
- Behavior:
	- Shows interactive terminal menu; use arrow keys.
	- Press Enter to launch the selected AppImage.
- Notes:
	- Useful for quickly launching apps from the managed library.
	- Does not move, update, or manage AppImages.

- Notes:
  - This command does not move, register, or manage the AppImage.
  - Managed AppImages’ `.desktop` launchers call this command to run the application.