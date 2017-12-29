# sinaptika/deluged
[Github](https://github.com/git-sinaptika/deluged)  
Docker image for deluged  
From alpine:3.7  
From [sinaptika/libtorrent](https://hub.docker.com/r/sinaptika/libtorrent/)  

[Deluge: 1.3.15](http://deluge-torrent.org/)    
[libtorrent: 1.0.11-1.1.5](http://www.libtorrent.org/)    
This image contains only Deluge Daemon.  
Deluge daemon port: 58846  
Deluged incoming port tcp&udp: 50100  

Docker tags: latest/0.7 (1.3.15), dev (2.0b1)
#### Simple instructions:  
1. Pull the image from docker-hub:  
`docker pull sinaptika/deluged`  

2. Create a directory called **deluge** inside your home directory on the host:  
`mkdir ~/deluge`

3. Create or run your container:  
`docker run -d \`  
`--name c_deluged \`  
`-p 50100:50100 \`  
`-p 58846:58846 \`  
`-v ~/deluge:/opt/deluge/complete \`  
`sinaptika/deluged`

4. Create a username and password for logging in to deluge daemon by running:   
`docker exec -it c_deluge deluged-pass.sh`   
You can also add a username and password manually.   
Just edit the **auth** file inside your **~/deluge/config** directory.

In the example above, we pulled the image from docker-hub,  
created and started a container named c_deluged and mounted the directory  
~/deluge from the host to /opt/deluge inside the container.  
We have also exposed two ports in the container and mapped them on the host.   
Then we generated user and pass and appended it to deluged's **auth** file.

Other optional variables, that you can pass at `docker create -e` or `docker run -e`  
are:  
- `-e TZ=<timezone>` (examples: Europe/London or America/New_York)
- `-e D_UID=<user id of user running deluge>` (default user id 1000)
- `-e D_GID=<group id of user running deluge>` (default group id 1000)
- `-e D_D_LOG_LEVEL=<log level of deluged>` (default is warn)

#### Another example:
`docker create`  
We will be using *docker create* instead of run, but you can use either.

`--name c_deluged`  
The name of our container. Use something you will remember and append c_ in front,  
so you don't mix up images and container and volumes and networks...  

`-p 50200:50100`  
Here we are mapping port 50200 on the host to port 50100 on our deluged container.  
We can map a port from the container to any port on the host.  
If you have a firewall between your host running docker and the internet,  
you would then open port 50200/tcp on the fw for incoming connections.  

`-p 50300:50100/udp`  
Here we are having some more fun and mapping udp port 50100 from deluged  
to 50300 on the host.  
You can choose your own values here and even use ranges.  
You can always change ports on the host side as you wish.  
If you change ports the container side, you also need to set them correctly  
inside deluged.  

`-p 50400:58846`  
You will now be able to connect to the daemon with gtkui and web ui on port 50400.  

`-v v_deluged_config:/opt/deluge/config`  
This mounts your containers config directory with configuration files,  
logs and ssl certificates to a named docker volume v_deluged_config  
(usually at /var/lib/docker/volumes).  

`-v /path/to/downloads:/opt/deluge/downloads`  
This mounts the downloads dir from your container to a custom location.  
Make sure the location already exists.

`-v /path/to/complete:/opt/deluge/complete`  
Same as above, but for complete directory. If you are using a cow file system  
it might be useful to have downloads and complete on separate pools and  
"move completed" enabled inside deluge.

`-e TZ=America/Costa_Rica`  
Set the [timezone](https://en.wikipedia.org/wiki/Tz_database).

`-e D_UID:1000 -e D_GID:1000`  
User and group id of the user running deluged. All files downloaded by deluged  
will be owned by that user. 1000 is the default id of the first "human" user   
on debian/ubuntu. You can see your id by typing *id* inside of a terminal.

`--restart=unless-stopped`  
Docker's restart policy. unless-stopped means that docker will always  
restart this container (e.g. after a host restart), unless you stopped it with  
*docker stop c_deluged*.

`sinaptika/deluged`  
Name of the image on which we will base the whole container.

The whole command:  
`docker create \`  
`--name c_deluged \`  
`-p 50200:50100 \`  
`-p 50300:50100/udp \`  
`-p 50400:58846 \`  
`-v v_deluged_config:/opt/deluge/config \`  
`-v /path/to/downloads:/opt/deluge/downloads \`  
`-v /path/to/complete:/opt/deluge/complete \`  
`-e TZ=America/Costa_Rica \`  
`-e D_UID:1000 -e D_GID:1000 \`  
`--restart=unless-stopped \`  
`sinaptika/deluged`

#### Notes:
Don't use `--net host` on *docker create*, unless you know what you are doing.  
If you are using more than one interface with deluge, add docker network to container.  
Macvlan works great, so does ipvlan (but ipvlan is not yet included in docker stable).  
If you are having problems with file permission, check `-e D_UID=`  
If you are only using the web interface for accessing deluged (sinaptika/deluge-web),  
you don't need to expose port 58846 on the host.  
If building this image locally, don't forget that compiling latest libtorrent  
will take some time even on modern hw.  
If the container with deluge-web is running on the same docker host  
(and they are in the same docker network), they will be able to communicate just fine.

**For a complete deluge docker image, consider using deluge images.**  
[deluge github](https://github.com/git-sinaptika/deluge)  
[deluge dockerhub](https://hub.docker.com/r/sinaptika/deluge/)  

**For advance uses or more customization, consider using separate images for deluged and deluge-web.**  
[deluged github](https://github.com/git-sinaptika/deluged)  
[deluged dockerhub](https://hub.docker.com/r/sinaptika/deluged/)  
[deluge-web github](https://github.com/git-sinaptika/deluge-web)  
[deluge-web dockerhub](https://hub.docker.com/r/sinaptika/deluge-web/)  

#### Changelog for deluge, deluged and deluge-web:  
**0.1**  
- supervisor integration  
  - umask and user done
  - passing variables to entrypoint and supervisor done  

**0.2**  
- fixing typos in readme, some basic editing in dockerfile
  - starting to unify structure/style in deluged, deluge-web and deluge images  

**0.3**
- downgraded libtorrent to 1.0.11 for stable, latest, and 1.3.15 tags
- added dev and stable

**0.4**
- Changed to multi-stage build and ssl force on deluge-web

**0.5**
- Dir strcuture changes on github and tag changes on docker hub
- Some syntax changes
- Added first run with debug for deluge-web

**0.6**
- Changed git source from git:deluge.org to github 
- removed selfsigned certs from image

**0.7**
- Upgraded libtorrent and deluge base images to Alpine 3.7
- Defined config as a volume in dockerfile, so it can work as stated in the readme
- Removed some WORKDIR layers for easier readability
  - Specified Supervisord pid location
  - Specified Supervisord log location
- Replaced unrar with p7zip (extractor plugin uses it)

**0.8**
- Changed builder images (libtorrent)