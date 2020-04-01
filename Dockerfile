ARG ARCH
FROM ${ARCH}/ubuntu:latest
MAINTAINER yhaenggi <yhaenggi@darkgamex.ch>

ARG ARCH
ARG OPENTTD_VERSION
ARG OPENGFX_VERSION
ENV OPENTTD_VERSION=${OPENTTD_VERSION}
ENV ARCH=${ARCH}

COPY ./qemu-i386-static /usr/bin/qemu-i386-static
COPY ./qemu-x86_64-static /usr/bin/qemu-x86_64-static
COPY ./qemu-arm-static /usr/bin/qemu-arm-static
COPY ./qemu-aarch64-static /usr/bin/qemu-aarch64-static

RUN echo force-unsafe-io | tee /etc/dpkg/dpkg.cfg.d/docker-apt-speedup
RUN apt-get update

# set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive
#install tzdata package
RUN apt-get install tzdata -y
# set your timezone
RUN ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get install software-properties-common -y
RUN add-apt-repository universe
RUN add-apt-repository multiverse
RUN sed 's/# deb-src/deb-src/g' -i /etc/apt/sources.list
RUN apt-get update

RUN apt-get build-dep openttd -y
RUN apt-get install git debhelper fakeroot devscripts -y
RUN apt-get install libsdl2-dev -y

WORKDIR /tmp/
RUN git clone --depth 1 --branch ${OPENTTD_VERSION} https://github.com/OpenTTD/OpenTTD.git openttd
WORKDIR /tmp/openttd/
RUN mv os/debian .
# hack to disable opengfx dependency. will be build manually later.
# X11 is also removed.
RUN sed '/Recommends:.*/d' -i debian/control
RUN sed '/Suggests:.*/d' -i debian/control
RUN nice -n 10 debuild -uc -us -b
WORKDIR /tmp/
RUN rm -R openttd/
RUN rm openttd*dbg*.deb

WORKDIR /tmp/openttd-opengfx/
COPY ./opengfx-checksum.* ./
RUN wget https://cdn.openttd.org/opengfx-releases/${OPENGFX_VERSION}/opengfx-${OPENGFX_VERSION}-all.zip
RUN md5sum -c opengfx-checksum.md5
RUN sha1sum -c opengfx-checksum.sha1
RUN sha256sum -c opengfx-checksum.sha256
# the official archive is tar archive inside zip... WTF? madness!
RUN apt-get install unzip -y
RUN unzip opengfx-${OPENGFX_VERSION}-all.zip
# it even has a different naming pattern :(
RUN tar xvf opengfx-${OPENGFX_VERSION}.tar
WORKDIR /tmp/openttd-opengfx/opengfx-${OPENGFX_VERSION}/

RUN rm /usr/bin/qemu-i386-static /usr/bin/qemu-x86_64-static /usr/bin/qemu-arm-static /usr/bin/qemu-aarch64-static

FROM ${ARCH}/ubuntu:latest

ARG OPENGFX_VERSION

COPY ./qemu-i386-static /usr/bin/qemu-i386-static
COPY ./qemu-x86_64-static /usr/bin/qemu-x86_64-static
COPY ./qemu-arm-static /usr/bin/qemu-arm-static
COPY ./qemu-aarch64-static /usr/bin/qemu-aarch64-static

WORKDIR /root/

# set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=0 /tmp/openttd*.deb /root/
RUN mkdir -p /usr/share/games/openttd/baseset/opengfx
COPY --from=0 /tmp/openttd-opengfx/opengfx-${OPENGFX_VERSION}/* /usr/share/games/openttd/baseset/opengfx/
#RUN apt-get update && apt-get install tzdata -y && apt-get install --no-install-recommends ./openttd*.deb -y && apt-get clean && rm -Rf /var/cache/apt/ && rm -Rf /var/lib/apt/lists && rm -f openttd*.deb
RUN apt-get update && apt-get install --no-install-recommends ./openttd*.deb -y && apt-get clean && rm -Rf /var/cache/apt/ && rm -Rf /var/lib/apt/lists && rm -f openttd*.deb

# set your timezone
#RUN ln -fs /usr/share/zoneinfo/Europe/Zurich /etc/localtime
#RUN dpkg-reconfigure --frontend noninteractive tzdata

RUN mkdir -p /home/openttd/.openttd
RUN useradd -M -d /home/openttd -u 911 -U -s /bin/bash openttd
RUN usermod -G users openttd
RUN chown openttd:openttd /home/openttd -R

RUN rm /usr/bin/qemu-i386-static /usr/bin/qemu-x86_64-static /usr/bin/qemu-arm-static /usr/bin/qemu-aarch64-static

USER openttd
WORKDIR /home/openttd

EXPOSE 3979/tcp
EXPOSE 3979/udp

ENTRYPOINT ["/usr/games/openttd"]
CMD ["-D"]
