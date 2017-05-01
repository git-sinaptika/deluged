# hs-deluged
Docker image for deluged  
From alpine:3.5  
Deluge: 1.3.14  
This image contains only Deluge Daemon.
Deluge daemon port: 58846
Deluge incoming port tcp&udp: 50100  
[Deluge 1.3.14](http://deluge-torrent.org/)  
[Github](https://github.com/git-sinaptika/hs-deluged)  


#### Simple instructions:  
1. Pull the image from docker-hub:  
`docker pull sinaptika/hs-deluged`  

2. Create a directory called deluge inside your home directory on the host:  
`mkdir ~/deluge`

3. Create or run your container:  
`docker run -d \`  
`-p 50100:50100 \`  
`-p 58846:58846 \`  
`-v ~/deluge:/opt/deluge \`  
`--name c_hs-deluged \`  
`sinaptika/hs-deluged`

4. Create a username and password for logging in to deluge daemon by running:   
`docker exec -it c_hs-deluged deluged-pass.sh`   
You can also add a username and password manually.   
Just edit the **auth** file inside your **deluge/config** directory.

In the example above, we pulled the image from docker-hub,  
created and started a container named c_hs-deluged  
and mounted the directory ~/deluge from the host to /opt/deluge inside the container.  
We have also exposed two ports in the container and mapped them on the host.   
Then we generated user and pass and appended it to deluged's **auth** file.

Other optional variables, that you can pass at `docker create -e` or `docker run -e`  
are:  
- `-e D_UID=<user id of user runninng deluge>` (owner of files)
- `-e D_GID=<group id of user running deluge>`
- `-e D_LOG_LEVEL=<log level of deluged>` (none, info, warning, error, critical, debug)
- `-e TZ=<timezone>` (examples: Europe/London or America/New_York)
