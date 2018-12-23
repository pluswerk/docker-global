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

## HTTPS/SSL encryption

### Self-Signed Certificate

#### Create a Self-Signed Certificate

To use a self-signed certificate, a key & crt file must be created:

```Shell
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -keyout .docker/config/global-nginx-proxy/certs/default.key \
    -out .docker/config/global-nginx-proxy/certs/default.crt
```

If you want you can create several certificates.
The nginx proxy retrieves the information as to what the file should be called from the host name or the specified certificate in the other container.

For example, if the domain name is "chat.example.vm", then these files are searched for one after the other:

* chat.example.vm.crt & chat.example.vm.key
* example.vm.crt & example.vm.key
* vm.crt & vm.key
* default.crt & default.key

As you can see, this is like a wildcard system.

#### Configure a Self-Signed Certificate in website container

However, if you have a regular expression in your hostname (VIRTUAL_HOST), it will not work anymore.
In this case you have to specify the certificate yourself.

* CERT_NAME=chat.example.vm
* CERT_NAME=example.vm
* CERT_NAME=vm
* CERT_NAME=default

I simply recommend a default certificate (CERT_NAME=default) for development.

#### Nginx-Proxy is not on default port

If your nginx-proxy is not on the standard port 443, then you have to disable the port 80 redirect.
You can specify this with an environment variable in your website container.

* HTTPS_METHOD=noredirect

Instead of a http redirect to https, the website is simply output without encryption.
