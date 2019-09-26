These images have been built and tested on docker amd64, arm32v7 and arm64v8. This is a multi platform image.

## Usage ##

    docker run -d -p 3979:3979/tcp -p 3979:3979/udp yhaenggi/openttd:latest

For random port assignment replace

    -p 3979:3979/tcp -p 3979:3979/udp

with 

    -P

Its set up to not load any games by default (new game) but you can change it with the CMD argument. 
