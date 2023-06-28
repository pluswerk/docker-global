#!/bin/bash
set -e

read -p "What is your name (Format like this: Matthias Vogel): " NAME
read -p "What is your email address (Format like this: m.vogel@andersundsehr.com): " EMAIL
read -p "What is your TLD_DOMAIN https://jira.pluswerk.ag/wiki/display/AUSW/VM+Nummern (Format like this: vm23.iveins.de): " TLD_DOMAIN
read -p "DNS_CLOUDFLARE_API_KEY: " DNS_CLOUDFLARE_API_KEY
read -p "SLACK_TOKEN: " SLACK_TOKEN
read -p "SENTRY_DSN: " SENTRY_DSN

# if ed25519 is supported, enable this:
#if [ ! -f /home/user/.ssh/id_ed25519 ]; then
#  ssh-keygen -t ed25519 -a 100 -C "$EMAIL" -f /home/user/.ssh/id_ed25519 -N=
#  echo "add your SSH key to https://github.com/settings/ssh/new and https://bitbucket.org/account/settings/ssh-keys/"
#  echo ""
#  echo "public key:"
#  cat /home/user/.ssh/id_ed25519.pub
#  read -p "Press any key to continue... " -n1 -s
#  echo ""
#fi
if [ ! -f /home/user/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f /home/user/.ssh/id_rsa -N=
  echo "add your SSH key to https://github.com/settings/ssh/new and https://bitbucket.org/account/settings/ssh-keys/"
  echo ""
  echo "public key:"
  cat /home/user/.ssh/id_rsa.pub
  read -p "Press any key to continue... " -n1 -s
  echo ""
fi

echo "now you can wait for the install finishing..."


echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER 1> /dev/null

git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

# install docker
if [ ! command -v docker &> /dev/null ]; then
  curl -fsSL https://get.docker.com/ | sudo sh
fi
sudo usermod -aG docker $USER
if [ ! -f /etc/docker/daemon.json ]; then
  echo '{"log-driver": "local", "log-opts": {"max-size": "10m"}}' | sudo tee /etc/docker/daemon.json 1> /dev/null
  sudo systemctl restart docker
fi

echo '#!/bin/bash' | sudo tee /usr/local/bin/docker-compose 1> /dev/null
echo 'docker compose "${@:1}"' | sudo tee -a /usr/local/bin/docker-compose 1> /dev/null
sudo chmod +x /usr/local/bin/docker-compose

#setup default configs:
if [ ! -f ~/.composer/auth.json ]; then
  echo '{}' > ~/.composer/auth.json
fi

if grep -Fxq 'if [ $(dirs +0) == "~" ]; then' ~/.bashrc ; then
  # nothing
  echo ""
else
  echo 'if [ $(dirs +0) == "~" ]; then' >> ~/.bashrc
  echo '  cd ~/www/project' >> ~/.bashrc
  echo 'fi' >> ~/.bashrc
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

echo "wait for ~1min"
sleep 60
echo "start https://dozzle.vm$VM_NUMBER.iveins.de and check if it is working"
