#!/bin/bash

# should call adb to install an apk on the Nexus 5 phone or another one.
BASEDIR="${1:-$(pwd)}"
"$BASEDIR/modules/BluetoothAssistant/install.sh"