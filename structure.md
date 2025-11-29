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
this command will look in ~/.appimages then in each folder that has a .AppImage file, it will generate a .desktop file if there is a `icon.*` file in the same folder as the .AppImage it will add that as the icon in the .dekstop file, if there is not it will use `~/.appimages/placeholder-icon.png`, and then finally create a symlink for that .desktop file to the direcoty in which the system uses to store .desktop files.
account for some files might be .AppImage or .appimage (case-insensitive).
make sure the appimge file is executable.
if there's no icon find the appimage's original icon by extracting the appimage file, and use that (in this case generate a new file .noiconkeep move into the appimage folder then next time if an appimg reset happens and this file exists in an appimage's folder then do not copy it's icon).

4. appimage setup-all
this command will run commands 2,3 with their default options.

5. appimage reset this command will move all appimages from their folders in ~/.appimages to ~/.appimages/tmp and then after deletes their folders, then every AppImage file in ~/.appimages/tmp should become non-executable, as well as removing their symlinks, make sure the reset command whem moving appimages into ~/.appimages/tmp to move their icons too if they had, using the name of the appimage like name-icon.* so that when appimage update runs it can also detect icons in .appimages/tmp and move them and edit their names to icon.* but also move them to their correct places as they were before reset.