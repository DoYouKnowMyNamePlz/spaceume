# Spaceume

A Plasma 6 panel spacer that controls audio volume via scroll wheel and middle-click.

Spaceume adds an expandable spacer to your KDE Plasma panel. When hovered, scrolling changes the system volume and middle-click toggles mute. It also supports configurable left/middle/right click actions (Show Desktop, Overview, Grid View, Expose, Run Command, etc.).

Originally based on [plasmoid-spacer-as-pager by eatsu](https://github.com/eatsu/plasmoid-spacer-as-pager). Attribution: [eatsu on KDE Store](https://store.kde.org/u/eatsu) and [plasmoid-spacer-as-pager on GitHub](https://github.com/eatsu/plasmoid-spacer-as-pager).

## Features

- Expandable panel spacer (takes all available space or fixed length)
- Scroll up/down to raise/lower volume (only when hovered)
- Middle-click to toggle mute (only when hovered)
- Configurable click actions for left, middle, and right mouse buttons
- Optional command execution on click
- Configuration via right-click → Configure Spaceume

## Screenshot

![Spaceume Volume Control](Spaceume-Volume.png)

## Installation

### Option 1: Install from the KDE Store (recommended)

Open Plasma's **Add Widgets** dialog, click **Get New Widgets**, search for **Spaceume**, and install it.

### Option 2: Manual install from this repository

1. Download or clone this repository.
2. Run the install script:

   ```bash
   chmod +x install.sh
   ./install.sh
   ```

   This copies the plasmoid to `~/.local/share/plasma/plasmoids/com.github.DoYouKnowMyNamePlz.spaceume/`.

3. Add Spaceume to your panel:
   - Right-click your panel → **Add Widgets**
   - Search for **Spaceume** and add it

### Option 3: Install with kpackagetool6

```bash
kpackagetool6 -t Plasma/Applet -i package/
```

To remove:

```bash
kpackagetool6 -t Plasma/Applet -r com.github.DoYouKnowMyNamePlz.spaceume
```

## Configuration

Right-click the Spaceume spacer on your panel and select **Configure Spaceume** to adjust:

- **Appearance**: expanding mode, fixed length
- **Behavior**: enable volume control, volume step, click actions and commands for left/middle/right clicks

## Building the .plasmoid package

From the repository root:

```bash
cd package
python3 -c "
import zipfile, os
with zipfile.ZipFile('../spaceume-1.0.0.plasmoid', 'w', zipfile.ZIP_DEFLATED) as z:
    for root, dirs, files in os.walk('.'):
        for f in files:
            p = os.path.join(root, f)
            z.write(p, p.lstrip('./'))
"
```

This produces `spaceume-1.0.0.plasmoid`, which can be uploaded to the KDE Store or installed with `kpackagetool6`.

## Requirements

- KDE Plasma 6
- `pactl` (PipeWire/PulseAudio) for volume control
- `dbus-send` and `kglobalaccel` for click shortcut actions

## License

GPL-2.0-or-later. See [LICENSE](LICENSE).

## Attribution

Originally based on [plasmoid-spacer-as-pager](https://github.com/eatsu/plasmoid-spacer-as-pager) by [eatsu](https://store.kde.org/u/eatsu).
