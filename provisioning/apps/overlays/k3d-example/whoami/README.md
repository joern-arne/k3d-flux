# whoami

## Available URLs
### ingress
* https://whoami.k3d-example.lessingstrasse.org/
  * This need to be routed through an non-terminating SNI aware reverse proxy
* http://whoami.k3d-example.lessingstrasse.org:9080/
  * `curl --resolve whoami.k3d-example.lessingstrasse.org:9080:127.0.0.1 http://whoami.k3d-example.lessingstrasse.org:9080/`

### ingress local ip
* https://whoami.10.10.10.2.nip.io:9443/
* http://whoami.10.10.10.2.nip.io:9080/

### ingress localhost
* https://whoami.127.0.0.1.nip.io:9443/
* http://whoami.127.0.0.1.nip.io:9080/

