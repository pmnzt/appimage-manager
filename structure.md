# Directory layout

Managed AppImages are stored under `~/.appimages/` using a per-application directory layout, where the directory name is based on the application's desktop file ID. The ID is derived from the `.desktop` filename (e.g., `org.kde.krita` from `org.kde.krita.desktop`).

Examples of desktop file IDs include:
- `com.appname.App`
- `org.kde.krita`
- `org.blender.Blender`

The resulting directory structure would be:

```
~/.appimages/
    org.kde.krita/
        org.kde.krita.AppImage
        icon.png       # optional application icon
        org.kde.krita.desktop
    org.blender.Blender/
        org.blender.Blender.AppImage
        org.blender.Blender.desktop
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
	- For each AppImage, extract its embedded `.desktop` file to determine the application's ID.
	- Create a folder named after the ID inside `~/.appimages` and move the AppImage there.
	- The AppImage should be renamed to match the folder name (e.g., `~/.appimages/com.appname.App/com.appname.App.AppImage`).
	- This process overwrites any existing AppImage, meaning there is only one version of each application at a time.
	- Do not attempt to move files that are already inside `~/.appimages` into the same location.
	- Do handle `~/.appimages/tmp` specially (it may contain reset files) — do not skip it when appropriate, but avoid moving from a folder into itself.
	- If `--all` is omitted, the user must provide the AppImage path: `appimg move ~/Downloads/myapp.AppImage`.
	- Matching of file extensions is case-insensitive.

3) `appimg update`
- Description: Scan `~/.appimages`, and for each folder containing an AppImage generate a `.desktop` file and ensure a proper icon and executable bit. If `APPNAME` is provided, only that application is updated.
- Usage: `appimg update [APPNAME]`
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
			  3. If no icon is found at all, use `~/.appimages/placeholder-icon.png`.
		- Copy the chosen icon into the app's folder as `icon.*`.
		- Create a `.noiconkeep` marker if needed to prevent icon copying on reset.
		- Ensure the AppImage file is executable.
		- Create a symlink for the generated `.desktop` file in the system applications directory (e.g. `~/.local/share/applications`).
	- Note: AppImage file extensions are treated case-insensitively.

4) `appimg setup-all`
- Description: Convenience command that runs `appimg move` and `appimg update` with their default options to discover, move, and register AppImages.
- Usage: `appimg setup-all`

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

Notes
- Treat `.AppImage` and `.appimage` equivalently (case-insensitive matching).
- Default managed directory: `~/.appimages`.
- Placeholder icon path: `~/.appimages/placeholder-icon.png`.