# ansible-setup-macos

## Setup a new MacOS installation with my favorite software

This repository contains ansible playbooks to setup a mac

1. on a fresh install, create the user, i.e. my username `brian` 
1. save the script `bootstrap.sh` from this repository to your local disk. (i.e. view raw and save it)
1. run the script `bootstrap.sh` on the new MacOS installation to set it up
1. finally run `make` to get things going. 
1. have a coffee for 10-15 mins while it installs everything for you

## The parts...
`bootstrap.sh` will install Homebrew, git, pip, ansible and awscli

`make` will create a 1GB RAM Disk and run the main ansible playbooks: `playbooks/init.yml`, `playbooks/install.yml` and `playbooks/cleanup.yml`.  

This will create a temporary download directory and installation directory in the RAM Disk and install all the applications that are listed in `playbooks/apps/*.yml`. It will then setup some preferences from the `playbooks/prefs.yml` file.  Finally, `playbooks/cleanup.yml` will delete the RAM disk.  

The `Makefile` has 4 targets: `all`, `init`, `plays`, and `cleanup`.  The default target is `all`. It is intended to start the installation and configuration with a call to simpley `make` or `make all`

## TODO
1. Enable support for adding apps to accessibility and automation on the Privacy and Security settings of Preferences.  This is hard because of SIP in High Sierra and Mojaave, which makes the TCC.db database readonly and SIP protected now. 
