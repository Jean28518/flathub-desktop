# Flathub Desktop
Unofficial Desktop Client for Flathub

# How to build and run:
- You need flutter, gtk, curl, python3 and pip3 installed on linux
- `pip3 install flask flask_cors`
- `mkdir mkdir deploy/frontend`
- `cd flutter`
- `flutter build linux`
- `cd ..`
- `cp -r flutter/build/linux/x64/release/bundle/* ../deploy/frontend/`
- `./deploy/flathub_manager`
