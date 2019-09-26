#!/bin/bash
OPENTTD_VERSION="$(cat OPENTTD_VERSION)"
OPENGFX_VERSION="$(cat OPENGFX_VERSION)"
ARCHES="$(cat ARCHES)"
REGISTRY="$(cat REGISTRY)"
DOCKERHUB=yhaenggi/

for arch in $ARCHES; do
	docker tag ${REGISTRY}openttd-${arch}:${OPENTTD_VERSION} ${DOCKERHUB}openttd-${arch}:${OPENTTD_VERSION}
done

REGISTRY=${DOCKERHUB}
for arch in $ARCHES; do
	docker push ${REGISTRY}openttd-${arch}:${OPENTTD_VERSION}
done

manifests=""
for arch in $ARCHES; do
	manifests+="${REGISTRY}openttd-${arch}:${OPENTTD_VERSION} "
done

docker manifest create ${REGISTRY}openttd:${OPENTTD_VERSION} $manifests
docker manifest push --purge ${REGISTRY}openttd:${OPENTTD_VERSION}
