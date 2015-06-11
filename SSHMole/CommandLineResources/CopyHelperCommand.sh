#!/bin/sh

cd `dirname "${BASH_SOURCE[0]}"`
sudo mkdir -p "~/Library/Containers/openthread.SSHMole/"
sudo cp SSHMoleSystemConfigurationHelper "~/Library/Containers/openthread.SSHMole/"
sudo chown root:admin "~/Library/Containers/openthread.SSHMole/SSHMoleSystemConfigurationHelper"
sudo chmod +s "~/Library/Containers/openthread.SSHMole/SSHMoleSystemConfigurationHelper"
