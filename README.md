## PromVPS
a full-featured https server

### Features
* tls1.3 + http2 + quic
* autocert(Let's Encrypt) support
* plain http2 support
* tls termination
* sni routing
* forward chain
* global dns cache
* custom dns server support
* dns over tls support
* hosts file support
* flexible auth
* outbound ip address support
* tls prober mitigation
* pac file with china_ip_list
* country/region bypass rules
* traffic metrics
* pprof/expvar handler
* graceful reload

### Installation
```
curl -L git.io/get-promvps | bash
```

### Configuraion
see [example.toml](example.toml)

### Tuning
see [sysctl.conf](https://phuslu.github.io/sysctl.conf)

### Build
```
# bootstrap go from https://github.com/phuslu/go
go list -deps | egrep '^[^/]+\.[^/]+/' | xargs -n1 -i go get -u -v {}
go build -v
```
