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
* china whitelist pac script
* country/region bypass rules
* multi-dimensional traffic metrics
* pprof handler
* graceful reload

### Installation
```
curl -L git.io/get-promvps | bash
```
NOTE: If nginx/apache was alrady installed, change its listen port to 81 then restart it, promvps will proxy_pass to the 81 port

### Configuraion
see [promvps.toml](promvps.toml)

### Build
```
# bootstrap go from https://github.com/phuslu/go
gawk 'match($1, /"((github\.com|golang\.org)\/.+)"/) {if (!seen[$1]++) {gsub("\"", "", $1); print $1}}' $(find . -name "*.go") | xargs -n1 -i go get -u -v {}
go build -v
```
