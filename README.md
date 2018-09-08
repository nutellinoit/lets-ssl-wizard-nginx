# LET'S SSL  WIZARD NGINX

Automatic ssl issuing and nginx reverse proxy configuration

## Usage

1. SSH on your nginx reverse proxy
1. Clone project and `cd ~/lets-ssl-wizard-nginx`
1. Start wizard with `./lets-ssl-wizard-nginx.sh`

If using route 53 remember to export key before running script

```bash
export  AWS_ACCESS_KEY_ID=XXXXX
export  AWS_SECRET_ACCESS_KEY=YYYYYYY
```


## Requirement

* Acme.sh installed as root


