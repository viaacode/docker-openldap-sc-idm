FROM debian:stretch-slim
MAINTAINER Bart Debunne
# derived from https://github.com/viaacode/docker-openldap

ARG SlapdUserId=1001
ENV SlapdUserId $SlapdUserId
ARG LdapPort=8389
ENV LdapPort $LdapPort
# use unpriviliged port!
EXPOSE $LdapPort


# Install software and remove the auto configured ldap backend
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y slapd \
 db-util ldap-utils procps pwgen \
 && rm -rf /var/lib/apt/lists/* \
 && find /etc/ldap/slapd.d/ -type f -exec grep -qi \
 '^olcDbDirectory:.*/var/lib/ldap' {} \; -exec rm {} \; \
 && rm -f /var/lib/ldap/*

#Install git & cleanup
RUN apt-get update && apt-get install -y git
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /docker-entrypoint-init \
  && cd /docker-entrypoint-init \
  && git clone https://github.com/viaacode/viaa-ldap-schema.git .

COPY docker-entrypoint.sh /usr/local/bin/
COPY configure_ldap_access.sh /usr/local/bin/
COPY backend.ldif /
COPY config.ldif /
ADD ldif /docker-entrypoint-init/
RUN chmod +x /usr/local/bin/configure_ldap_access.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Arange access so that the container can run non-privileged
# Enable passwordless access via shared memory for SlapdUserId
# Run as a non-privileged container with a configurable uid
RUN /usr/local/bin/configure_ldap_access.sh \
 && chown -R $SlapdUserId /etc/ldap \
 && chown -R $SlapdUserId /var/run/slapd \
 && chown -R $SlapdUserId /var/lib/ldap
USER $SlapdUserId

VOLUME /var/lib/ldap

ENTRYPOINT ["docker-entrypoint.sh"]
