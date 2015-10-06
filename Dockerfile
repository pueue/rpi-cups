FROM resin/rpi-raspbian
MAINTAINER Ammon Sarver <manofarms@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get install -y sudo locales whois cups cups-client cups-bsd \
  && apt-get install -y printer-driver-all \
  && apt-get install -y hpijs-ppds hp-ppd hplip \
  && sed -i "s/^#\ \+\(en_US.UTF-8\)/\1/" /etc/locale.gen \
  && locale-gen en_US en_US.UTF-8

ENV LANG=en_US.UTF-8 \
  LC_ALL=en_US.UTF-8 \
  LANGUAGE=en_US:en

RUN useradd \
  --groups=sudo,lp,lpadmin \
  --create-home \
  --home-dir=/home/print \
  --shell=/bin/bash \
  --password=$(mkpasswd print) \
  print \
  && sed -i '/%sudo[[:space:]]/ s/ALL[[:space:]]*$/NOPASSWD:ALL/' /etc/sudoers \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir /var/lib/apt/lists/partial

USER print