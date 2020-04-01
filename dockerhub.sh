#!/bin/bash
OPENTTD_VERSION="$(cat OPENTTD_VERSION)"
OPENGFX_VERSION="$(cat OPENGFX_VERSION)"
ARCHES="$(cat ARCHES)"
REGISTRY="$(cat REGISTRY)"
IMAGE="$(cat IMAGE)"
DOCKERHUB=yhaenggi/

for arch in $ARCHES; do
	docker tag ${REGISTRY}${IMAGE}-${arch}:${OPENTTD_VERSION} ${DOCKERHUB}${IMAGE}-${arch}:${OPENTTD_VERSION}
done

REGISTRY=${DOCKERHUB}
for arch in $ARCHES; do
	docker push ${REGISTRY}${IMAGE}-${arch}:${OPENTTD_VERSION}
done

manifests=""
for arch in $ARCHES; do
	manifests+="${REGISTRY}${IMAGE}-${arch}:${OPENTTD_VERSION} "
done

docker manifest create ${REGISTRY}${IMAGE}:${OPENTTD_VERSION} $manifests
docker manifest push --purge ${REGISTRY}${IMAGE}:${OPENTTD_VERSION}
