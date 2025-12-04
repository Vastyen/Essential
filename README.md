# Essential [Open Source]

**Essential** is a powerful macOS clipboard manager that runs seamlessly from your menu bar. Keep track of everything you copy, take screenshots directly to your clipboard, and access your clipboard history instantly with global hotkeys.

## Features

### 📋 Clipboard History
- **Automatic tracking**: Monitors your clipboard every 0.5 seconds
- **150 item limit**: Maintains a FIFO (First In, First Out) queue of your clipboard entries
- **Text & images**: Supports both text and screenshot entries
- **Quick access**: Search through your clipboard history instantly
- **Smart filtering**: Avoids duplicate entries automatically

### 📸 Screenshot Capture
- **Full screen**: Capture entire screen to clipboard with `⌘⇧3`
- **Selection**: Capture selected area to clipboard with `⌘⇧4`
- **Instant clipboard**: Screenshots go directly to your clipboard, ready to paste
- **No files**: No cluttered desktop - everything stays in your clipboard

### ⚡ Global Hotkeys
- **`⌘⇧V`**: Toggle clipboard history popover
- **`⌘⇧3`**: Take full screen screenshot to clipboard
- **`⌘⇧4`**: Take selection screenshot to clipboard

### 🎨 Customization
- **Menu bar icons**: Choose from `</>`, `⌘`, or `⌥` icons
- **Change anytime**: Right-click the menu bar icon to switch icons
- **Clean design**: Minimalist interface that stays out of your way

### 🚀 Always Available
- **Launch at login**: Automatically starts when your Mac boots
- **Menu bar only**: No dock icon - runs quietly in the background
- **Lightweight**: Minimal resource usage

## Installation

### Option 1: Build from Source

1. Clone this repository:
   ```bash
   git clone [repository-url]
   cd Essential
   ```

2. Open the project in Xcode:
   ```bash
   open Essential.xcodeproj
   ```

3. Build and run (⌘R)

### Option 2: Download DMG

1. Download the latest `Essential.dmg` from the releases
2. Open the DMG file
3. Drag Essential.app to your Applications folder
4. Launch Essential from Applications

## First Launch

On first launch, Essential will guide you through setup:

1. **Grant Screen Recording permissions** - Required for screenshot capture
2. **Choose your menu bar icon** - Select from `</>`, `⌘`, or `⌥`
3. **Select screenshot folder** - Choose where screenshots should be saved (default: ~/Pictures)
4. **Get started** - Click "Get Started" to begin using Essential

## Permissions

Essential requires the following permissions to function:

### Screen Recording
- **Required for**: Taking screenshots with `⌘⇧3` and `⌘⇧4`
- **How to grant**: System Settings → Privacy & Security → Screen Recording → Enable Essential

### Accessibility (Optional but Recommended)
- **Required for**: Global hotkey interception (especially for `⌘⇧3` and `⌘⇧4`)
- **How to grant**: System Settings → Privacy & Security → Accessibility → Enable Essential
- **Note**: If you've disabled macOS native screenshot shortcuts, this permission helps Essential capture those hotkeys

## Usage

### Accessing Clipboard History

1. Click the Essential icon in your menu bar, OR
2. Press `⌘⇧V` (Command + Shift + V)
3. Browse or search through your clipboard history
4. Click any entry to copy it to your clipboard

### Taking Screenshots

- **Full screen**: Press `⌘⇧3` - Screenshot goes directly to clipboard
- **Selection**: Press `⌘⇧4` - Select area to capture, screenshot goes to clipboard

### Changing Menu Bar Icon

1. Right-click the Essential icon in your menu bar
2. Select "Change Icon"
3. Choose from `</>`, `⌘`, or `⌥`

### Clearing History

1. Right-click the Essential icon in your menu bar
2. Select "Clear History"

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘⇧V` | Open/close clipboard history popover |
| `⌘⇧3` | Take full screen screenshot to clipboard |
| `⌘⇧4` | Take selection screenshot to clipboard |

## Requirements

- **macOS**: 13.0 (Ventura) or later
- **Architecture**: Apple Silicon or Intel
- **Permissions**: Screen Recording (required), Accessibility (recommended)

## Troubleshooting

### Screenshots not working

1. **Check permissions**: Ensure Screen Recording permission is granted in System Settings
2. **Disable native shortcuts**: macOS native screenshot shortcuts may conflict. Go to System Settings → Keyboard → Keyboard Shortcuts → Screenshots and disable `⌘⇧3` and `⌘⇧4`
3. **Grant Accessibility**: Enable Essential in System Settings → Privacy & Security → Accessibility

### Hotkeys not responding

1. **Check Accessibility permissions**: Essential needs Accessibility permission to intercept global hotkeys
2. **Restart the app**: Quit and relaunch Essential
3. **Check for conflicts**: Ensure no other apps are using the same hotkeys

### Clipboard history not updating

1. **Check if app is running**: Look for the Essential icon in your menu bar
2. **Restart the app**: Quit and relaunch Essential
3. **Clear and retry**: Clear history from the context menu and try copying again

## Technical Details

- **Bundle Identifier**: `open.Essential`
- **Maximum History**: 150 items (FIFO queue)
- **Polling Interval**: 0.5 seconds
- **Build System**: Xcode with Swift Package Manager
- **Dependencies**: KeyboardShortcuts (by sindresorhus)

## License

[Add your license here]

## Credits

Created with ❤️ for macOS users who value efficiency and simplicity.

