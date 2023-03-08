# Serve Valheim 

Code and instructions to build and serve Valheim.

## AWS Lightsail

I prefer to choose AWS Lightsail, since I am into IT and know to run some basic stuff with Docker. If you are not used to these, it is easy to learn, but if you prefer to not learn this, just use a pre-setup hosted Valheim game server from any provider - but those are not necessarily as good/fast/configurable as doing it on your own.

For creating a lightsail instance and configuring it inside AWS, you can follow https://updateloop.dev/dedicated-valheim-lightsail/ until setting up the docker-compose, for using a perfect setup docker image, I would always recommend https://github.com/lloesche/valheim-server-docker - you can follow the instructions there for setting up the docker image and compose script.

I recommend to use a default Ubuntu 20.04 image. You will need at least a configuration like 4 GB RAM, 2 vCPUs. 

### AWS Lightsail Networking setup

* add rule for TCP port 9001
* add rule for UDP port 2456-2457
* remove rule for HTTP on port 80
* keep the SSH rule for port 22

### Host setup

Login to the AWS Lightsail instance via SSH (e.g. using Putty on Windows, requires AWS "*.pem" keys to be converted to Putty's .ppk using Putty Keygen to load the .pem and safe the private key).

Execute these commands to setup docker and docker-comose on a fresh instance:
```
sudo apt update
sudo apt upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh
sudo apt install docker-compose -y
```

### Docker image and compose script setup

As said before, I recommend using https://github.com/lloesche/valheim-server-docker for docker image and server setup.

I also prefer using docker-compose, see especially the section https://github.com/lloesche/valheim-server-docker#deploying-with-docker-compose 

Or here the commands:
```
mkdir -p $HOME/valheim-server/config/worlds_local $HOME/valheim-server/data
touch $HOME/valheim-server/valheim.env
curl -o $HOME/valheim-server/docker-compose.yaml https://raw.githubusercontent.com/lloesche/valheim-server-docker/main/docker-compose.yaml
sed -i "s/\$HOME/\/home\/$(whoami)/g" valheim-server/docker-compose.yaml
```

Then you can still edit, add any setting to the '$HOME/valheim-server/valheim.env' file pre-created. 

I do recommend (replace <...>):
```
SERVER_NAME=<your server name>
WORLD_NAME=<use the world name, if you copied any locally saved before to $HOME/valheim-server/config/worlds_local the file name "myworld" for files like "myworld.db" and "myworld.fwl">
SERVER_PASS=<use your password, min 5 characters>
SERVER_PUBLIC=true
BEPINEX=true
```

### Starting the server

Navigate to the server folder and run:
```
cd $HOME/valheim-server
rm nohup.out; nohup sudo docker-compose up & 
```

NOTE: first startup will take a while, since it needs to download a lot.
NOTE: if the server needs to create a world, it will also take quite a while until the game is up the first time

since this will redirect all console output to a file, you can view the log using:
```
tail -F nohup.out
```

#### Fixing file ownership and permissions

Some of the processes of the docker container running with root permissions do create files and folders that are owned by root, even changing PUIG and GUID still showed rare cases, where this would not work properly. Therefore sometimes it might be required to change the folder owner back to the normal user.
```
chown ubuntu:ubuntu -R $HOME/valheim-server
```

### Uploading server side mods

To simply create a server from an existing modpack, you will need to upload the local mod pack DLLs and config files to the server. For this you can use WinSCP (in case transferring from Windows).

In case you are using Thunderstore Mod Manager, it is easy to find the mods needed to upload in the folder:
```
C:\Users\<felix - replace this>\AppData\Roaming\Thunderstore Mod Manager\DataFolder\Valheim\profiles
```

After uploading the mod packs, you will need to restart the server:
```
cd $HOME/valheim-server
sudo docker-compose down
rm nohup.out
nohup sudo docker-compose up & 
```

#### Uploading config files

Go into the profile you downloaded the modpack and navigate to config folder like:
```
C:\Users\<felix - replace this>\AppData\Roaming\Thunderstore Mod Manager\DataFolder\Valheim\profiles\single\BepInEx\config
```

Config files (and sub folders) need to be put on the server into:
```
/home/ubuntu/valheim-server/config/bepinex
```

#### Uploading plugin DLLs

Go into the profile you downloaded the modpack and navigate to plugins folder like:
```
C:\Users\<felix - replace this>\AppData\Roaming\Thunderstore Mod Manager\DataFolder\Valheim\profiles\single\BepInEx\plugins
```

Plugin folders (including DLLs and other things) need to be put on the server into (sub folder inside the config folders):
```
/home/ubuntu/valheim-server/config/bepinex/plugins
```

