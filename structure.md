# Commands 
1. appimg ls [by default searches all appimages in the user home/ directory]
- options: -s [to specify a directory (s as in the wordscope)]
- example-output: lists all the appimages it finds each with its full path 
- required-options: none

2. appimg move
- options: -s [to specify a directory (s as in the wordscope)], --all [moves all appimages it found]
- example-output: if the directory ~/.appimages doesn't exist it creates it, each appimage file that was found (.AppIamge) gets moved to ~/.appimages each .AppImage file will have its own folder, command move should not attempt to move files from ~/.appimage to itself, However it shouldn't skip ~/.appimages/tmp, account for some files might be .AppImage or .appimage (case-insensitive).
- required-options: none; if `--all` isn't included in the command, the user must add the appimage file path after the command i.e: [appimg move ~/Downloads/myapp.AppImage]

3. appimg update 
this command will look in ~/.appimages then in each folder that has a .AppImage file, it will generate a .desktop file. For the icon, it will:
- Use `icon.*` in the folder if present.
- Otherwise, extract the AppImage and:
	- Read the embedded .desktop file's `Icon` key and search for a matching SVG in common icon directories (usr/share/icons, usr/share/pixmaps, etc.).
	- If no SVG is found, search for a matching PNG and select the largest one by file size.
	- If still not found, search for a matching XPM.
	- If no match, fallback to the largest SVG, then largest PNG, then largest XPM in the extracted contents.
- If no icon is found, use `~/.appimages/placeholder-icon.png`.
The selected icon is copied to the appimage folder as `icon.*`. A `.noiconkeep` marker is created to prevent icon copying on reset. The appimage file is made executable. Finally, a symlink for the .desktop file is created in the system's applications directory.
Account for some files might be .AppImage or .appimage (case-insensitive).

4. appimage setup-all
this command will run commands 2,3 with their default options.

5. appimage reset this command will move all appimages from their folders in ~/.appimages to ~/.appimages/tmp and then after deletes their folders, then every AppImage file in ~/.appimages/tmp should become non-executable, as well as removing their symlinks, make sure the reset command whem moving appimages into ~/.appimages/tmp to move their icons too if they had, using the name of the appimage like name-icon.* so that when appimage update runs it can also detect icons in .appimages/tmp and move them and edit their names to icon.* but also move them to their correct places as they were before reset.