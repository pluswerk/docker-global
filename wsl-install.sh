#!/bin/bash
set -e

# cat wsl-install.sh > x && chmod +x x && sh ./x ; rm x
# curl -fsSLl https://github.com/pluswerk/docker-global/raw/master/wsl-install.sh > x && chmod +x x && sh ./x ; rm x

if [ ! $(getent group docker) ]; then
  sudo groupadd docker
  sudo usermod -aG docker $USER
fi

if [ $(id -gn) != docker ]; then
  # restart script with docker group:
  exec sg docker "$0 $*"
fi

read -p "What is your name (Format like this: Matthias Vogel): " NAME
read -p "What is your email address (Format like this: m.vogel@andersundsehr.com): " EMAIL
read -p "What is your TLD_DOMAIN https://jira.pluswerk.ag/wiki/display/AUSW/VM+Nummern (Format like this: vm23.iveins.de): " TLD_DOMAIN
read -p "DNS_CLOUDFLARE_API_KEY: " DNS_CLOUDFLARE_API_KEY
read -p "SLACK_TOKEN: " SLACK_TOKEN
read -p "SENTRY_DSN: " SENTRY_DSN

if [ ! -f /home/user/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -a 100 -C "$EMAIL" -f /home/user/.ssh/id_ed25519 -N ''
  echo "add your SSH key to https://github.com/settings/ssh/new and https://bitbucket.org/account/settings/ssh-keys/"
  echo ""
  echo "public key:"
  cat /home/user/.ssh/id_ed25519.pub
  read -p "Press any key to continue... " -n1 -s
  echo ""
fi
#if [ ! -f /home/user/.ssh/id_rsa ]; then
#  ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f /home/user/.ssh/id_rsa -N ''
#  echo "add your SSH key to https://github.com/settings/ssh/new and https://bitbucket.org/account/settings/ssh-keys/"
#  echo ""
#  echo "public key:"
#  cat /home/user/.ssh/id_rsa.pub
#  read -p "Press any key to continue... " notUsed
#  echo ""
#fi

echo ""
echo "now you can wait for the install finishing..."
echo ""
echo ""

echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER 1> /dev/null

git config --global user.name "$NAME"
git config --global user.email "$EMAIL"
git config --global init.defaultBranch main

# install docker
if ! [ -x "$(command -v docker)" ]; then
  curl -fsSL https://get.docker.com/ | sudo sh
fi

if [ ! -f /etc/docker/daemon.json ]; then
  echo '{"log-driver": "local", "log-opts": {"max-size": "10m"}}' | sudo tee /etc/docker/daemon.json 1> /dev/null
  sudo systemctl restart docker
fi

echo '#!/bin/bash' | sudo tee /usr/local/bin/docker-compose 1> /dev/null
echo 'docker compose "${@:1}"' | sudo tee -a /usr/local/bin/docker-compose 1> /dev/null
sudo chmod +x /usr/local/bin/docker-compose

#setup default configs:
if [ ! -f ~/.composer/auth.json ]; then
  mkdir -p ~/.composer
  echo '{}' > ~/.composer/auth.json
fi

if grep -Fxq 'if [ -z "$SSH_AUTH_SOCK" ] ; then' ~/.bashrc ; then
  # nothing
  echo ""
else
  tee -a ~/.bashrc 1> /dev/null << 'EOF'

# Run SSH Agent and add key 7d
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  if [ -f ~/.ssh/id_rsa ]; then
    ssh-add -t 604800 ~/.ssh/id_rsa
  fi
  if [ -f ~/.ssh/id_ed25519 ]; then
    ssh-add -t 604800 ~/.ssh/id_ed25519
  fi
fi
EOF
fi

if grep -Fxq 'if [ $(dirs +0) == "~" ]; then' ~/.bashrc ; then
  # nothing
  echo ""
else
  tee -a ~/.bashrc 1> /dev/null << 'EOF'

if [ $(dirs +0) == "~" ]; then
  cd ~/www/project
fi
EOF
fi

mkdir -p ~/www/project
cd ~/www/
if [ ! -d ~/www/global ]; then
  git clone git@github.com:pluswerk/docker-global.git global
fi

cd ~/www/global/

if [ ! -f ~/www/global/.env ]; then
  echo "TLD_DOMAIN=$TLD_DOMAIN" >> ~/www/global/.env
  echo "HTTPS_MAIN_DOMAIN=$TLD_DOMAIN" >> ~/www/global/.env
  echo '' >> ~/www/global/.env
  echo 'DNS_CLOUDFLARE_EMAIL=tech@andersundsehr.com' >> ~/www/global/.env
  echo "DNS_CLOUDFLARE_API_KEY=$DNS_CLOUDFLARE_API_KEY" >> ~/www/global/.env
  echo "SLACK_TOKEN=$SLACK_TOKEN" >> ~/www/global/.env
  echo "SENTRY_DSN=$SENTRY_DSN" >> ~/www/global/.env
fi

bash start.sh start

echo "wait for 30s (to create certificates)"
sleep 30
echo "start https://dozzle.$TLD_DOMAIN and check if it is working"
