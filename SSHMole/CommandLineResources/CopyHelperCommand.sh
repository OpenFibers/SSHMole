#!/bin/sh

cd `dirname "${BASH_SOURCE[0]}"`
sudo mkdir -p "~/Library/Application Support/SSHMole/"
sudo cp SSHMoleSystemConfigurationHelper "~/Library/Application Support/SSHMole/"
sudo chown root:admin "~/Library/Application Support/SSHMole/SSHMoleSystemConfigurationHelper"
sudo chmod +s "~/Library/Application Support/SSHMole/SSHMoleSystemConfigurationHelper"
