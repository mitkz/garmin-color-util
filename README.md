# garmin-color-util

A Connect IQ app for previewing colors on the Garmin vivoactive 5 OLED display.

## Features

- Independently set the foreground (square) color and background color
- FG and BG RGB values are displayed at the top of the screen
- The currently selected channel is highlighted with a rectangle
- Tap the center square to cycle through channels: `FG R` → `FG G` → `FG B` → `BG R` → `BG G` → `BG B`
- Tap above the square: selected value `+20`
- Tap below the square: selected value `-20`
- Tap left of the square: selected value `-1`
- Tap right of the square: selected value `+1`
- Values are clamped to `0..255`
- Press the action (enter) button to exit the app
- Swipe-back gesture is disabled to prevent accidental exits

## Build

Install the Connect IQ SDK, then run:

```powershell
./deploy.ps1 -Action Build
```

Or build manually:

```bash
monkeyc -f monkey.jungle -d vivoactive5 -o bin/ColorFinder.prg -y /path/to/developer_key
```

## Deploy

To build and deploy to a connected device via MTP:

```powershell
./deploy.ps1
```

## Run

- Load the `.prg` file in the Connect IQ Simulator with the `vivoactive5` device
- Or transfer to the device for on-hardware testing