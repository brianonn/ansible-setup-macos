#!/bin/bash

## Bootstrap the installation of ansible on MacOS so that I can continue 
## full provisioning with Ansible

USERNAME="Brian Onn"
EMAIL="brian.a.onn@gmail.com"

tmpdir=$(mktemp -d)
function cleanup {
    rm -rf "$tmpdir"
}

trap cleanup EXIT

# homebrew
echo -n "Checking for HomeBrew ... "
if [[ -z $(which brew) ]]; then
  echo -n "installing ..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
echo OK

# git 
echo -n "Checking for git ... "
if [[ -z $(which git) ]]; then
  echo -n "installing ..."
  brew install git
fi
git config --global user.name "${USERNAME}"
git config --global user.email "${EMAIL}"
echo OK

# pip 
echo -n "Checking for pip ... "
if [[ -z $(which pip) ]]; then
  echo -n "installing ..."
  curl https://bootstrap.pypa.io/get-pip.py -o "${tmpdir}/get-pip.py"
  sudo python "${tmpdir}/get-pip.py"

fi
echo OK

# ansible 
echo -n "Checking for ansible ... "
if [[ -z $(which ansible) ]]; then
  echo -n "installing ..."
  sudo -H pip install ansible  
fi
echo OK

# awscli 
echo -n "Checking for awscli ... "
if [[ -z $(which aws) ]]; then
  echo -n "installing ..."
  pip install nose tornado --user 
  pip install awscli --user 
fi
echo OK

rcchanged=0

## update $HOME/.bashrc to include Python user files
Python_Version="$(python -V 2>&1)"
Python_Version=${Python_Version:7:4}
Python_Version=${Python_Version%.}
[[ ! -s $HOME/.bashrc ]] && touch $HOME/.bashrc 
if [[ -z "$(egrep 'PATH=.*HOME/Library/Python' "$HOME/.bashrc" 2>/dev/null )" ]] ; then 
  cat >> $HOME/.bashrc <<!EOF!
PATH="\$HOME/Library/Python/${Python_Version}/bin:\$PATH"
!EOF!
rcchanged=1
fi 

# iTerm is weird, it sources .profile. Make .profile source bashrc 
[[ ! -s $HOME/.profile ]] && touch $HOME/.profile
if [[ -z "$(egrep 'source.*bashrc' $HOME/.profile 2>/dev/null )" ]] ; then 
    cat >> $HOME/.profile <<!EOF!
[[ -s \$HOME/.bashrc ]] && source \$HOME/.bashrc
!EOF!
rcchanged=1
fi 

[[ ${rcchanged} = 1 ]] && {
    echo "=========================================================="
    echo "You must exit this terminal session and start a new one to"
    echo "get the newest PATH for the next steps with Ansible"
    echo "=========================================================="
    echo
}
