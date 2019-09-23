ARG ARCH
FROM ${ARCH}/ubuntu:latest AS openttd-builder
MAINTAINER Xeha <Xeha@i2pmail.org>

ARG ARCH
ARG OPENTTD_VERSION
ARG OPENGFX_VERSION
ENV OPENTTD_VERSION=${OPENTTD_VERSION}
ENV ARCH=${ARCH}

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

WORKDIR /tmp/
RUN git clone --depth 1 --branch ${OPENTTD_VERSION} https://github.com/OpenTTD/OpenTTD.git openttd
WORKDIR /tmp/openttd/
RUN mv os/debian .
RUN debuild -uc -us -b
WORKDIR /tmp/
RUN rm -R openttd/

RUN apt-get build-dep openttd-opengfx -y
RUN git clone --depth 1 --branch ${OPENGFX_VERSION} https://salsa.debian.org/openttd-team/openttd-opengfx.git
WORKDIR /tmp/openttd-opengfx/
RUN debuild -uc -us -b
WORKDIR /tmp/
RUN rm -R openttd-opengfx/

RUN rm /usr/bin/qemu-x86_64-static /usr/bin/qemu-arm-static /usr/bin/qemu-aarch64-static

FROM ubuntu:latest

WORKDIR /root/
COPY --from=openttd-builder /tmp/openttd*.deb /root/
RUN rm -f openttd*dbg*.deb
RUN apt-get update
RUN apt-get install --no-install-recommends ./openttd*.deb -y
RUN rm -f openttd*.deb

RUN mkdir -p /home/openttd/.openttd
RUN useradd -M -d /home/openttd -u 911 -U -s /bin/bash openttd
RUN usermod -G users openttd
RUN chown openttd:openttd /home/openttd -R

USER openttd
WORKDIR /home/openttd

EXPOSE 3979/tcp
EXPOSE 3979/udp

ENTRYPOINT ["/usr/games/openttd"]
CMD ["-D"]
