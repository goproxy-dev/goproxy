## PromVPS
a full-featured https edge server

### Features
* tls1.3 + http2 + quic
* autocert(Let's Encrypt) support
* plain http2 support
* tls termination
* sni reverse proxy
* http/https/quic/socks forward chain
* global dns cache
* dns over tls support
* custom dns server support
* hosts file support
* pluggable(shell style) auth
* outbound ip address support
* whitelist PAC based on china_ip_list
* country/region bypass rules
* multi-dimensional traffic metrics
* pprof/expvar debug handler
* graceful reload

### Installation
```
curl -L git.io/get-promvps | bash
```
NOTE: Please change webserver(nginx/apache) listen port to 127.0.0.1:81 if installed, promvps will proxy_pass to them.

### Configuraion
see [promvps.toml](promvps.toml)

### Tuning
see [sysctl.conf](https://phuslu.github.io/sysctl.conf)

### Build
```
# bootstrap go from https://github.com/phuslu/go
gawk 'match($1, /"((github\.com|golang\.org)\/.+)"/) {if (!seen[$1]++) {gsub("\"", "", $1); print $1}}' $(find . -name "*.go") | xargs -n1 -i go get -u -v {}
go build -v
```
