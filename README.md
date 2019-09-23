These images have been built and tested on docker amd64, arm32v7 and arm64v8. This is a multi platform image.

## Usage ##

    docker run -d -p 3979:3979/tcp -p 3979:3979/udp registry.traefik.k8.darkgamex.ch/openttd:latest

For random port assignment replace

    -p 3979:3979/tcp -p 3979:3979/udp

with 

    -P

Its set up to not load any games by default (new game) and it can be run without mounting a .openttd folder. 
However, if you want to load your savegames, mounting a .openttd folder is required.

Config files is located under /home/openttd/.openttd. To mount up your .openttd folder use 

   -v /path/to/your/.openttd:/home/openttd/.openttd

For example to run server and load my savename game.sav:

    docker run -d --name openttd -p 3979:3979/tcp -p 3979:3979/udp -v /home/<your_username>/.openttd:/home/openttd/.openttd registry.traefik.k8.darkgamex.ch/openttd:latest

## Other tags ##
   * None yet
