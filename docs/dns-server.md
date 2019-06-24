# DNS Server (example.vm)

You can use DNS Server for the example.vm domains to work.
IP address (192.168.56.101) must be adapted for the current environment.
If you use Docker on the localhost, the IP is ``127.0.0.1`` .

## Linux installation

Some information about dnsmasq:

In the file ``/etc/dnsmasq.d/development`` you can add as many addresses as you want.

In the first example, all domains ending with .vm will be redirected to the IP address 192.168.56.101. (example.vm, sub2.example.vm, sub2.sub1.example.vm, ...)

As you can see, this depends more on your network configuration.

```bash
# Redirect *.vm domains to 192.168.56.101 (Other IP, Virtual Machine)
address=/.vm/192.168.56.101

# Redirect *.vm domains to 127.0.0.1 (Local system)
address=/.vm/127.0.0.1

# Redirect *.vm23.iveins.de domains to 127.0.0.1 (Another domain)
address=/.vm23.iveins.de/127.0.0.1
```

### Installation in Debian

Tested on Debian GNU/Linux 9.6 (stretch).

```Shell
sudo apt -y install resolvconf dnsmasq
sudo sh -c 'echo "address=/.vm/127.0.1.1" >> /etc/dnsmasq.d/development'
sudo sh -c 'echo "address=/.vm23.iveins.de/127.0.1.1" >> /etc/dnsmasq.d/development'
sudo systemctl restart dnsmasq
sudo resolvconf -u
```

### Installation in Ubuntu

Tested on Ubuntu Desktop 16.04 & 18.04.

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
sudo sh -c 'echo "address=/.vm23.iveins.de/192.168.56.101" >> /etc/NetworkManager/dnsmasq.d/development'
sudo systemctl restart network-manager
sudo resolvconf -u
```

## Windows installation (Acrylic DNS Proxy)

Tested on Windows 10.

Download and install: https://mayakron.altervista.org/wikibase/show.php?id=AcrylicHome

Start menu > Control Panel > Network and Internet > Network and Sharing Center > Change adapter settings

Edit network > Internet Protocol Version 4 (TCP/IPv4) > Properties > Use the following DNS server addresses:

* Preferred DNS server: 127.0.0.1

Start menu > Acrylic DNS Proxy > Acrylic UI

* File > Open Acrylic Hosts

Append with your virtual machine IP, depends on your network configuration:

```bash
# Redirect *.vm domains to 192.168.56.101 (Other IP, Virtual Machine)
192.168.56.101 /.*\.vm$

# Redirect *.vm domains to 127.0.0.1 (Local system)
127.0.0.1 /.*\.vm$

# Redirect *.vm23.iveins.de domains to 192.168.56.101 (Another domain)
192.168.56.101 /.*\.vm23\.iveins\.de$

# Redirect *.vm23.iveins.de domains to 127.0.0.1 (Local system)
127.0.0.1 /.*\.vm23\.iveins\.de$
```

Maybe you must restart the Service:

* Actions > Restart Acrylic Service
