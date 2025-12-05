# Essential · Open Source

**Essential** is a lightweight, fast, menu-bar clipboard manager for macOS. It captures everything you copy, sends screenshots directly to your clipboard, and lets you browse your full history instantly with global shortcuts.

---

## Features

### 📋 Clipboard History

* Tracks your clipboard automatically
* Stores up to **150 items** (text + images)
* Smart deduplication
* Instant pop-over search
* Global shortcut: **`⌘⇧V`**

### 📸 Screenshot Capture

* Full screen: **`⌘⇧3`**
* Selection: **`⌘⇧4`**
* Screenshots go **directly to your clipboard**
* **Optional saving**: choose a folder where screenshots are stored (default: `~/Documents/Screenshots`)

### Preview

<img width="2932" height="2327" alt="Preview" src="https://github.com/user-attachments/assets/869f10a0-753a-429d-9380-b1f55f94b863" />

### 🎨 Customization

* Choose your menu-bar icon (`</>`, `⌘`, `⌥`)
* Select your screenshot folder anytime
* Minimal, distraction-free UI

### 🚀 Always On

* Runs from the menu bar
* Can launch at login
* Very low resource usage

---

## Installation

### Option 1: Build from Source

```bash
git clone https://github.com/Vastyen/Essential
cd Essential
open Essential.xcodeproj
```

Then build & run with **⌘R**.

### Option 2: Download App (DMG)

1. Download the latest `Essential.dmg`
2. Drag **Essential.app** into your **Applications** folder
3. **Important:** Before opening, run this command to remove macOS quarantine:

```bash
xattr -cr /Applications/Essential.app
```

4. Open Essential normally

---

## First Launch Setup

Essential will ask you for:

1. **Screen Recording permission** (for screenshots)
2. **Menu-bar icon** selection
3. **Screenshot folder** (you choose where screenshots are saved)
4. Done — you're ready to use it

---

## Permissions Needed

### Screen Recording

Required for capturing screenshots.
**System Settings → Privacy & Security → Screen Recording → Enable Essential**

### Accessibility (Recommended)

Allows Essential to intercept `⌘⇧3` / `⌘⇧4` reliably.
**System Settings → Privacy & Security → Accessibility → Enable Essential**

---

## Keyboard Shortcuts

| Shortcut  | Action                                             |
| --------- | -------------------------------------------------- |
| **`⌘⇧V`** | Open clipboard history                             |
| **`⌘⇧3`** | Full-screen capture to clipboard (+ optional save) |
| **`⌘⇧4`** | Selection capture to clipboard (+ optional save)   |

---

## Troubleshooting (Simple)

**Screenshots not working?**

* Check Screen Recording permission
* Disable the native macOS screenshot shortcuts
* Make sure Accessibility permission is enabled

**Clipboard not updating?**

* Relaunch Essential
* Clear History and try copying again

---

## Technical Info

* Bundle ID: `open.Essential`
* History limit: 150 items
* Polling: 0.5s
* Swift + SwiftPM
* Dependency: KeyboardShortcuts by Sindre Sorhus

---

## License

MIT — free and open source.

---
