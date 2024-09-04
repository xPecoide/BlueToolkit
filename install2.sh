#!/bin/bash

# Instalar dependencias necesarias
sudo apt-get install -y build-essential bluez bluetooth libbluetooth-dev pulseaudio-module-bluetooth zstd unzip liblzma-dev libcairo2-dev libgirepository1.0-dev libbluetooth-dev libdbus-1-dev bluez-tools python3-cairo-dev rfkill meson patchelf bluez ubertooth adb python-is-python3 git libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget binutils-arm-linux-gnueabi openjdk-17-jdk openjdk-17-jre android-sdk-platform-tools

# Instalar pyenv para gestionar las versiones de Python
curl https://pyenv.run | bash

# Configurar pyenv automáticamente
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT/bin ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# Recargar el entorno para que los cambios tengan efecto sin reiniciar la terminal
exec "$SHELL"

# Instalar versiones de Python 3.10 y 3.12
pyenv install 3.10.0
pyenv install 3.12.0

# Crear entornos virtuales para ambas versiones de Python
pyenv virtualenv 3.10.0 bluekit-venv-3.10
pyenv virtualenv 3.12.0 bluekit-venv-3.12

# Definir BASEDIR dinámico, por defecto es $HOME/BlueToolkit si no se especifica otra ruta
BASEDIR="${1:-$HOME/BlueToolkit}"
mkdir -p "$BASEDIR"
sudo chown $USER:$USER "$BASEDIR"

# Configurar adaptador Bluetooth
sudo killall pulseaudio
pulseaudio --start
sudo systemctl restart bluetooth

# Clonar el repositorio de bluekit
git clone https://github.com/sgxgsx/bluekit.git "$BASEDIR/bluekit"

# Crear los directorios necesarios
mkdir "$BASEDIR/bluekit/.logs"
mkdir -p "$BASEDIR/modules/tools"

# Activar el entorno virtual de Python 3.10 para bluekit
pyenv activate bluekit-venv-3.12
python3 -m pip install --upgrade pip setuptools wheel pure-python-adb pwntools cmd2 pyelftools scapy psutil tqdm tabulate colorama 2to3 pyyaml
# Instalar pybluez
python3 -m pip install git+https://github.com/pybluez/pybluez.git#egg=pybluez

# Instalar bluekit, herramientas en módulos y BluetoothAssistant
# Necesita acceso al teléfono, debe de estar conectado.
cd "$BASEDIR/bluekit/"
pip install .
cd "$BASEDIR/modules"
git clone https://github.com/sgxgsx/BluetoothAssistant "$BASEDIR/modules/BluetoothAssistant"
cd "$BASEDIR/modules/BluetoothAssistant"
chmod +x "$BASEDIR/modules/BluetoothAssistant/install.sh"
"$BASEDIR/modules/BluetoothAssistant/install.sh"

# Bdaddr
git clone https://github.com/thxomas/bdaddr "$BASEDIR/modules/bdaddr"
cd "$BASEDIR/modules/bdaddr"
make

# Herramientas en modules/tools
cd "$BASEDIR/modules/tools"

# Instalar braktooth
wget https://github.com/Matheus-Garbelini/braktooth_esp32_bluetooth_classic_attacks/releases/download/v1.0.1/release.zip -O braktooth.zip
mkdir "$BASEDIR/modules/tools/braktooth"
cd "$BASEDIR/modules/tools/braktooth"
unzip ../braktooth.zip
rm -f ../braktooth.zip
unzip esp32driver.zip

# Instalar bluing utilizando el entorno virtual de pyenv
mkdir "$BASEDIR/modules/tools/bluing"
cd "$BASEDIR/modules/tools/bluing"

# Crear entorno virtual bluing con Python 3.10 usando pyenv
pyenv activate bluekit-venv-3.10
python -m venv bluing
source bluing/bin/activate

# Instalar dependencias en el entorno bluing
python -m pip install --upgrade pip venv setuptools wheel
python -m pip install dbus-python==1.2.18
python -m pip install --no-dependencies bluing PyGObject docopt btsm btatt bluepy configobj btl2cap pkginfo xpycommon halo pyserial bthci btgatt log_symbols colorama spinners six termcolor

# Volver al entorno virtual de bluekit (Python 3.12)
pyenv activate bluekit-venv-3.12

# Instalar BLUR
cd "$BASEDIR/modules/tools"
git clone https://github.com/francozappa/blur

# Instalar blueborne, bleedingteeth, custom_exploits
git clone https://github.com/sgxgsx/bluetoothexploits "$BASEDIR/modules/tools/blueexploits"
cp -R "$BASEDIR/modules/tools/blueexploits/custom_exploits" "$BASEDIR/modules/tools/custom_exploits"
cp -R "$BASEDIR/modules/tools/blueexploits/bleedingtooth" "$BASEDIR/modules/tools/bleedingtooth"
cp -R "$BASEDIR/modules/tools/blueexploits/blueborne" "$BASEDIR/modules/tools/blueborne"
cp -R "$BASEDIR/modules/tools/blueexploits/hi_my_name_is_keyboard" "$BASEDIR/modules/tools/hi_my_name_is_keyboard"
rm -rf "$BASEDIR/modules/tools/blueexploits"

# Instalar internalblue
git clone https://github.com/seemoo-lab/internalblue "$BASEDIR/modules/tools/internalblue"
python -m pip install https://github.com/seemoo-lab/internalblue/archive/master.zip

# Modificar archivos de InternalBlue
cp "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect.py" "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect_0a_00.py"
cp "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect.py" "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect_16_0b.py"
cp "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect.py" "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect_20_17.py"
rm -f "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect.py"

# Ajustar parámetros
sed -i 's/LMP_VSC_CMD_START = 0x0f/LMP_VSC_CMD_START = 0x0a/' "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect_0a_00.py"
sed -i 's/LMP_VSC_CMD_END = 0x06/LMP_VSC_CMD_END = 0x00/' "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect_0a_00.py"
sed -i 's/LMP_VSC_CMD_START = 0x0f/LMP_VSC_CMD_START = 0x16/' "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect_16_0b.py"
sed -i 's/LMP_VSC_CMD_END = 0x06/LMP_VSC_CMD_END = 0x0b/' "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect_16_0b.py"
sed -i 's/LMP_VSC_CMD_START = 0x0f/LMP_VSC_CMD_START = 0x20/' "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect_20_17.py"
sed -i 's/LMP_VSC_CMD_END = 0x06/LMP_VSC_CMD_END = 0x17/' "$BASEDIR/modules/tools/internalblue/examples/nexus5/CVE_2018_19860_Crash_on_Connect_20_17.py"

# Instalar blueborne CVE
cd "$BASEDIR/modules/tools/blueborne"
git clone https://github.com/sgxgsx/blueborne-CVE-2017-1000251 "$BASEDIR/modules/tools/blueborne/blueborne-CVE-2017-1000251"

# Compilar blueborne CVE
cd "$BASEDIR/modules/tools/blueborne/blueborne-CVE-2017-1000251"
gcc -o blueborne_cve_2017_1000251 blueborne.c -lbluetooth

# Establecer permisos en el BASEDIR
sudo chown -R $USER:$USER "$BASEDIR"
