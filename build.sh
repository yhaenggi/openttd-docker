#!/bin/bash
OPENTTD_VERSION="$(cat OPENTTD_VERSION)"
OPENGFX_VERSION="$(cat OPENGFX_VERSION)"
ARCHES="$(cat ARCHES)"
REGISTRY="$(cat REGISTRY)"
IMAGE="$(cat IMAGE)"

for arch in $ARCHES; do
	docker build -t ${REGISTRY}${IMAGE}-${arch}:${OPENTTD_VERSION} --build-arg OPENTTD_VERSION=${OPENTTD_VERSION} --build-arg OPENGFX_VERSION=${OPENGFX_VERSION} --build-arg ARCH=${arch} .
done

for arch in $ARCHES; do
	docker push ${REGISTRY}${IMAGE}-${arch}:${OPENTTD_VERSION}
done

manifests=""
for arch in $ARCHES; do
	manifests+="${REGISTRY}${IMAGE}-${arch}:${OPENTTD_VERSION} "
done

docker manifest create ${REGISTRY}${IMAGE}:${OPENTTD_VERSION} $manifests
docker manifest push --purge ${REGISTRY}${IMAGE}:${OPENTTD_VERSION}
