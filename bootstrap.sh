#!/bin/bash

## Bootstrap the installation of ansible on MacOS so that I can continue
## full provisioning with Ansible

NAME="Example User"
EMAIL="user@example.com"

# TODO get USER and EMAIL from any existing .gitconfig, and prompt the user with these defaults

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
git config --global user.name "${NAME}"
git config --global user.email "${EMAIL}"
echo OK

# unshallow homebrew for updates
HOMEBREW_LIBRARY="/usr/local/Homebrew/Library"
if [[ -d "$HOMEBREW_LIBRARY" ]]; then
  echo "checking for shallow clones in homebrew..."
  if [[ -f "$HOMEBREW_LIBRARY/Taps/homebrew/homebrew-core/.git/shallow" ]]; then
    echo "Unshallowing homebrew-core ... "
    git -C "$HOMEBREW_LIBRARY/Taps/homebrew/homebrew-core" fetch --unshallow
  fi
  if [[ -f "$HOMEBREW_LIBRARY/Taps/homebrew/homebrew-cask/.git/shallow" ]]; then
    echo "Unshallowing homebrew-cask ... "
    git -C "$HOMEBREW_LIBRARY/Taps/homebrew/homebrew-cask" fetch --unshallow
  fi
fi

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

# Pygments
sudo easy_install Pygments

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
