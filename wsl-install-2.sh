#!/bin/bash
set -e

if [ id -nG | grep docker ]; then
  # restart script with docker group:
  echo 'Please run wsl-install-1.sh first!!!'
  exit 1
fi

mkdir -p ~/www/global
mkdir -p ~/www/project

cd ~/www/global/


if [ -f .env ]; then
  . .env
fi

NAME=$(git config --global user.name || true)
EMAIL=$(git config --global user.email || true)

git config --global init.defaultBranch main

if [ -z "$NAME" ]; then
  read -p "What is your name (Format like this: Matthias Vogel): " NAME
  git config --global user.name "$NAME"
fi
if [ -z "$EMAIL" ]; then
  read -p "What is your email address (Format like this: m.vogel@andersundsehr.com): " EMAIL
  git config --global user.email "$EMAIL"
fi
if [ -z "$TLD_DOMAIN" ]; then
  read -p "What is your TLD_DOMAIN https://jira.pluswerk.ag/wiki/display/AUSW/VM+Nummern (Format like this: vm23.iveins.de): " TLD_DOMAIN
  echo "TLD_DOMAIN=$TLD_DOMAIN" >> .env
  echo "HTTPS_MAIN_DOMAIN=$TLD_DOMAIN" >> .env
fi
if [ -z "$DNS_CLOUDFLARE_API_TOKEN" ]; then
  read -p "DNS_CLOUDFLARE_API_TOKEN: " DNS_CLOUDFLARE_API_TOKEN
  echo "DNS_CLOUDFLARE_API_TOKEN=$DNS_CLOUDFLARE_API_TOKEN" >> .env
fi
if [ -z "$SENTRY_DSN" ]; then
  read -p "SENTRY_DSN: " SENTRY_DSN
  echo "SENTRY_DSN=$SENTRY_DSN" >> .env
fi

if [ ! -f /home/user/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -a 100 -C "$EMAIL" -f /home/user/.ssh/id_ed25519 -N ''
  echo "add your SSH key to https://github.com/settings/ssh/new and https://bitbucket.org/account/settings/ssh-keys/"
  echo ""
  echo "public key:"
  cat /home/user/.ssh/id_ed25519.pub
  read -p "Press any key to continue... " notUsed
  echo ""
fi
if [ ! -f /home/user/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f /home/user/.ssh/id_rsa -N ''
  echo "add your SSH key to https://github.com/settings/ssh/new and https://bitbucket.org/account/settings/ssh-keys/"
  echo ""
  echo "public key:"
  cat /home/user/.ssh/id_rsa.pub
  read -p "Press any key to continue... " notUsed
  echo ""
fi

# make user sudo without password.
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER 1> /dev/null


# install wudo
if ! [ -x "$(command -v wudo)" ]; then
  curl -fsSL https://raw.githubusercontent.com/Chronial/wsl-sudo/master/wsl-sudo.py | sudo tee /usr/local/bin/wudo 1> /dev/null
  sudo chmod +x /usr/local/bin/wudo
fi
# install inotify
if ! [ -x "$(command -v inotifywait)" ]; then
  sudo apt update -y
  sudo apt install inotify-tools -y
fi

# install docker
if ! [ -x "$(command -v docker)" ]; then
  curl -fsSL https://get.docker.com/ | sudo sh
fi

# configure docker
if [ ! -f /etc/docker/daemon.json ]; then
  echo '{"log-driver": "local", "log-opts": {"max-size": "10m"}}' | sudo tee /etc/docker/daemon.json 1> /dev/null
  sudo systemctl restart docker
fi

# configure composer
if [ ! -f ~/.composer/auth.json ]; then
  mkdir -p ~/.composer/cache
  rm -rf ~/.composer/auth.json
  echo '{}' > ~/.composer/auth.json
fi

# clone global
if [ ! -d .git ]; then
  git clone --no-checkout git@github.com:pluswerk/docker-global.git ./a
  mv ./a/.git ./
  rm -r a
  git restore --staged .
  git restore .
fi

# make docker-compose work
if [ ! -f /usr/local/bin/docker-compose ]; then
  sudo ln -s $(pwd)/bin/docker-compose /usr/local/bin/docker-compose
fi

function addOnceToFile() {
  if [ ! -f $1 ]; then
    touch $1
  fi
  if ! grep -Fxq "$2" $1
  then
    echo "$2" | sudo tee -a $1 1> /dev/null
  fi
}

# install bashrc files
addOnceToFile ~/.bashrc 'source ~/www/global/bashrc-files/.bashrc-ssh-agent'
addOnceToFile ~/.bashrc 'source ~/www/global/bashrc-files/.bashrc-cd'
addOnceToFile ~/.bashrc 'source ~/www/global/bashrc-files/.bashrc-windows-hosts-sync'

# configure wsl
addOnceToFile /etc/wsl.conf '[network]'
addOnceToFile /etc/wsl.conf 'generateHosts = false'

# run hosts file sync now
source bashrc-files/.bashrc-windows-hosts-sync

if ! ssh root@20.13.155.71 -p221 echo '1' 1> /dev/null ; then
  echo 'ask a colleague to add your SSH Key to the vm-proxy'
  read -p "Press any key to continue... " -n1 -s
  ssh root@20.13.155.71 -p221 echo '1'
fi

#start docker global
bash start.sh pull
bash start.sh up

echo "wait for 30s (to create certificates)"
sleep 30
echo "start https://dozzle.$TLD_DOMAIN and check if it is working"
