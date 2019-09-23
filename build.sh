#!/bin/bash
OPENTTD_VERSION="1.9.3"
OPENGFX_VERSION="debian/0.5.5-1"
ARCHES="amd64 arm32v7 arm64v8"
REGISTRY=registry.traefik.k8.darkgamex.ch/

for arch in $ARCHES; do
echo	docker build -t ${REGISTRY}openttd-${arch}:${OPENTTD_VERSION} --build-arg OPENTTD_VERSION=${OPENTTD_VERSION} --build-arg OPENGFX_VERSION=${OPENGFX_VERSION} --build-arg ARCH=${arch} .
done

for arch in $ARCHES; do
echo	docker push -t ${REGISTRY}openttd-${arch}:${OPENTTD_VERSION}
done

manifests=""
for arch in $ARCHES; do
	manifests+="${REGISTRY}openttd-${arch}:${OPENTTD_VERSION} "
done

docker manifest create ${REGISTRY}openttd:${OPENTTD_VERSION} $manifests
docker manifest push --purge ${REGISTRY}openttd:${OPENTTD_VERSION}
