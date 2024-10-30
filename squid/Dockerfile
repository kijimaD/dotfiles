FROM ubuntu/squid

ARG ACL_MODE

RUN apt update && \
    apt install -y squidguard

COPY squid.conf /etc/squid/
COPY conf.d/debian.conf /etc/squid/conf.d/
COPY blacklist_${ACL_MODE} /etc/squid/blacklist

COPY squidguard/squidGuard.conf /etc/squidguard/squidGuard.conf
COPY squidguard/deny/* /var/lib/squidguard/db/deny/
RUN squidGuard -C all

RUN chown -R proxy:proxy /var/lib/squidguard/db && \
    chmod -R 755 /var/lib/squidguard/db
