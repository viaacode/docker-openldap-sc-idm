# docker-openldap-sc-idm

VIAA customization for local [docker-openldap](https://github.com/viaacode/docker-openldap.git)

# deploy

build, config, run

1. docker build . -t sc-openldap --no-cache
2. create env file with
  - LDAP_SUFFIX={your_domain_suffix}
  - LDAP_ROOT_PASSWORD={admin_password}
  - OLCROOTPW_CONFIG={config_password}
3. docker run --name {suffix}-ldap -a stdout --env-file ./env -p 8389:8389/tcp sc-openldap:latest
