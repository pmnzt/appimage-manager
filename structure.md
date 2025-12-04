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
- Description: Move AppImage files into the `managed/` directory (`~/.appimages/managed`). Each AppImage will be placed in its own dedicated folder within `managed/`.
- Usage: `appimg move [OPTIONS] [PATH]`
- Options:
	- `-s DIR` — specify a directory to search for AppImages. Defaults to the user's home directory if `--all` is used without `PATH`.
	- `--all` — move all AppImages found in the search scope. If `PATH` is provided, it searches within `PATH`.
- Behavior:
	- If `~/.appimages`, `~/.appimages/managed`, or `~/.appimages/unmanaged` do not exist, they will be created.
	- For each AppImage:
		- Its embedded `.desktop` file is extracted to determine the application's ID.
		- A folder named after the ID (e.g., `org.kde.krita`) is created inside `~/.appimages/managed/`.
		- The AppImage is moved into this new folder and renamed to match the folder name (e.g., `~/.appimages/managed/org.kde.krita/org.kde.krita.AppImage`).
	- This process overwrites any existing AppImage with the same ID in the `managed/` directory, ensuring only one version of each application is managed at a time.
	- AppImages already residing within `~/.appimages/managed/` are skipped to prevent redundant operations.
	- If `--all` is omitted, the user must provide a specific AppImage path: `appimg move ~/Downloads/myapp.AppImage`.
	- File extension matching is case-insensitive (`.AppImage`, `.appimage`).

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