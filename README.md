## Private Tor Network on Docker

##### An isolated, private tor network running entirely in Docker containers

### Quickstart

The easiest way to get a tor network up and running is to use the docker-compose create and then scale function

```
docker-compose up 
docker-compose scale relay=5 exit=3 
```

This will create 3 directory authorities (DA's), 1 client listning on port 9050, 5 relays, and 3 exits. You can scale to whatever you want. 

### Uses

If you're going "Why do I want this?" here's a few examples:

**tor research**: learn how tor interacts with nodes, make modifications to settings and see what happens, understand how the Tor Network operates without affecting real people. Originally this project was part of a class I wrote to teach about how tor works.

**tor development**: in the case you're working on a patch that is more complex and requires seeing what happens on the tor network, you can apply the patches to the containers.

**traffic analysis**: Test out the latest tor exploit and pretend to be a nation state adversary.

*If this needs to be said, this should never be used as a replacement for tor. This is for research purposes alone.*

### Network Settings

All of the required information that other nodes need to know about on the network are stored in a mapped volume: `./tor:/tor`. (I know you shouldn't do this but I needed it for a class) NOTE: This folder must exist on the host and allow the debian-tor user to create files in this directory. 

### Running Individual Roles

You can manually build a tor network if you don't want to use docker-compose but you'll need to make sure you pass the correct DA fingerprints to each of the servers. (Don't for you automatically with docker-compose) For example, this would make the first directory authority (DA)
`docker run -e ROLE=DA antitree/private-tor`

Or setup a relay:
`docker run -e ROLE=RELAY antitree/private-tor`

Watching the logs on a relay
`docker logs -f {name of your container}`

Available roles right now are:

* DA - directory authority
* RELAY - non-exit relay
* EXIT - exit relay
* CLIENT - exposes the tor socks port on 9050 to the host

### Onion Services

If you'd like to run an onion service, you can use the `TOR_HS_PORT` and `TOR_HS_ADDRESS` environment variables. By default, there is a hidden service setup in the docker-compose.yml file. 

Example configuration that will run an onion service named "hs" and a web server named "web". This will link the web service to the onion service so that "hs" will forward connections to "web" on port 80. This is done using the `links` configuration feature for docker-compose. 

```
 hs:
  image: antitree/private-tor
  expose:
    - "80"
  environment:
    ROLE: HS
    # This will create a hidden service that points to
    # the service "web" which is runing nginx. You can 
    # change this to whatever ip or hostname you want
    TOR_HS_PORT: "80"
    TOR_HS_ADDR: "web"
  volumes:
    - ./tor:/tor
  depends_on:
    - da1
    - da2
    - da3
  links:
    - web
 web:
  image: nginx
  expose:
    - "80"
```

NOTE: By default, this just displays the nginx start page so you may want to replace the image with a more interesting one or configure the nginx container with some static HTML to host.

### Tor configuration

This configuration is based on the Tor documentation for how to run a private tor network. You should also check out [Chutney](https://gitweb.torproject.org/chutney.git/) which does something similar with separate processes instead of containers. If you need to make a modification (such as changing the timing of the DA's) edit the `config/torrc` and/or `config/torrc.da` files. You may need to modify the Dockerfile as well.

### Environment variables

The container is built off of [chriswayg/tor-server](https://github.com/chriswayg/tor-server) but has been heavily modified to support some other env variables that you can pass to it:

* TOR_ORPORT - default is 7000
* TOR_DIRPORT - default is 9030
* TOR_DIR - container path to mount a persistent tor material. default is /tor
* TOR_CONTROL_PWD - set the control port password to something besides "password"
* TOR_HS_PORT - port to listen for an onion service on
* TOR_HS_ADDR - IP or hostname of service you want to point an onion service to

### Things to try

The `/util/` directory contains a few scripts to play with one the host computer. Once you have a 
private tor network up and running you can try out some of the tools in there. 

**Using Arm**:

With the tor control port exposed to the host, you can use arm to monitor the client. 
```
apt-get install tor-arm
arm
```
NOTE: There is a password to protect the control port right now. Enter "password" when prompted

![arm screenshot](https://raw.githubusercontent.com/antitree/private-tor-network/master/doc/arm.png)

You can also connect arm to one of the containers if you know it's ip. You can find the IPs by running the 
`get_consensus.py` script provided or however otherway you feel like. 

```arm -i 172.19.0.3:9051```

**Get Consensus**:

```python util/get_consensus.py```

This will connect to the CLIENT docker container via the tor Control Port and download the consensus which
contains the nicknames and IPs of the relays on the network. (If this is blank, you may have to wait 30s
while they decided on a consensus.)

**Tor-prompt**:

If you've installed arm you will probably also have the `tor-prompt` command. You can use it to manually 
gather information about some of the containers that have their Control Port exposed like so:

```
tor-prompt -i {ip_of_ontainer}:9051
Control Port password: password
```


### Debugging

Here are a few things to try if you're runing into issues:

* Check the tor logs sent to stdout `docker logs -f torserver_da_1`
* Check all the logs with `docker-compose logs`
* Enable verbose logging by changing the `./config/torrc` 
* Check permissions for your ./tor folder
* Delete the files in your ./tor folder so you can start from scratch (or specifically the torrc.da file)
* To cleanup the environment and start over you can use `docker-compose kill` and `docker-compose rm -ra` to remove them all. 

### TODO

* Wait for someone to yell at me about using scale like this and then move to the new networking

### Dislaimer

This project is in no way associated with the Tor Project or their developers. Like many people I'm a fan of Tor and recommend considering ways you can help the project. Consider running a relay, donating, or writing code. 

### Resources
- https://github.com/andrewmichaelsmith/private-tor-network-kube Used some of this work to port to a kubernetes config
- https://github.com/chriswayg/tor-server
- https://www.torproject.org/docs/tor-relay-debian.html.en
