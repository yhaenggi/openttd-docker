These images have been built and tested on docker i386, amd64, arm32v7 and arm64v8. This is a multi platform image.

## Usage ##

    docker run -d -p 3979:3979/tcp -p 3979:3979/udp yhaenggi/openttd:13.4

Its set up to not load any games by default (new game) but you can change it with the CMD argument. 


## Build ##

If you want to build the images yourself, you'll have to adapt the registry file, copy qemu and enable binfmt.

    cp /usr/bin/qemu-{x86_64,arm,aarch64}-static .

In case you want other arches, just add them in the ARCHES files and copy the corresponding qemu user static binary. If you want support for another archtitecture, open an issue.

On some distros, you have to manually enable binfmt support:

    sudo service binfmt-support restart

You can verify if it worked with this (should show enabled):

    update-binfmts --display|grep -E "arm|aarch"

## Tags ##
   * 13.4
   * 13.1
   * 13.0
   * 12.2
   * 1.10.3
   * 1.10.2
   * 1.10.1
   * 1.10.0
   * 1.9.3
