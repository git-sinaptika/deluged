# sinaptika/deluged
Docker image for deluged  
From alpine:3.5  
Deluge: 1.3.15  
This image contains only Deluge Daemon.  
Deluge daemon port: 58846  
Deluged incoming port tcp&udp: 50100  
[Deluge 1.3.15](http://deluge-torrent.org/)  
[Github](https://github.com/git-sinaptika/hs-deluged)  


#### Simple instructions:  
1. Pull the image from docker-hub:  
`docker pull sinaptika/deluged`  

2. Create a directory called deluge inside your home directory on the host:  
`mkdir ~/deluge`

3. Create or run your container:  
`docker run -d \`  
`--name c_deluged \`  
`-p 50100:50100 \`  
`-p 58846:58846 \`  
`-v ~/deluge:/opt/deluge \`  
`sinaptika/deluged`

4. Create a username and password for logging in to deluge daemon by running:   
`docker exec -it c_deluged deluged-pass.sh`   
You can also add a username and password manually.   
Just edit the **auth** file inside your **deluge/config** directory.

In the example above, we pulled the image from docker-hub,  
created and started a container named c_deluged  
and mounted the directory ~/deluge from the host to /opt/deluge inside the container.  
We have also exposed two ports in the container and mapped them on the host.   
Then we generated user and pass and appended it to deluged's **auth** file.

Other optional variables, that you can pass at `docker create -e` or `docker run -e`  
are:  
- `-e D_UID=<user id of user runninng deluge>` (owner of files)
- `-e D_GID=<group id of user running deluge>`
- `-e D_LOG_LEVEL=<log level of deluged>` (none, info, warning, error, critical, debug)
- `-e TZ=<timezone>` (examples: Europe/London or America/New_York)

#### Another example:
`docker create`  
We will be using docker create instead of run, but you can use either.

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
You can choose your own values here and even use ranges *-p 1234-1236:1234/tcp*  
You can always change ports on the host side as you wish.  
If you change ports the container side, you also need to set them correctly on the daemon.  

`-p 50400:58846`  
You will now be able to connect to the daemon with gtkui and web ui on port 50400.  

`-v /home/my_username/deluged_config:/opt/deluge/config`  
This mounts your containers config directory with logs and ssl certificates to a directory  
deluged_config inside your home dir. Make sure the directory already exists.  

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
`-v /home/my_username/deluged_config:/opt/deluge/config \`  
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
you don't need to expose port 58846 on the host. If the container with deluge-web  
is running on the same docker host (and they are in the same docker network),  
they will be able to communicate just fine.
