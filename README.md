# appimg – Simple AppImage Manager

`appimg` is a lightweight command-line tool that helps you manage AppImage files on Linux.  
It allows you to scan, move, organize, and generate `.desktop` launchers for your AppImages—fully automatically.

## ✨ Features

- 🔍 **Scan** any directory for `.AppImage` files  
- 📦 **Move & organize** AppImages into `~/.appimages/<AppName>/`  
- 🖼️ **Auto-detect icons** or use a placeholder  
- 🖥️ **Auto-generate `.desktop` launchers**  
- 🔗 **Symlink launchers** to your system applications directory  
- ⚙️ **One-shot full setup** using `appimg setup-all`  
- 💡 No dependencies except standard Linux CLI tools

---

## 📥 Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/pmnzt/appimage-manager
cd appimage-manager
sh install.sh
```

This will install the `appimg` command into your system.

---

## 📁 Directory Structure

All AppImages managed by this tool are placed in:

```
~/.appimages/
    MyApp/
        MyApp.AppImage
        icon.png       <-- optional app icon
        MyApp.desktop
    Editor/
        Editor.AppImage
        Editor.desktop
    placeholder-icon.png
```

`.desktop` launchers are symlinked to:

```
~/.local/share/applications/
```

> **Note:**  
> If you want a custom icon for your AppImage:
> 1. Place the icon file (any common format like `.png`, `.svg`, `.ico`) in the **same folder** as the `.AppImage`.  
> 2. Then run:
> 
> ```bash
> appimg update
> ```
> 
> This will generate or update the `.desktop` file with your icon.  
> If no icon is found, the placeholder `placeholder-icon.png` will be used instead.

---

## 🚀 Commands

### **1. `appimg ls`**
Search for AppImages.

#### Usage
```bash
appimg ls
appimg ls -s /path/to/search
```

#### Description
- Lists all `.AppImage` files.
- Default search path: `$HOME`.

---

### **2. `appimg move`**
Move AppImages into `~/.appimages`.

#### Usage
```bash
appimg move --all
appimg move myfile.AppImage
appimg move -s ~/Downloads --all
```

#### Description
- Moves AppImages into structured folders.
- Creates `~/.appimages` if missing.
- If `--all` is not used, you must specify a file manually.

---

### **3. `appimg update`**
Generates `.desktop` files and symlinks.

#### Usage
```bash
appimg update [--icon|--icon-skip]
```

#### Description
- Scans `~/.appimages`.
- Creates a `.desktop` launcher for each AppImage.
- Icon handling:
    - If `icon.*` exists alongside the AppImage, it is used.
    - If no icon is present and `--icon` is provided, the tool will automatically extract icons from the AppImage.
    - If `--icon-skip` is provided, extraction will be skipped and the placeholder icon will be used.
    - If neither flag is provided, the tool will prompt interactively whether to try extraction; if declined or extraction fails, the placeholder icon is used.
- Creates symlinks in `~/.local/share/applications`.

> **Reminder:** If you added or changed any icons, always run `appimg update` to refresh the `.desktop` entries. Use `appimg update --icon` to attempt automatic extraction when needed, or `--icon-skip` to explicitly avoid extraction.

---

### **4. `appimg setup-all`**
Runs **move** + **update** automatically.

#### Usage
```bash
appimg setup-all [--icon|--icon-skip]
```

#### Description
Equivalent to:

```bash
appimg move --all
appimg update [--icon|--icon-skip]
```

---

### **5. `appimg reset`**
Resets all AppImages.

#### Usage
```bash
appimg reset
```

#### Description
- Moves all AppImages in `~/.appimages` into `~/.appimages/tmp/`.
- Deletes all other folders inside `~/.appimages` (except `tmp` and `placeholder-icon.png`).  
- Removes all `.desktop` symlinks pointing to AppImages.  
- Removes executable permissions from AppImages in `tmp/`.  

> **After resetting:**  
> If you want to re-register your AppImages, run:

```bash
appimg setup-all
```

---

## 🧪 Example Workflow

```bash
# 1. List AppImages in Downloads
appimg ls -s ~/Downloads

# 2. Move all detected AppImages
appimg move --all

# 3. Build launchers
appimg update

# (Or do all of the above)
appimg setup-all

# 4. Reset AppImages if needed
appimg reset
appimg setup-all   # re-register AppImages
```

---

## 🛠️ Requirements

- Bash  
- Standard GNU/Linux utilities (`find`, `mv`, `ln`, etc.)  
- No third-party dependencies needed

---

## 📄 License

MIT License  
Copyright © 2025

---

## 🙌 Contributions

Pull requests & suggestions are welcome.  