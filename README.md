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
        icon.png
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
appimg update
```

#### Description
- Scans `~/.appimages`.
- Creates a `.desktop` launcher for each AppImage.
- Uses `icon.*` if available, otherwise uses `placeholder-icon.png`.
- Creates symlinks in `~/.local/share/applications`.

---

### **4. `appimg setup-all`**
Runs **move** + **update** automatically.

#### Usage
```bash
appimg setup-all
```

#### Description
Equivalent to:

```bash
appimg move --all
appimg update
```

### **5. `appimg reset`**
Resets All Appimages.

#### Usage
```bash
appimg reset
```

#### Description
moves all appimages in `~/.appimges` into `~/.appimages/tmp` useful if you decide to rename them again.

```bash
appimg reset
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