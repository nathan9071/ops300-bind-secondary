FROM docker.io/library/ubuntu:26.04
RUN apt-get update && \
    apt-get install -y --no-install-recommends bind9 bind9utils && \
    rm -rf /var/lib/apt/lists/*
COPY named.conf.options /etc/bind/
COPY named.conf.local /etc/bind/
RUN chown -R root:root /etc/bind && \
    chmod -R g-w,o-w /etc/bind && \
    if [ -f /etc/bind/rndc.key ]; then chgrp bind /etc/bind/rndc.key && chmod 640 /etc/bind/rndc.key; fi

EXPOSE 53/tcp 53/udp
CMD ["/usr/sbin/named", "-g", "-c", "/etc/bind/named.conf"]
