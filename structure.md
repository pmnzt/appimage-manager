# Commands 
1. appimg ls [by default searches all appimages in the user home/ directory]
- options: -s [to specify a directory (s as in the wordscope)]
- example-output: lists all the appimages it finds each with its full path 
- required-options: none

2. appimg move
- options: -s [to specify a directory (s as in the wordscope)], --all [moves all appimages it found]
- example-output: if the directory ~/.appimages doesn't exist it creates it, each appimage file that was found (.AppIamge) gets moved to ~/.appimages each .AppImage file will have its own folder, command move should not attempt to move files from ~/.appimage to itself 
- required-options: none; if `--all` isn't included in the command, the user must add the appimage file path after the command i.e: [appimg move ~/Downloads/myapp.AppImage]

3. appimg update 
this command will look in ~/.appimages then in each folder that has a .AppImage file, it will generate a .desktop file if there is a `icon.*` file in the same folder as the .AppImage it will add that as the icon in the .dekstop file, if there is not it will use `~/.appimages/placeholder-icon.png`, and then finally create a symlink for that .desktop file to the direcoty in which the system uses to store .desktop files.

4. appimage setup-all
this command will run commands 2,3 with their default options.