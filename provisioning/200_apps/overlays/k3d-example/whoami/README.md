# whoami

## Available URLs
### ingress
This need to be routed through an non-terminating SNI aware reverse proxy
* https://whoami.k3d-example.lessingstrasse.org/

Since http can't be forwarded based on SNI because SNI is not part of http we need to resolve it manually in case of http protocol
* http://whoami.k3d-example.lessingstrasse.org:9080/

`curl --resolve whoami.k3d-example.lessingstrasse.org:9080:127.0.0.1 http://whoami.k3d-example.lessingstrasse.org:9080/`

### ingress local ip
* https://whoami.10.10.10.2.nip.io:9443/
* http://whoami.10.10.10.2.nip.io:9080/

### ingress localhost
* https://whoami.127.0.0.1.nip.io:9443/
* http://whoami.127.0.0.1.nip.io:9080/

