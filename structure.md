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
- Description: Move AppImage files into the managed directory (`~/.appimages`). Each AppImage should end up in its own folder.
- Usage: `appimg move [OPTIONS] [PATH]`
- Options:
	- `-s DIR` — specify a directory to search for AppImages.
	- `--all` — move all AppImages found in the search scope.
- Behavior:
	- If `~/.appimages` does not exist, create it.
	- For each AppImage found, create a folder for that AppImage inside `~/.appimages` and move the file there.
	- Do not attempt to move files that are already inside `~/.appimages` into the same location.
	- Do handle `~/.appimages/tmp` specially (it may contain reset files) — do not skip it when appropriate, but avoid moving from a folder into itself.
	- If `--all` is omitted, the user must provide the AppImage path: `appimg move ~/Downloads/myapp.AppImage`.
	- Matching of file extensions is case-insensitive.

3) `appimg update`
- Description: Scan `~/.appimages`, and for each folder containing an AppImage generate a `.desktop` file and ensure a proper icon and executable bit. If `APPNAME` is provided, only that application is updated.
- Usage: `appimg update [APPNAME] [--icon|--icon-skip]`
- Behavior:
	- For each folder in `~/.appimages` that contains an AppImage:
		- Generate or update the `.desktop` file for the application.
		- Determine the icon using the following precedence:
			1. If `icon.*` already exists in the folder, use it.
			2. Otherwise, extract the AppImage and inspect its embedded `.desktop` `Icon` key; then try to find a matching icon:
				 - Search common icon directories (e.g. `/usr/share/icons`, `/usr/share/pixmaps`) for an SVG matching the name.
				 - If no matching SVG, search for a matching PNG and prefer the largest PNG file by file size.
				 - If still not found, search for a matching XPM.
				 - If no direct match is found, fall back to the largest SVG, then largest PNG, then largest XPM from the extracted contents.
			  3. If no icon is found at all:
				  - If `--icon` was provided, automatically attempt to extract icons from the AppImage.
				  - If `--icon-skip` was provided, do not attempt extraction and use `~/.appimages/placeholder-icon.png`.
				  - If neither option is provided, ask the user if they would like to extract icons from the AppImage. If the user declines or no icon can be extracted, use `~/.appimages/placeholder-icon.png`.
		- Copy the chosen icon into the app's folder as `icon.*`.
		- Create a `.noiconkeep` marker if needed to prevent icon copying on reset.
		- Ensure the AppImage file is executable.
		- Create a symlink for the generated `.desktop` file in the system applications directory (e.g. `~/.local/share/applications`).
	- Note: AppImage file extensions are treated case-insensitively.

4) `appimg setup-all`
- Description: Convenience command that runs `appimg move` and `appimg update` with their default options to discover, move, and register AppImages.
- Usage: `appimg setup-all [--icon|--icon-skip]`

5) `appimg reset`
- Description: Reset the managed AppImage state. Move managed AppImages to a temporary area, remove their folders, and undo registration.
- Usage: `appimg reset`
- Behavior:
	- Move all AppImage files from their folders in `~/.appimages` into `~/.appimages/tmp`.
	- When moving, also move any icons that belong to an AppImage; rename them using the pattern `<appname>-icon.*` so they can be detected later by `appimg update`.
	- After moving files to `~/.appimages/tmp`, delete the now-empty app folders.
	- Mark the moved AppImage files as non-executable.
	- Remove any symlinks created in the system applications directory.
	- `appimg update` should be able to detect icons in `~/.appimages/tmp` (using the `<appname>-icon.*` pattern), rename them to `icon.*` and move them back to the appropriate folders when restoring.

6) `appimg select`
- Description: Manage and switch between multiple versions of an AppImage for a given application name.
- Usage:
	- `appimg select <appname>`: List available versions for `<appname>` and indicate the currently active one.
	- `appimg select <appname> --switch <VERSION>`: Switch the active AppImage version for `<appname>` to `<VERSION>`. The `<VERSION>` is a unique identifier, a string, or a numeric index.
- Behavior:
	- **Version Naming Convention**: When `appimg move` processes AppImages, if multiple versions of the same application (basically when there's more than one appimage of the same name) are detected, it appends a unique `#version-string` suffix to the filename (e.g., `krita#1.AppImage`, `krita#2.AppImage`). The `#` character denotes the start of the version string for identification purposes across commands.
	- **Storage Location**: All versions of a single application are stored within the same dedicated subfolder under `~/.appimages` (e.g., `~/.appimages/krita/krita#1.AppImage`).
	- **Active Version Symlink**: A symlink, named after the application without a version suffix (e.g., `~/.appimages/krita/krita.AppImage`), points to the currently active version. This symlink is the target for `.desktop` file entries and system integration.
	- **`appimg select <appname>`**: Lists all available versioned AppImages (e.g., `krita#1.AppImage`, `krita#3.AppImage`) found in the application's folder and indicates which version the active symlink currently points to.
	- **`appimg select <appname> --switch <VERSION>`**: Modifies the active symlink (e.g., `~/.appimages/krita/krita.AppImage`) to point to the AppImage file corresponding to `<VERSION>`. Subsequently, `appimg update <appname>` is automatically run to re-generate the `.desktop` file and ensure system integration reflects the new active version.
	- **Interactions with other commands**:
		- `appimg move`: Recognizes the `#` character as a version separator and ensures multiple versions of an application are grouped within the same folder.
		- `appimg reset`: Removes the active version symlink (e.g., `krita.AppImage`) when moving AppImages to `~/.appimages/tmp`. The version string (e.g., `#1`) is preserved in the AppImage filename during this move.


Notes
- Treat `.AppImage` and `.appimage` equivalently (case-insensitive matching).
- Default managed directory: `~/.appimages`.
- Placeholder icon path: `~/.appimages/placeholder-icon.png`.