# linux-assistant

A linux application which is a daily linux helper with powerful integrated search, routines checks and admninistrative tasks. The Project is built with flutter and python.

## Requirements

```bash
sudo apt install keybinder-3.0 
sudo apt install libkeybinder-3.0-0 libkeybinder-3.0-dev # For debian 11, Ubuntu 22.04, ...

sudo apt install wmctrl
```

## Build

```bash
# Install keybinder, see requirements
sudo rm /etc/apt/preferences.d/nosnap.pref # (For Linux Mint)
sudo apt install snapd git
sudo snap install flutter --classic
flutter doctor # If command not found: Reboot and try again
git clone https://github.com/Jean28518/linux-assistant.git
cd linux-assistant

# Option 1: Build with flutter manually
flutter build linux
chmod +x additional/python/run_script.py
cp -r additional build/linux/x64/release/bundle/
cd build/linux/x64/release/bundle/
./linux_assistant

# Option 2: Build .deb and install .deb package:
bash ./build-deb.sh
sudo dpkg --install linux-assistant.deb

# Option 3: Build .rpm package:
bash ./build-rpm.sh

# Option 3: Build Arch package
# You can only do this on an arch based distro
bash ./build-arch-pkg.sh
# To Install:
sudo pacman -U linux-assistant-*.pkg.tar.zst
```

## Run as flatpak

Repo: <https://github.com/Jean28518/flathub/tree/com.github.jean28518.Linux-Assistant>

- Uncomment the archive from the web and use e.g. this local one:

```yaml
      - type: archive
        path: /path/to/linux-assistant-bundle.zip
```

```bash
flatpak install runtime/org.freedesktop.Sdk/x86_64/23.08

rm -r .flatpak-builder/ # Only if you built something before.
flatpak-builder build-dir io.github.jean28518.Linux-Assistant.yml  --user --force-clean --install 
flatpak run io.github.jean28518.Linux-Assistant
```

## Features

<https://github.com/Jean28518/linux-assistant/blob/main/features.csv>

## Current Languages

- English
- German
- Italian

## Mission

<https://github.com/Jean28518/linux-assistant/blob/main/MANIFEST.md>

## Development

```bash
# Install flutter

flutter run
```
