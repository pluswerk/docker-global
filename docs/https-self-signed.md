# HTTPS/SSL encryption

## Self-Signed Certificate

### Create a Self-Signed Certificate

To use a self-signed certificate, a key & crt file must be created and stored in Docker-Global:

```bash
sudo mkdir -p .docker/data/global-nginx-proxy/certs
sudo openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -keyout .docker/data/global-nginx-proxy/certs/default.key \
    -out .docker/data/global-nginx-proxy/certs/default.crt
```

If you want you can create several certificates.
The nginx proxy retrieves the information as to what the file should be called from the host name or the specified certificate in the other container.

For example, if the domain name is "chat.example.vm", then these files are searched for one after the other:

* chat.example.vm.crt & chat.example.vm.key
* example.vm.crt & example.vm.key
* vm.crt & vm.key
* default.crt & default.key

As you can see, this is like a wildcard system.

### Configure Docker-Global Setup

So that the Nginx proxy can read the certificates and deliver the website via https, you must configure the following in the docker-global setup.

Add port 443 and one path for the certificates in the docker-compose.yml file.

```yaml
global-nginx-proxy:
  ports:
    - "443:443"
  volumes:
    - ./.docker/data/global-nginx-proxy/certs:/etc/nginx/certs:ro
```

### Configure a Self-Signed Certificate in website container (php-dev)

However, if you have a regular expression in your hostname (VIRTUAL_HOST), it will not work anymore.
In this case you have to specify the certificate yourself.

* CERT_NAME=chat.example.vm
* CERT_NAME=example.vm
* CERT_NAME=vm
* CERT_NAME=default

I simply recommend a default certificate (CERT_NAME=default) for development.

### Nginx-Proxy is not on default port

If your nginx-proxy is not on the standard port 443, then you have to disable the port 80 redirect.
You can specify this with an environment variable in your website container.

* HTTPS_METHOD=noredirect

Instead of a http redirect to https, the website is simply output without encryption.
