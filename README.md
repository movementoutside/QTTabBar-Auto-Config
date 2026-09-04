# QTTabBar Auto Config

A small AutoHotkey v2 utility that automatically switches between **Light** and **Dark** QTTabBar configurations when the Windows app theme changes.

The script checks the Windows theme every five seconds and imports the matching QTTabBar XML configuration.

## Features

- Detects Windows Light/Dark app theme changes automatically.
- Loads a separate QTTabBar configuration for each theme.
- Uses relative paths, so no personal or machine-specific paths are required.
- Works with AutoHotkey v2.
- Does not change Windows theme settings; it only reads the current theme state.

## Requirements

- Windows 10 or Windows 11.
- [AutoHotkey v2](https://www.autohotkey.com/).
- QTTabBar installed and configured.
- Two QTTabBar configuration files exported as XML.

## Setup

1. Export your preferred Light and Dark configurations from QTTabBar.
2. Place both XML files inside the `config` folder.
3. Name them exactly:

```text
QTTabBarConfig Light.xml
QTTabBarConfig Dark.xml
```

The project should look like this:

```text
qttabbar-auto-config/
├── qttabbar_auto_config.ahk
├── config/
│   ├── QTTabBarConfig Light.xml
│   └── QTTabBarConfig Dark.xml
└── README.md
```

4. Open a File Explorer window.
5. Run `qttabbar_auto_config.ahk`.

The script will monitor the Windows app theme and import the corresponding QTTabBar profile whenever the theme changes.

## Important note

QTTabBar's options interface can vary between versions and custom setups. This script currently navigates to the **Import now...** control using keyboard input. If the QTTabBar UI changes, the number of `Tab` presses in the script may need to be adjusted.

The `Alt+O` shortcut must also open QTTabBar options in your setup.

## Configuration files and privacy

The XML files in `config/` are intentionally excluded from this repository by default because QTTabBar exports may contain user-specific paths or preferences. Export and review your own configurations before publishing them.

## How it works

Windows stores the app-theme state in:

```text
HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize
```

The script reads `AppsUseLightTheme` and chooses the matching QTTabBar XML file.

## License

A license can be added before public release depending on the intended reuse policy.

## Import-button detection

The script locates QTTabBar's **Import now...** control by its exposed button text instead of relying on a fixed number of Tab key presses. If that control cannot be identified, the script stops without clicking another button. This avoids accidentally activating controls such as **Download update now**.
