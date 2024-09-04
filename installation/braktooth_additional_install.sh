#!/bin/bash
sudo apt-get install libpulse0 qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libc-ares-dev libssl-dev

# if won't work uncomment 
#sudo apt install g++ libglib2.0-dev libqt5multimedia5 libsnappy1v5 libsmi2ldbl libc-ares2 libnl-route-3-200  libfreetype6 graphviz libtbb-dev libxss1 libnss3 libspandsp2 libsbc1 libbrotli1 libnghttp2-14 libasound2 psmisc sshpass      libpulse0 libasound2 libpcre2-dev -y

pyenv activate bluekit-venv-3.12
cd "/usr/share/BlueToolkit/modules/tools/braktooth/release"
sudo python3 firmware.py flash /dev/ttyUSB1
cd "/usr/share/BlueToolkit/modules/tools/braktooth"
tar -I zstd -xf wdissector.tar.zst
cd "/usr/share/BlueToolkit/modules/tools/braktooth/wdissector"
cat ./requirements.sh | sed -e 's/qt5-default//' > ./requirements2.sh
chmod +x ./requirements2.sh
sudo ./requirements2.sh
