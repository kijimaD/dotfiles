FROM ubuntu/squid

ARG ACL_MODE

COPY squid.conf /etc/squid/
COPY conf.d/debian.conf /etc/squid/conf.d/
COPY blacklist_${ACL_MODE} /etc/squid/blacklist
