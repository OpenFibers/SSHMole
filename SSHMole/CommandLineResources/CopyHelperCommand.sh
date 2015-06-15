#!/bin/sh

cd `dirname "${BASH_SOURCE[0]}"`

helper_dir_path="$HOME/Library/Containers/openthread.SSHMole/"
helper_name="SSHMoleSystemConfigurationHelper"
helper_path="$helper_dir_path$helper_name"

sudo mkdir -p $helper_dir_path
sudo cp SSHMoleSystemConfigurationHelper $helper_dir_path
sudo chown root:admin $helper_path
sudo chmod +s $helper_path
