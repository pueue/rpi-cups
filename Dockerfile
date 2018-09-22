FROM resin/rpi-raspbian
MAINTAINER Ammon Sarver <manofarms@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
  gcc \
  make \
  sudo \
  locales \
  whois \
  cups \
  cups-client \
  cups-bsd \
  printer-driver-all \
  hpijs-ppds \
  hp-ppd \
  hplip 

RUN sed -i "s/^#\ \+\(en_US.UTF-8\)/\1/" /etc/locale.gen \
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
  
RUN wget -O foo2zjs.tar.gz http://foo2zjs.rkkda.com/foo2zjs.tar.gz \
  && tar xvf foo2zjs.tar.gz \
  && cd foo2zjs \
  && make \
  && ./getweb 1020 \
  && make install install-hotplug cups

COPY etc-cups/cupsd.conf /etc/cups/cupsd.conf
EXPOSE 631
ENTRYPOINT ["/usr/sbin/cupsd", "-f"]
