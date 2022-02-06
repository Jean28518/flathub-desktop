# Flathub Desktop
Unofficial Desktop Client for Flathub

![Bildschirmfoto vom 2022-02-04 17-04-28](https://user-images.githubusercontent.com/39700889/152561868-b5cfff7f-4ffc-4283-871c-710421f3f9e5.png)

# How to build and run:
- You need flutter, gtk, curl, python3 and pip3 installed on linux
    - Ubuntu based systems: `sudo apt install snapd python3 python3-pip curl && sudo snap install flutter`
- `pip3 install flask flask_cors`
- `mkdir deploy/frontend`
- `cd flutter`
- `flutter build linux`
- `cd ..`
- `cp -r flutter/build/linux/x64/release/bundle/* ../deploy/frontend/`
- `./deploy/flathub_manager`
