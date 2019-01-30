# Documentation of this Setup System

## Why?

It is nice if you have many Web-Projects what you need to work on. 
It is extendable.

## How

docker

## Requirements

- docker
- nothing on port 80 or 443 or 3306

## Links:

https://github.com/pluswerk/php-dev

# Documentation

## DNS Server (example.vm)

You can use DNS Server for the example.vm domains to work.
IP address (192.168.56.101) must be adapted for the current environment.
If you use Docker on the localhost, the IP is ``127.0.0.1`` .

### DNS Server - Linux Ubuntu Desktop

```Shell
sudo apt -y install resolvconf
sudo vim /etc/NetworkManager/NetworkManager.conf
```

Append to file: /etc/NetworkManager/NetworkManager.conf

```ini
[main]
dns=dnsmasq
```

Run these commands in the shell:

```Shell
sudo sh -c 'echo "nameserver 127.0.1.1" >> /etc/resolvconf/resolv.conf.d/head'
sudo sh -c 'echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head'
sudo sh -c 'echo "address=/.vm/192.168.56.101" >> /etc/NetworkManager/dnsmasq.d/development'
sudo systemctl restart network-manager
sudo resolvconf -u
```

### Windows DNS Server (Acrylic DNS Proxy)

Download and install: http://mayakron.altervista.org/wikibase/show.php?id=AcrylicHome

Start menu > Control Panel > Network and Internet > Network and Sharing Center > Change adapter settings

Edit network > Internet Protocol Version 4 (TCP/IPv4) > Properties > Use the following DNS server addresses:

* Preferred DNS server: 127.0.0.1

Start menu > Acrylic DNS Proxy > Acrylic UI

* File > Open Acrylic Hosts

Append with your virtual machine IP:

```Text
192.168.56.101 /.*\.vm$
```

Maybe you must restart the Service:

* Actions > Restart Acrylic Service
